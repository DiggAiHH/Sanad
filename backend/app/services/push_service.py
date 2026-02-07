"""
Push Notification Service using Firebase Cloud Messaging (FCM).

Handles:
    - Device token registration/unregistration
    - Sending notifications to individual users or groups
    - Batch sending with failure handling
    - Token cleanup on invalid tokens

Security:
    - FCM credentials via environment variable (GOOGLE_APPLICATION_CREDENTIALS)
    - No sensitive data in notification payloads
    - Token validation before storage
"""

import logging
import os
from pathlib import Path
from typing import Optional
from uuid import UUID

from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import PushDeviceToken, DevicePlatform
from app.schemas.schemas import (
    PushNotificationPayload,
    PushNotificationStats,
    PushNotificationType,
)

logger = logging.getLogger(__name__)

# Firebase initialization (lazy)
_firebase_app = None
_firebase_init_error: Optional[str] = None


def validate_firebase_credentials() -> tuple[bool, Optional[str]]:
    """
    Validate Firebase credentials at startup.

    Returns:
        Tuple of (is_valid, error_message).

    Raises:
        None - returns validation result for caller to handle.
    """
    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")

    if not cred_path:
        return False, "GOOGLE_APPLICATION_CREDENTIALS environment variable not set"

    cred_file = Path(cred_path)
    if not cred_file.exists():
        return False, f"Firebase credentials file not found: {cred_path}"

    if not cred_file.is_file():
        return False, f"Firebase credentials path is not a file: {cred_path}"

    # Basic JSON validation
    try:
        import json

        with open(cred_file, "r") as f:
            cred_data = json.load(f)

        required_keys = ["type", "project_id", "private_key", "client_email"]
        missing = [k for k in required_keys if k not in cred_data]
        if missing:
            return False, f"Firebase credentials missing keys: {missing}"

        if cred_data.get("type") != "service_account":
            return False, f"Invalid Firebase credential type: {cred_data.get('type')}"

    except json.JSONDecodeError as e:
        return False, f"Firebase credentials file is not valid JSON: {e}"
    except Exception as e:
        return False, f"Failed to read Firebase credentials: {e}"

    return True, None


def _init_firebase():
    """Initialize Firebase Admin SDK (once)."""
    global _firebase_app, _firebase_init_error
    if _firebase_app is not None:
        return _firebase_app

    if _firebase_init_error is not None:
        # Already tried and failed
        return None

    # Validate credentials first
    is_valid, error = validate_firebase_credentials()
    if not is_valid:
        _firebase_init_error = error
        logger.warning(f"Firebase disabled: {error}")
        return None

    try:
        import firebase_admin
        from firebase_admin import credentials

        cred_path = os.environ["GOOGLE_APPLICATION_CREDENTIALS"]  # Fail-fast
        cred = credentials.Certificate(cred_path)
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized successfully")
        return _firebase_app
    except Exception as e:
        _firebase_init_error = str(e)
        logger.error(f"Failed to initialize Firebase: {e}")
        return None


def get_firebase_status() -> dict:
    """
    Get Firebase initialization status for health checks.

    Returns:
        Dict with 'initialized', 'enabled', and 'error' keys.
    """
    return {
        "initialized": _firebase_app is not None,
        "enabled": os.environ.get("GOOGLE_APPLICATION_CREDENTIALS") is not None,
        "error": _firebase_init_error,
    }


class PushNotificationService:
    """Service for managing push notifications."""

    def __init__(self, db: AsyncSession):
        self.db = db

    # =========================================================================
    # Token Management
    # =========================================================================

    async def register_token(
        self,
        user_id: UUID,
        fcm_token: str,
        platform: DevicePlatform,
        device_name: Optional[str] = None,
        app_version: Optional[str] = None,
    ) -> PushDeviceToken:
        """
        Register or update FCM device token for a user.

        If token already exists (same token, different user), reassign it.
        """
        # Check if token already exists
        existing = await self.db.execute(
            select(PushDeviceToken).where(PushDeviceToken.fcm_token == fcm_token)
        )
        token_record = existing.scalar_one_or_none()

        if token_record:
            # Update existing token
            token_record.user_id = user_id
            token_record.platform = platform
            token_record.device_name = device_name
            token_record.app_version = app_version
            token_record.is_active = True
            logger.info("FCM token updated", extra={"user_id": str(user_id)})
        else:
            # Create new token
            token_record = PushDeviceToken(
                user_id=user_id,
                fcm_token=fcm_token,
                platform=platform,
                device_name=device_name,
                app_version=app_version,
            )
            self.db.add(token_record)
            logger.info("FCM token registered", extra={"user_id": str(user_id)})

        await self.db.commit()
        await self.db.refresh(token_record)
        return token_record

    async def unregister_token(self, fcm_token: str) -> bool:
        """Unregister/deactivate a device token."""
        result = await self.db.execute(
            update(PushDeviceToken)
            .where(PushDeviceToken.fcm_token == fcm_token)
            .values(is_active=False)
        )
        await self.db.commit()
        return result.rowcount > 0

    async def get_user_tokens(self, user_id: UUID) -> list[PushDeviceToken]:
        """Get all active tokens for a user."""
        result = await self.db.execute(
            select(PushDeviceToken).where(
                PushDeviceToken.user_id == user_id,
                PushDeviceToken.is_active.is_(True),
            )
        )
        return list(result.scalars().all())

    async def cleanup_invalid_tokens(self, invalid_tokens: list[str]) -> int:
        """Remove invalid tokens from database."""
        if not invalid_tokens:
            return 0

        result = await self.db.execute(
            delete(PushDeviceToken).where(PushDeviceToken.fcm_token.in_(invalid_tokens))
        )
        await self.db.commit()
        logger.info(f"Cleaned up {result.rowcount} invalid FCM tokens")
        return result.rowcount

    # =========================================================================
    # Sending Notifications
    # =========================================================================

    async def send_to_user(
        self,
        user_id: UUID,
        payload: PushNotificationPayload,
    ) -> PushNotificationStats:
        """Send notification to all devices of a single user."""
        tokens = await self.get_user_tokens(user_id)
        if not tokens:
            return PushNotificationStats(total_tokens=0, successful=0, failed=0)

        return await self._send_to_tokens(
            [t.fcm_token for t in tokens],
            payload,
        )

    async def send_to_users(
        self,
        user_ids: list[UUID],
        payload: PushNotificationPayload,
    ) -> PushNotificationStats:
        """Send notification to multiple users."""
        if not user_ids:
            return PushNotificationStats(total_tokens=0, successful=0, failed=0)

        # Get all tokens for users
        result = await self.db.execute(
            select(PushDeviceToken).where(
                PushDeviceToken.user_id.in_(user_ids),
                PushDeviceToken.is_active.is_(True),
            )
        )
        tokens = list(result.scalars().all())

        if not tokens:
            return PushNotificationStats(total_tokens=0, successful=0, failed=0)

        return await self._send_to_tokens(
            [t.fcm_token for t in tokens],
            payload,
        )

    async def send_to_topic(
        self,
        topic: str,
        payload: PushNotificationPayload,
    ) -> bool:
        """Send notification to FCM topic (e.g., 'queue_A', 'all_mfa')."""
        if not _init_firebase():
            logger.warning("Firebase not initialized - skipping topic push")
            return False

        try:
            from firebase_admin import messaging

            message = messaging.Message(
                notification=messaging.Notification(
                    title=payload.title,
                    body=payload.body,
                ),
                data=self._prepare_data(payload),
                topic=topic,
            )

            response = messaging.send(message)
            logger.info(f"Topic push sent: {topic}", extra={"response": response})
            return True
        except Exception as e:
            logger.error(f"Topic push failed: {e}")
            return False

    async def _send_to_tokens(
        self,
        tokens: list[str],
        payload: PushNotificationPayload,
    ) -> PushNotificationStats:
        """Internal: Send to list of FCM tokens with batch support."""
        if not _init_firebase():
            logger.warning("Firebase not initialized - skipping push")
            return PushNotificationStats(
                total_tokens=len(tokens), successful=0, failed=len(tokens)
            )

        try:
            from firebase_admin import messaging

            messages = [
                messaging.Message(
                    notification=messaging.Notification(
                        title=payload.title,
                        body=payload.body,
                    ),
                    data=self._prepare_data(payload),
                    token=token,
                )
                for token in tokens
            ]

            # Batch send (max 500 per batch)
            response = messaging.send_each(messages)

            invalid_tokens = []
            for i, result in enumerate(response.responses):
                if not result.success:
                    error = result.exception
                    if error and "UNREGISTERED" in str(error):
                        invalid_tokens.append(tokens[i])

            # Cleanup invalid tokens
            if invalid_tokens:
                await self.cleanup_invalid_tokens(invalid_tokens)

            stats = PushNotificationStats(
                total_tokens=len(tokens),
                successful=response.success_count,
                failed=response.failure_count,
                invalid_tokens=invalid_tokens,
            )

            logger.info(
                "Push batch sent",
                extra={
                    "total": stats.total_tokens,
                    "success": stats.successful,
                    "failed": stats.failed,
                },
            )
            return stats

        except Exception as e:
            logger.error(f"Push send failed: {e}")
            return PushNotificationStats(
                total_tokens=len(tokens),
                successful=0,
                failed=len(tokens),
            )

    def _prepare_data(self, payload: PushNotificationPayload) -> dict[str, str]:
        """Prepare data payload for FCM (all values must be strings)."""
        data = {
            "notification_type": payload.notification_type.value,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        if payload.data:
            for key, value in payload.data.items():
                data[key] = str(value) if value is not None else ""
        return data


# ============================================================================
# Convenience Functions for Common Notifications
# ============================================================================


async def notify_ticket_called(
    db: AsyncSession,
    patient_user_id: UUID,
    ticket_number: str,
    room: Optional[str] = None,
) -> PushNotificationStats:
    """Notify patient that their ticket number was called."""
    service = PushNotificationService(db)

    body = "Bitte begeben Sie sich zum Behandlungsraum."
    if room:
        body = f"Bitte begeben Sie sich zu {room}."

    return await service.send_to_user(
        user_id=patient_user_id,
        payload=PushNotificationPayload(
            notification_type=PushNotificationType.TICKET_CALLED,
            title=f"🔔 Sie sind dran: {ticket_number}",
            body=body,
            data={"ticket_number": ticket_number, "room": room or ""},
        ),
    )


async def notify_check_in_success(
    db: AsyncSession,
    patient_user_id: UUID,
    ticket_number: str,
    queue_name: str,
    estimated_wait_minutes: int,
) -> PushNotificationStats:
    """Notify patient of successful check-in."""
    service = PushNotificationService(db)

    return await service.send_to_user(
        user_id=patient_user_id,
        payload=PushNotificationPayload(
            notification_type=PushNotificationType.CHECK_IN_SUCCESS,
            title="✅ Check-in erfolgreich",
            body=f"Ticket {ticket_number} für {queue_name}. Wartezeit ca. {estimated_wait_minutes} Min.",
            data={
                "ticket_number": ticket_number,
                "queue_name": queue_name,
                "estimated_wait": str(estimated_wait_minutes),
            },
        ),
    )


async def notify_mfa_new_ticket(
    db: AsyncSession,
    mfa_user_ids: list[UUID],
    ticket_number: str,
    queue_name: str,
) -> PushNotificationStats:
    """Notify MFA staff about new ticket in queue."""
    service = PushNotificationService(db)

    return await service.send_to_users(
        user_ids=mfa_user_ids,
        payload=PushNotificationPayload(
            notification_type=PushNotificationType.TICKET_CREATED,
            title=f"📋 Neues Ticket: {ticket_number}",
            body=f"Warteschlange {queue_name}",
            data={"ticket_number": ticket_number, "queue_name": queue_name},
        ),
    )
