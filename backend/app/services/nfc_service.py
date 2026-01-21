"""
NFC Service for patient check-in and card management.

Handles:
    - NFC card registration and lookup.
    - Automatic check-in when card is scanned.
    - UID encryption/hashing for GDPR compliance.

Security:
    - NFC UIDs are stored encrypted (AES-256-GCM).
    - SHA-256 hash is used for fast lookup without decryption.
    - Card secrets are never logged.
"""

import hashlib
import logging
import os
import secrets
from base64 import b64decode, b64encode
from datetime import datetime
from typing import Optional
from uuid import UUID

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import (
    CheckInEvent,
    CheckInMethod,
    IoTDevice,
    NFCCardType,
    PatientNFCCard,
    Queue,
    Ticket,
    TicketPriority,
    TicketStatus,
    User,
    WayfindingRoute,
    Zone,
)
from app.services.mqtt_service import get_mqtt_service

logger = logging.getLogger(__name__)


class NFCService:
    """
    Service for NFC card operations and automated check-in.
    
    Security:
        - All UIDs encrypted at rest.
        - Fail-fast on missing encryption key.
    """
    
    def __init__(self, db: AsyncSession) -> None:
        """
        Initialize NFC service.
        
        Args:
            db: Async database session.
        
        Raises:
            ValueError: If NFC_ENCRYPTION_KEY not set.
        """
        self._db = db
        # MANDATORY: Encryption key must be set in environment
        key_b64 = os.environ.get("NFC_ENCRYPTION_KEY")
        if not key_b64:
            raise ValueError(
                "NFC_ENCRYPTION_KEY environment variable is required. "
                "Generate with: python -c 'import secrets; import base64; print(base64.b64encode(secrets.token_bytes(32)).decode())'"
            )
        self._encryption_key = b64decode(key_b64)
        if len(self._encryption_key) != 32:
            raise ValueError("NFC_ENCRYPTION_KEY must be 32 bytes (256-bit)")
    
    def _hash_uid(self, nfc_uid: str) -> str:
        """
        Create SHA-256 hash of NFC UID for lookup.
        
        Args:
            nfc_uid: Raw NFC UID string (e.g., "04:A3:5B:1A:7C:8D:90").
        
        Returns:
            Hex-encoded SHA-256 hash.
        """
        normalized = nfc_uid.upper().replace(":", "").replace(" ", "")
        return hashlib.sha256(normalized.encode()).hexdigest()
    
    def _encrypt_uid(self, nfc_uid: str) -> str:
        """
        Encrypt NFC UID with AES-256-GCM.
        
        Args:
            nfc_uid: Raw NFC UID string.
        
        Returns:
            Base64-encoded ciphertext (nonce + ciphertext + tag).
        """
        normalized = nfc_uid.upper().replace(":", "").replace(" ", "")
        aesgcm = AESGCM(self._encryption_key)
        nonce = secrets.token_bytes(12)  # 96-bit nonce for GCM
        ciphertext = aesgcm.encrypt(nonce, normalized.encode(), None)
        return b64encode(nonce + ciphertext).decode()
    
    def _decrypt_uid(self, encrypted: str) -> str:
        """
        Decrypt NFC UID.
        
        Args:
            encrypted: Base64-encoded ciphertext.
        
        Returns:
            Original NFC UID.
        
        Raises:
            ValueError: If decryption fails.
        """
        try:
            data = b64decode(encrypted)
            nonce = data[:12]
            ciphertext = data[12:]
            aesgcm = AESGCM(self._encryption_key)
            plaintext = aesgcm.decrypt(nonce, ciphertext, None)
            return plaintext.decode()
        except Exception as e:
            raise ValueError(f"Decryption failed: {e}") from e
    
    async def register_card(
        self,
        patient_id: UUID,
        nfc_uid: str,
        card_type: NFCCardType,
        card_label: Optional[str] = None,
        expires_at: Optional[datetime] = None,
    ) -> PatientNFCCard:
        """
        Register a new NFC card for a patient.
        
        Args:
            patient_id: Patient user UUID.
            nfc_uid: Raw NFC UID from reader.
            card_type: Type of card (eGK, custom, etc.).
            card_label: Optional label (e.g., "Hauptkarte").
            expires_at: Optional expiration date.
        
        Returns:
            Created PatientNFCCard.
        
        Raises:
            ValueError: If card already registered.
        """
        uid_hash = self._hash_uid(nfc_uid)
        
        # Check if card already exists
        existing = await self._db.execute(
            select(PatientNFCCard).where(PatientNFCCard.nfc_uid_hash == uid_hash)
        )
        if existing.scalar_one_or_none():
            raise ValueError("NFC card already registered")
        
        card = PatientNFCCard(
            patient_id=patient_id,
            nfc_uid_encrypted=self._encrypt_uid(nfc_uid),
            nfc_uid_hash=uid_hash,
            card_type=card_type,
            card_label=card_label,
            expires_at=expires_at,
        )
        
        self._db.add(card)
        await self._db.commit()
        await self._db.refresh(card)
        
        logger.info(
            "NFC card registered",
            extra={"patient_id": str(patient_id), "card_type": card_type.value}
        )
        return card
    
    async def lookup_card(self, nfc_uid: str) -> Optional[PatientNFCCard]:
        """
        Find patient by NFC UID.
        
        Args:
            nfc_uid: Raw NFC UID from reader.
        
        Returns:
            PatientNFCCard if found and active, None otherwise.
        """
        uid_hash = self._hash_uid(nfc_uid)
        
        result = await self._db.execute(
            select(PatientNFCCard)
            .where(PatientNFCCard.nfc_uid_hash == uid_hash)
            .where(PatientNFCCard.is_active == True)
        )
        card = result.scalar_one_or_none()
        
        if card:
            # Check expiration
            if card.expires_at and card.expires_at < datetime.utcnow():
                logger.warning("Expired NFC card used", extra={"card_id": str(card.id)})
                return None
            
            # Update last used
            card.last_used_at = datetime.utcnow()
            await self._db.commit()
        
        return card
    
    async def process_check_in(
        self,
        practice_id: UUID,
        nfc_uid: str,
        device_id: Optional[UUID] = None,
        queue_id: Optional[UUID] = None,
    ) -> tuple[CheckInEvent, Optional[Ticket], Optional[WayfindingRoute]]:
        """
        Process automated NFC check-in.
        
        Flow:
            1. Lookup card -> Get patient.
            2. Check for existing appointment/ticket.
            3. Create ticket if none exists.
            4. Find wayfinding route to assigned room.
            5. Trigger LED wayfinding.
            6. Log check-in event.
        
        Args:
            practice_id: Practice UUID.
            nfc_uid: Raw NFC UID from reader.
            device_id: Optional NFC reader device ID.
            queue_id: Optional queue to assign ticket to.
        
        Returns:
            Tuple of (CheckInEvent, Ticket or None, WayfindingRoute or None).
        """
        uid_hash = self._hash_uid(nfc_uid)
        
        # Step 1: Lookup card
        card = await self.lookup_card(nfc_uid)
        patient_id = card.patient_id if card else None
        
        # Step 2: Check for existing waiting ticket
        ticket = None
        if patient_id:
            result = await self._db.execute(
                select(Ticket)
                .join(Queue)
                .where(Queue.practice_id == practice_id)
                .where(Ticket.status == TicketStatus.WAITING)
                .where(Ticket.created_by_id == patient_id)
                .order_by(Ticket.created_at.desc())
            )
            ticket = result.scalar_one_or_none()
        
        # Step 3: Create ticket if needed
        if not ticket and queue_id:
            # Get queue
            queue_result = await self._db.execute(
                select(Queue).where(Queue.id == queue_id)
            )
            queue = queue_result.scalar_one_or_none()
            
            if queue:
                queue.current_number += 1
                ticket_number = f"{queue.code}-{queue.current_number:03d}"
                
                ticket = Ticket(
                    queue_id=queue_id,
                    ticket_number=ticket_number,
                    status=TicketStatus.WAITING,
                    priority=TicketPriority.NORMAL,
                    estimated_wait_minutes=queue.average_wait_minutes,
                    created_by_id=patient_id,
                )
                self._db.add(ticket)
        
        # Step 4: Find wayfinding route
        route: Optional[WayfindingRoute] = None
        assigned_room: Optional[str] = None
        
        if ticket:
            # For now, find first available route from entrance
            entrance_result = await self._db.execute(
                select(Zone)
                .where(Zone.practice_id == practice_id)
                .where(Zone.zone_type == "entrance")
                .limit(1)
            )
            entrance = entrance_result.scalar_one_or_none()
            
            if entrance:
                route_result = await self._db.execute(
                    select(WayfindingRoute)
                    .where(WayfindingRoute.practice_id == practice_id)
                    .where(WayfindingRoute.from_zone_id == entrance.id)
                    .where(WayfindingRoute.is_active == True)
                    .limit(1)
                )
                route = route_result.scalar_one_or_none()
                
                if route:
                    # Get destination zone name
                    dest_result = await self._db.execute(
                        select(Zone).where(Zone.id == route.to_zone_id)
                    )
                    dest_zone = dest_result.scalar_one_or_none()
                    assigned_room = dest_zone.name if dest_zone else None
        
        # Step 5: Trigger LED wayfinding via MQTT
        if route:
            try:
                mqtt = get_mqtt_service()
                if mqtt.is_connected:
                    # Parse LED segment IDs from JSON array
                    segment_ids = []
                    if route.led_segment_ids:
                        try:
                            import json
                            segment_ids = json.loads(route.led_segment_ids)
                        except (json.JSONDecodeError, TypeError):
                            logger.warning(
                                "Invalid led_segment_ids JSON",
                                extra={"route_id": str(route.id)}
                            )
                    
                    await mqtt.publish_wayfinding_route(
                        practice_id=practice_id,
                        route_name=route.name,
                        segments=segment_ids,
                        color=route.led_color,
                        pattern=route.led_pattern.value,
                        duration_seconds=route.duration_seconds,
                    )
            except Exception as e:
                logger.warning("Failed to trigger wayfinding", extra={"error": str(e)})
        
        # Step 6: Log check-in event
        event = CheckInEvent(
            practice_id=practice_id,
            ticket_id=ticket.id if ticket else None,
            device_id=device_id,
            nfc_card_id=card.id if card else None,
            check_in_method=CheckInMethod.NFC,
            patient_id=patient_id,
            raw_nfc_uid_hash=uid_hash if not card else None,
            success=True,
            assigned_room=assigned_room,
            wayfinding_route_id=route.id if route else None,
        )
        self._db.add(event)
        
        await self._db.commit()
        if ticket:
            await self._db.refresh(ticket)
        await self._db.refresh(event)
        
        # Publish event for real-time updates
        try:
            mqtt = get_mqtt_service()
            if mqtt.is_connected:
                await mqtt.publish_event(
                    practice_id=practice_id,
                    event_type="check_in",
                    data={
                        "ticket_number": ticket.ticket_number if ticket else None,
                        "assigned_room": assigned_room,
                        "method": "nfc",
                    },
                )
        except Exception:
            pass  # Non-critical
        
        logger.info(
            "NFC check-in processed",
            extra={
                "practice_id": str(practice_id),
                "ticket": ticket.ticket_number if ticket else None,
                "route": route.name if route else None,
            }
        )
        
        return event, ticket, route
    
    async def deactivate_card(self, card_id: UUID) -> bool:
        """
        Deactivate an NFC card.
        
        Args:
            card_id: Card UUID.
        
        Returns:
            True if deactivated, False if not found.
        """
        result = await self._db.execute(
            select(PatientNFCCard).where(PatientNFCCard.id == card_id)
        )
        card = result.scalar_one_or_none()
        
        if not card:
            return False
        
        card.is_active = False
        await self._db.commit()
        
        logger.info("NFC card deactivated", extra={"card_id": str(card_id)})
        return True
