"""
Push notification API endpoints.

Handles device token registration and management.
"""


from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import User, UserRole
from app.schemas.schemas import (
    MessageResponse,
    RegisterDeviceTokenRequest,
    RegisterDeviceTokenResponse,
    UnregisterDeviceTokenRequest,
)
from app.services.push_service import PushNotificationService, get_firebase_status

router = APIRouter(prefix="/push", tags=["Push Notifications"])


@router.post(
    "/register",
    response_model=RegisterDeviceTokenResponse,
    summary="Register FCM device token",
    description="Register or update FCM token for push notifications.",
)
async def register_device_token(
    request: RegisterDeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Register device token for push notifications.

    - Token is associated with current authenticated user
    - If token already exists, ownership is transferred
    - One user can have multiple devices (iOS, Android, Web)
    """
    service = PushNotificationService(db)

    token_record = await service.register_token(
        user_id=current_user.id,
        fcm_token=request.fcm_token,
        platform=request.platform,
        device_name=request.device_name,
        app_version=request.app_version,
    )

    return RegisterDeviceTokenResponse(
        success=True,
        device_id=token_record.id,
        message="Gerät erfolgreich für Push-Benachrichtigungen registriert",
    )


@router.post(
    "/unregister",
    response_model=MessageResponse,
    summary="Unregister FCM device token",
    description="Unregister device from push notifications (e.g., on logout).",
)
async def unregister_device_token(
    request: UnregisterDeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Unregister device from push notifications.

    Should be called on:
    - User logout
    - App uninstall detection
    - Token refresh (old token)
    """
    service = PushNotificationService(db)

    success = await service.unregister_token(request.fcm_token)

    if not success:
        # Token not found - still return success (idempotent)
        return MessageResponse(message="Token bereits entfernt oder nicht gefunden")

    return MessageResponse(message="Gerät erfolgreich abgemeldet")


@router.get(
    "/devices",
    summary="List registered devices",
    description="List all registered push notification devices for current user.",
)
async def list_devices(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all registered devices for current user."""
    service = PushNotificationService(db)
    tokens = await service.get_user_tokens(current_user.id)

    return {
        "devices": [
            {
                "id": str(t.id),
                "platform": t.platform.value,
                "device_name": t.device_name,
                "app_version": t.app_version,
                "registered_at": t.created_at.isoformat(),
                "last_used_at": t.last_used_at.isoformat(),
            }
            for t in tokens
        ],
        "count": len(tokens),
    }


@router.get(
    "/status",
    summary="Firebase status (Admin only)",
    description="Check Firebase initialization status for debugging.",
)
async def get_push_status(
    current_user: User = Depends(get_current_user),
):
    """
    Get Firebase/FCM status for health monitoring.

    Admin-only endpoint for debugging push notification issues.

    Returns:
        initialized: Whether Firebase SDK is ready
        enabled: Whether credentials are configured
        error: Last initialization error (if any)
    """
    if current_user.role not in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )

    return get_firebase_status()
