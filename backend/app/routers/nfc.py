"""
NFC API Router for Zero-Touch Reception.

Endpoints for:
    - NFC-based patient check-in.
    - NFC card registration and management.
    - Card lookup and deactivation.

Security:
    - Device authentication via device_secret (bcrypt hash verification).
    - Patient data is masked (first name only).
    - All UIDs are encrypted at rest.
"""

import logging
from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from passlib.context import CryptContext
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import (
    CheckInEvent,
    CheckInMethod,
    DeviceStatus,
    IoTDevice,
    PatientNFCCard,
    Queue,
    Ticket,
    TicketPriority,
    TicketStatus,
    User,
    UserRole,
    WayfindingRoute,
)
from app.schemas.schemas import (
    CheckInEventListResponse,
    CheckInEventResponse,
    ErrorResponse,
    MessageResponse,
    NFCCardListResponse,
    NFCCardRegisterRequest,
    NFCCardResponse,
    NFCCheckInRequest,
    NFCCheckInResponse,
)
from app.services.nfc_service import NFCService
from app.services.led_service import LEDService
from app.services.push_service import notify_check_in_success, notify_mfa_new_ticket

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/nfc", tags=["NFC"])

# Password context for device secret verification (bcrypt)
_device_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _verify_device_secret(plain_secret: str, hashed_secret: str) -> bool:
    """
    Verify device secret against stored hash.

    Args:
        plain_secret: Plain text secret from request.
        hashed_secret: bcrypt hash stored in DB.

    Returns:
        True if secret matches.
    """
    try:
        return _device_pwd_ctx.verify(plain_secret, hashed_secret)
    except Exception:
        return False


# ============================================================================
# NFC Check-In Endpoints
# ============================================================================


@router.post(
    "/check-in",
    response_model=NFCCheckInResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Device authentication failed"},
        404: {"model": ErrorResponse, "description": "Card not registered"},
    },
    summary="Automatischer NFC-Check-In",
    description="Wird von ESP32-NFC-Readern aufgerufen. Erstellt automatisch ein Ticket.",
)
async def nfc_check_in(
    request: NFCCheckInRequest,
    db: AsyncSession = Depends(get_db),
) -> NFCCheckInResponse:
    """
    Process NFC card scan and auto-create ticket.

    Called by ESP32 NFC readers when a patient taps their card.

    Flow:
        1. Verify device authentication.
        2. Look up card in database.
        3. Check if patient has appointment today.
        4. Create ticket in appropriate queue.
        5. Trigger wayfinding LED route.

    Args:
        request: NFC check-in request with UID and device credentials.
        db: Database session.

    Returns:
        Check-in response with ticket info and wayfinding route.
    """
    # 1. Verify device
    device_result = await db.execute(
        select(IoTDevice).where(IoTDevice.id == request.device_id)
    )
    device = device_result.scalar_one_or_none()

    if not device:
        logger.warning(
            "Unknown device attempted check-in",
            extra={"device_id": str(request.device_id)},
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültiges Gerät"
        )

    # Verify device secret (bcrypt hash comparison)
    if not _verify_device_secret(request.device_secret, device.device_secret_hash):
        logger.warning(
            "Device secret mismatch", extra={"device_id": str(request.device_id)}
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültiges Gerät"
        )

    if not device.is_active or device.status != DeviceStatus.ONLINE:
        logger.warning(
            "Inactive device attempted check-in",
            extra={"device_id": str(request.device_id)},
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültiges Gerät"
        )

    # 2. Look up card
    try:
        nfc_service = NFCService(db)
    except ValueError as e:
        logger.error("NFC service init failed", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="NFC service configuration error",
        )

    card = await nfc_service.lookup_card(request.nfc_uid)

    if not card:
        logger.info(
            "Unknown NFC card scanned", extra={"device_id": str(request.device_id)}
        )
        return NFCCheckInResponse(
            success=False,
            message="Karte nicht registriert. Bitte wenden Sie sich an die Rezeption.",
        )

    if card.expires_at:
        expires_at = card.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=timezone.utc)
        if expires_at < datetime.now(timezone.utc):
            return NFCCheckInResponse(
                success=False,
                message="Karte abgelaufen. Bitte wenden Sie sich an die Rezeption.",
            )

    # 3. Get patient info
    patient_result = await db.execute(select(User).where(User.id == card.patient_id))
    patient = patient_result.scalar_one_or_none()

    if not patient or not patient.is_active:
        return NFCCheckInResponse(
            success=False,
            message="Patient nicht gefunden oder inaktiv.",
        )

    # 4. Get default queue for practice
    queue_result = await db.execute(
        select(Queue)
        .where(Queue.practice_id == device.practice_id)
        .where(Queue.is_active.is_(True))
        .order_by(Queue.created_at)
        .limit(1)
    )
    queue = queue_result.scalar_one_or_none()

    if not queue:
        logger.error(
            "No active queue found", extra={"practice_id": str(device.practice_id)}
        )
        return NFCCheckInResponse(
            success=False,
            message="Keine aktive Warteschlange verfügbar.",
        )

    # 5. Check for existing ticket today
    today_start = datetime.now(timezone.utc).replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    existing_ticket_result = await db.execute(
        select(Ticket)
        .where(Ticket.queue_id == queue.id)
        .where(Ticket.patient_name == f"{patient.first_name} {patient.last_name}")
        .where(Ticket.created_at >= today_start)
        .where(Ticket.status.in_([TicketStatus.WAITING, TicketStatus.CALLED]))
    )
    existing_ticket = existing_ticket_result.scalar_one_or_none()

    if existing_ticket:
        return NFCCheckInResponse(
            success=True,
            ticket_number=existing_ticket.ticket_number,
            queue_name=queue.name,
            estimated_wait_minutes=existing_ticket.estimated_wait_minutes,
            patient_name=patient.first_name,
            message=f"Sie sind bereits angemeldet. Ihre Nummer: {existing_ticket.ticket_number}",
        )

    # 6. Create new ticket
    # Get next ticket number
    queue.current_number += 1
    ticket_number = f"{queue.code}{queue.current_number:03d}"

    # Calculate estimated wait time from queue stats
    waiting_count_result = await db.execute(
        select(func.count(Ticket.id))
        .where(Ticket.queue_id == queue.id)
        .where(Ticket.status == TicketStatus.WAITING)
    )
    waiting_count = waiting_count_result.scalar() or 0
    estimated_wait = max(queue.average_wait_minutes * waiting_count, 5)

    ticket = Ticket(
        queue_id=queue.id,
        patient_name=f"{patient.first_name} {patient.last_name}",
        ticket_number=ticket_number,
        status=TicketStatus.WAITING,
        priority=TicketPriority.NORMAL,
        estimated_wait_minutes=estimated_wait,
    )

    db.add(ticket)

    # 7. Create check-in event
    check_in_event = CheckInEvent(
        practice_id=device.practice_id,
        ticket_id=ticket.id,
        device_id=device.id,
        nfc_card_id=card.id,
        check_in_method=CheckInMethod.NFC,
        patient_id=patient.id,
        success=True,
        checked_in_at=datetime.now(timezone.utc),
    )
    db.add(check_in_event)

    # Update card last_used_at
    card.last_used_at = datetime.now(timezone.utc)

    await db.commit()

    logger.info(
        "NFC check-in successful",
        extra={
            "patient_id": str(patient.id),
            "ticket_number": ticket_number,
            "queue": queue.code,
        },
    )

    # 8. Trigger wayfinding (if route configured for queue zone)
    wayfinding_route_id: Optional[UUID] = None
    if queue.zone_id:
        route_result = await db.execute(
            select(WayfindingRoute)
            .where(WayfindingRoute.to_zone_id == queue.zone_id)
            .where(WayfindingRoute.is_active.is_(True))
            .limit(1)
        )
        route = route_result.scalar_one_or_none()
        if route:
            wayfinding_route_id = route.id
            try:
                led_service = LEDService(db)
                await led_service.activate_wayfinding_route(route.id)
            except Exception as e:
                logger.warning("Wayfinding activation failed", extra={"error": str(e)})

    # 9. Send push notifications (async, don't block response)
    try:
        # Notify patient of successful check-in
        await notify_check_in_success(
            db=db,
            patient_user_id=patient.id,
            ticket_number=ticket_number,
            queue_name=queue.name,
            estimated_wait_minutes=ticket.estimated_wait_minutes,
        )

        # Notify MFA staff about new ticket
        mfa_users_result = await db.execute(
            select(User.id).where(
                User.role == UserRole.MFA,
                User.is_active.is_(True),
            )
        )
        mfa_user_ids = [row[0] for row in mfa_users_result.fetchall()]
        if mfa_user_ids:
            await notify_mfa_new_ticket(
                db=db,
                mfa_user_ids=mfa_user_ids,
                ticket_number=ticket_number,
                queue_name=queue.name,
            )
    except Exception as e:
        logger.warning("Push notification failed", extra={"error": str(e)})

    return NFCCheckInResponse(
        success=True,
        ticket_number=ticket_number,
        queue_name=queue.name,
        estimated_wait_minutes=ticket.estimated_wait_minutes,
        patient_name=patient.first_name,
        wayfinding_route_id=wayfinding_route_id,
        message=f"Willkommen, {patient.first_name}! Bitte nehmen Sie im Wartebereich Platz.",
    )


# ============================================================================
# NFC Card Management Endpoints
# ============================================================================


@router.post(
    "/cards/register",
    response_model=NFCCardResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Card already registered"},
        403: {"model": ErrorResponse, "description": "Insufficient permissions"},
    },
    summary="NFC-Karte registrieren",
)
async def register_nfc_card(
    request: NFCCardRegisterRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> NFCCardResponse:
    """
    Register a new NFC card for a patient.

    Requires MFA or Admin role.

    Args:
        request: Card registration data.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        Created card info.

    Raises:
        HTTPException: If card already registered or insufficient permissions.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA, UserRole.DOCTOR]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur MFA oder Admin können Karten registrieren",
        )

    try:
        nfc_service = NFCService(db)
        card = await nfc_service.register_card(
            patient_id=request.patient_id,
            nfc_uid=request.nfc_uid,
            card_type=request.card_type,
            card_label=request.card_label,
            expires_at=request.expires_at,
        )
        return NFCCardResponse.model_validate(card)

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/cards/patient/{patient_id}",
    response_model=NFCCardListResponse,
    summary="NFC-Karten eines Patienten abrufen",
)
async def get_patient_cards(
    patient_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> NFCCardListResponse:
    """
    Get all NFC cards registered for a patient.

    Args:
        patient_id: Patient UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        List of registered cards.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA, UserRole.DOCTOR]:
        if current_user.id != patient_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Zugriff verweigert"
            )

    result = await db.execute(
        select(PatientNFCCard)
        .where(PatientNFCCard.patient_id == patient_id)
        .order_by(PatientNFCCard.created_at.desc())
    )
    cards = list(result.scalars().all())

    return NFCCardListResponse(
        items=[NFCCardResponse.model_validate(c) for c in cards], total=len(cards)
    )


@router.delete(
    "/cards/{card_id}",
    response_model=MessageResponse,
    summary="NFC-Karte deaktivieren",
)
async def deactivate_card(
    card_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> MessageResponse:
    """
    Deactivate an NFC card (soft delete).

    Args:
        card_id: Card UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        Success message.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur MFA oder Admin können Karten deaktivieren",
        )

    result = await db.execute(
        select(PatientNFCCard).where(PatientNFCCard.id == card_id)
    )
    card = result.scalar_one_or_none()

    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Karte nicht gefunden"
        )

    card.is_active = False
    await db.commit()

    logger.info(
        "NFC card deactivated",
        extra={"card_id": str(card_id), "by_user": str(current_user.id)},
    )

    return MessageResponse(message="Karte erfolgreich deaktiviert")


# ============================================================================
# Check-In Event History
# ============================================================================


@router.get(
    "/check-ins",
    response_model=CheckInEventListResponse,
    summary="Check-In-Verlauf abrufen",
)
async def get_check_in_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    method: Optional[CheckInMethod] = Query(
        None, description="Filter by check-in method"
    ),
) -> CheckInEventListResponse:
    """
    Get recent check-in events.

    Args:
        db: Database session.
        current_user: Authenticated user.
        limit: Max results.
        offset: Pagination offset.
        method: Optional filter by method.

    Returns:
        List of check-in events.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA, UserRole.DOCTOR]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Zugriff verweigert"
        )

    query = select(CheckInEvent).order_by(CheckInEvent.checked_in_at.desc())

    if method:
        query = query.where(CheckInEvent.check_in_method == method)

    query = query.limit(limit).offset(offset)

    result = await db.execute(query)
    events = list(result.scalars().all())

    # Get ticket info for each event
    response_items = []
    for event in events:
        ticket_result = await db.execute(
            select(Ticket).where(Ticket.id == event.ticket_id)
        )
        ticket = ticket_result.scalar_one_or_none()

        patient_name = None
        if ticket and ticket.patient_id:
            patient_result = await db.execute(
                select(User).where(User.id == ticket.patient_id)
            )
            patient = patient_result.scalar_one_or_none()
            if patient:
                patient_name = patient.first_name

        response_items.append(
            CheckInEventResponse(
                id=event.id,
                ticket_id=event.ticket_id,
                ticket_number=ticket.ticket_number if ticket else "N/A",
                check_in_method=event.check_in_method,
                device_id=event.nfc_device_id,
                patient_name=patient_name,
                checked_in_at=event.checked_in_at,
                assigned_room=ticket.assigned_room if ticket else None,
            )
        )

    # Count total
    count_query = select(CheckInEvent)
    if method:
        count_query = count_query.where(CheckInEvent.check_in_method == method)
    count_result = await db.execute(count_query)
    total = len(list(count_result.scalars().all()))

    return CheckInEventListResponse(items=response_items, total=total)
