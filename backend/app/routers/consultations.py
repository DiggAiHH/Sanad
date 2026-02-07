"""
Patient Consultation Router.

API endpoints for video calls, voice calls, and patient chat.

Security:
    - Authenticated users only.
    - Patients can only access their own consultations.
    - Doctors can access assigned consultations.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, require_roles
from app.models.models import User, UserRole
from app.models.patient_consultation import (
    ConsultationType,
    ConsultationStatus,
)
from app.schemas.consultation_schemas import (
    ConsultationRequestCreate,
    ConsultationSchedule,
    ConsultationStatusUpdate,
    ConsultationMessageCreate,
    ConsultationResponse,
    ConsultationPatientResponse,
    ConsultationStaffResponse,
    ConsultationListResponse,
    ConsultationStaffListResponse,
    ConsultationMessageResponse,
    ConsultationMessageListResponse,
    ConsultationEnd,
    ConsultationCancel,
    WebRTCRoomInfo,
    WebRTCOffer,
    WebRTCAnswer,
    WebRTCIceCandidate,
    WebRTCSignal,
    CallbackRequest,
    CallbackResponse,
)
from app.schemas.schemas import MessageResponse
from app.services.consultation_service import (
    create_consultation,
    schedule_consultation,
    start_consultation,
    end_consultation,
    get_consultation,
    get_patient_consultations,
    get_doctor_consultations,
    send_consultation_message,
    get_consultation_messages,
    mark_messages_read,
    get_unread_message_count,
    cancel_consultation,
)
from app.config import get_settings


router = APIRouter()

# In-memory signaling store (in production, use Redis or similar)
# Key: consultation_id, Value: list of signals
_webrtc_signals: dict[str, list[dict]] = {}


# =============================================================================
# Patient Endpoints
# =============================================================================


@router.post(
    "/request",
    response_model=ConsultationPatientResponse,
    status_code=status.HTTP_201_CREATED,
)
async def request_consultation(
    request_data: ConsultationRequestCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationPatientResponse:
    """
    Request a new consultation (video, voice, or chat).

    Args:
        request_data: Consultation request details.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        ConsultationPatientResponse: Created consultation.
    """
    # Get practice ID
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    consultation = await create_consultation(
        db=db,
        patient_id=current_user.id,
        practice_id=practice.id,
        request_data=request_data,
    )
    
    return ConsultationPatientResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        unread_messages=0,
    )


@router.get("/my-consultations", response_model=ConsultationListResponse)
async def list_my_consultations(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    status_filter: Annotated[
        Optional[list[ConsultationStatus]], Query(alias="status")
    ] = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
) -> ConsultationListResponse:
    """
    List my consultations.

    Args:
        db: Database session.
        current_user: Authenticated patient.
        status_filter: Optional status filter.
        page: Page number.
        page_size: Items per page.

    Returns:
        ConsultationListResponse: Paginated list.
    """
    consultations, total = await get_patient_consultations(
        db=db,
        patient_id=current_user.id,
        status_filter=status_filter,
        page=page,
        page_size=page_size,
    )
    
    items = []
    for c in consultations:
        unread = await get_unread_message_count(db, c.id, current_user.id)
        items.append(ConsultationPatientResponse(
            id=c.id,
            consultation_type=c.consultation_type,
            status=c.status,
            priority=c.priority,
            subject=c.subject,
            description=c.description,
            symptoms=c.symptoms,
            scheduled_at=c.scheduled_at,
            scheduled_duration_minutes=c.scheduled_duration_minutes,
            room_id=c.room_id,
            call_started_at=c.call_started_at,
            call_ended_at=c.call_ended_at,
            actual_duration_seconds=c.actual_duration_seconds,
            recording_consent=c.recording_consent,
            follow_up_required=c.follow_up_required,
            follow_up_notes=c.follow_up_notes,
            created_at=c.created_at,
            updated_at=c.updated_at,
            unread_messages=unread,
        ))
    
    return ConsultationListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/my-consultations/{consultation_id}", response_model=ConsultationPatientResponse)
async def get_my_consultation(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationPatientResponse:
    """
    Get a specific consultation.

    Args:
        consultation_id: Consultation ID.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        ConsultationPatientResponse: Consultation details.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    # Verify access
    if consultation.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    unread = await get_unread_message_count(db, consultation_id, current_user.id)
    
    return ConsultationPatientResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        unread_messages=unread,
    )


@router.post("/my-consultations/{consultation_id}/cancel", response_model=ConsultationPatientResponse)
async def cancel_my_consultation(
    consultation_id: uuid.UUID,
    cancel_data: ConsultationCancel,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationPatientResponse:
    """
    Cancel a consultation.

    Args:
        consultation_id: Consultation ID.
        cancel_data: Cancellation reason.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        ConsultationPatientResponse: Cancelled consultation.
    """
    # Verify ownership first
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if consultation.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    consultation = await cancel_consultation(
        db=db,
        consultation_id=consultation_id,
        cancelled_by_id=current_user.id,
        reason=cancel_data.reason,
    )
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Beratung kann nicht storniert werden",
        )
    
    return ConsultationPatientResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        unread_messages=0,
    )


# =============================================================================
# Messaging Endpoints
# =============================================================================


@router.get(
    "/{consultation_id}/messages",
    response_model=ConsultationMessageListResponse,
)
async def list_messages(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=50, ge=1, le=100),
) -> ConsultationMessageListResponse:
    """
    Get messages for a consultation.

    Args:
        consultation_id: Consultation ID.
        db: Database session.
        current_user: Authenticated user (patient or doctor).
        page: Page number.
        page_size: Items per page.

    Returns:
        ConsultationMessageListResponse: List of messages.
    """
    messages, total = await get_consultation_messages(
        db=db,
        consultation_id=consultation_id,
        user_id=current_user.id,
        page=page,
        page_size=page_size,
    )
    
    if not messages and total == 0:
        # Check if consultation exists and user has access
        consultation = await get_consultation(db, consultation_id)
        if not consultation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Beratung nicht gefunden",
            )
        if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Kein Zugriff auf diese Beratung",
            )
    
    return ConsultationMessageListResponse(
        items=[ConsultationMessageResponse.model_validate(m) for m in messages],
        total=total,
        has_more=total > page * page_size,
    )


@router.post(
    "/{consultation_id}/messages",
    response_model=ConsultationMessageResponse,
    status_code=status.HTTP_201_CREATED,
)
async def send_message(
    consultation_id: uuid.UUID,
    message_data: ConsultationMessageCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationMessageResponse:
    """
    Send a message in a consultation.

    Args:
        consultation_id: Consultation ID.
        message_data: Message content.
        db: Database session.
        current_user: Authenticated user (patient or doctor).

    Returns:
        ConsultationMessageResponse: Created message.
    """
    message = await send_consultation_message(
        db=db,
        consultation_id=consultation_id,
        sender_id=current_user.id,
        message_data=message_data,
    )
    
    if not message:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nachricht kann nicht gesendet werden",
        )
    
    return ConsultationMessageResponse.model_validate(message)


@router.post("/{consultation_id}/messages/read", response_model=MessageResponse)
async def mark_read(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Mark all messages as read.

    Args:
        consultation_id: Consultation ID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        MessageResponse: Success message.
    """
    count = await mark_messages_read(db, consultation_id, current_user.id)
    
    return MessageResponse(
        message=f"{count} Nachrichten als gelesen markiert",
        success=True,
    )


# =============================================================================
# WebRTC / Call Endpoints
# =============================================================================


@router.get("/{consultation_id}/room", response_model=WebRTCRoomInfo)
async def get_room_info(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> WebRTCRoomInfo:
    """
    Get WebRTC room information for joining a call.

    Args:
        consultation_id: Consultation ID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        WebRTCRoomInfo: Room and ICE server details.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    # Verify access
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    # Verify it's a call type
    if consultation.consultation_type not in [
        ConsultationType.VIDEO_CALL,
        ConsultationType.VOICE_CALL,
    ]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Keine Anruf-Beratung",
        )
    
    if not consultation.room_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Raum noch nicht erstellt",
        )
    
    # ICE servers configuration (EU-based managed provider)
    settings = get_settings()
    
    ice_servers = [
        {"urls": "stun:stun.l.google.com:19302"},
        {"urls": "stun:stun1.l.google.com:19302"},
    ]
    
    turn_servers = None
    if settings.TURN_SERVER_URL:
        turn_servers = [{
            "urls": settings.TURN_SERVER_URL,
            "username": settings.TURN_SERVER_USERNAME or "",
            "credential": settings.TURN_SERVER_CREDENTIAL or "",
        }]
    
    return WebRTCRoomInfo(
        room_id=consultation.room_id,
        consultation_id=consultation.id,
        ice_servers=ice_servers,
        turn_servers=turn_servers,
    )


# =============================================================================
# WebRTC Signaling Endpoints
# =============================================================================


@router.post("/{consultation_id}/signal/offer", response_model=MessageResponse)
async def send_offer(
    consultation_id: uuid.UUID,
    offer: WebRTCOffer,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Send WebRTC offer to peer.

    Security: Only consultation participants can send signals.
    DSGVO: No SDP content logged, only metadata.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    # Store signal for peer to retrieve
    room_key = str(consultation_id)
    if room_key not in _webrtc_signals:
        _webrtc_signals[room_key] = []
    
    from datetime import datetime, timezone
    _webrtc_signals[room_key].append({
        "signal_type": "offer",
        "payload": {"sdp": offer.sdp, "type": offer.type},
        "sender_id": str(current_user.id),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    
    return MessageResponse(message="Offer gesendet", success=True)


@router.post("/{consultation_id}/signal/answer", response_model=MessageResponse)
async def send_answer(
    consultation_id: uuid.UUID,
    answer: WebRTCAnswer,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Send WebRTC answer to peer.

    Security: Only consultation participants can send signals.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    room_key = str(consultation_id)
    if room_key not in _webrtc_signals:
        _webrtc_signals[room_key] = []
    
    from datetime import datetime, timezone
    _webrtc_signals[room_key].append({
        "signal_type": "answer",
        "payload": {"sdp": answer.sdp, "type": answer.type},
        "sender_id": str(current_user.id),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    
    return MessageResponse(message="Answer gesendet", success=True)


@router.post("/{consultation_id}/signal/ice", response_model=MessageResponse)
async def send_ice_candidate(
    consultation_id: uuid.UUID,
    candidate: WebRTCIceCandidate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Send ICE candidate to peer.

    Security: Only consultation participants can send signals.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    room_key = str(consultation_id)
    if room_key not in _webrtc_signals:
        _webrtc_signals[room_key] = []
    
    from datetime import datetime, timezone
    _webrtc_signals[room_key].append({
        "signal_type": "ice-candidate",
        "payload": {
            "candidate": candidate.candidate,
            "sdpMid": candidate.sdp_mid,
            "sdpMLineIndex": candidate.sdp_m_line_index,
        },
        "sender_id": str(current_user.id),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    })
    
    return MessageResponse(message="ICE Candidate gesendet", success=True)


@router.get("/{consultation_id}/signal/poll", response_model=list[WebRTCSignal])
async def poll_signals(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    since: Optional[str] = Query(None, description="ISO timestamp to filter signals"),
) -> list[WebRTCSignal]:
    """
    Poll for pending WebRTC signals from peer.

    Returns signals not sent by the current user.
    Security: Only consultation participants can poll.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    room_key = str(consultation_id)
    signals = _webrtc_signals.get(room_key, [])
    
    # Filter: only signals from the OTHER user
    from datetime import datetime
    result = []
    for sig in signals:
        if sig["sender_id"] != str(current_user.id):
            # Optional: filter by timestamp
            if since:
                sig_time = datetime.fromisoformat(sig["timestamp"].replace("Z", "+00:00"))
                since_time = datetime.fromisoformat(since.replace("Z", "+00:00"))
                if sig_time <= since_time:
                    continue
            result.append(WebRTCSignal(
                signal_type=sig["signal_type"],
                payload=sig["payload"],
                sender_id=uuid.UUID(sig["sender_id"]),
                timestamp=datetime.fromisoformat(sig["timestamp"].replace("Z", "+00:00")),
            ))
    
    return result


@router.delete("/{consultation_id}/signal", response_model=MessageResponse)
async def clear_signals(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Clear all WebRTC signals for a consultation room.

    Call this when ending a call to clean up.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    room_key = str(consultation_id)
    if room_key in _webrtc_signals:
        del _webrtc_signals[room_key]
    
    return MessageResponse(message="Signale gelöscht", success=True)


@router.post("/{consultation_id}/join", response_model=ConsultationPatientResponse)
async def join_call(
    consultation_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationPatientResponse:
    """
    Join a call (marks consultation as in progress).

    Args:
        consultation_id: Consultation ID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        ConsultationPatientResponse: Updated consultation.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    # Verify access
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    # Start if not already started
    if consultation.status in [ConsultationStatus.SCHEDULED, ConsultationStatus.WAITING]:
        consultation = await start_consultation(db, consultation_id, current_user.id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Anruf kann nicht gestartet werden",
        )
    
    unread = await get_unread_message_count(db, consultation_id, current_user.id)
    
    return ConsultationPatientResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        unread_messages=unread,
    )


@router.post("/{consultation_id}/end", response_model=ConsultationPatientResponse)
async def end_call(
    consultation_id: uuid.UUID,
    end_data: ConsultationEnd,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> ConsultationPatientResponse:
    """
    End a call.

    Args:
        consultation_id: Consultation ID.
        end_data: End data with optional rating.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        ConsultationPatientResponse: Ended consultation.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    # Verify access
    if current_user.id not in [consultation.patient_id, consultation.doctor_id]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Beratung",
        )
    
    consultation = await end_consultation(
        db=db,
        consultation_id=consultation_id,
        ended_by_id=current_user.id,
        patient_rating=end_data.patient_rating,
        follow_up_required=end_data.follow_up_required,
        follow_up_notes=end_data.follow_up_notes,
    )
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Anruf kann nicht beendet werden",
        )
    
    return ConsultationPatientResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        unread_messages=0,
    )


# =============================================================================
# Staff Endpoints
# =============================================================================


@router.get("/staff/all", response_model=ConsultationStaffListResponse)
async def list_all_consultations(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User,
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
    status_filter: Annotated[
        Optional[list[ConsultationStatus]], Query(alias="status")
    ] = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
) -> ConsultationStaffListResponse:
    """
    List all consultations (staff view).

    Args:
        db: Database session.
        current_user: Authenticated staff.
        status_filter: Optional status filter.
        page: Page number.
        page_size: Items per page.

    Returns:
        ConsultationStaffListResponse: Paginated list.
    """
    # For doctors, filter to their assigned consultations
    if current_user.role == UserRole.DOCTOR:
        consultations, total = await get_doctor_consultations(
            db=db,
            doctor_id=current_user.id,
            status_filter=status_filter,
            page=page,
            page_size=page_size,
        )
    else:
        # Admin/MFA see all consultations
        from sqlalchemy import select, func
        from app.models.patient_consultation import PatientConsultation
        
        query = select(PatientConsultation).order_by(
            PatientConsultation.created_at.desc()
        )
        
        if status_filter:
            query = query.where(PatientConsultation.status.in_(status_filter))
        
        count_query = select(func.count()).select_from(query.subquery())
        total = await db.scalar(count_query) or 0
        
        query = query.offset((page - 1) * page_size).limit(page_size)
        result = await db.execute(query)
        consultations = list(result.scalars().all())
    
    # Build response with patient info
    items = []
    for c in consultations:
        # Get patient info
        from sqlalchemy import select
        patient_result = await db.execute(
            select(User).where(User.id == c.patient_id)
        )
        patient = patient_result.scalar_one_or_none()
        patient_name = f"{patient.first_name} {patient.last_name}" if patient else "Unbekannt"
        patient_phone = patient.phone if patient else None
        
        # Get doctor info
        doctor_name = None
        if c.doctor_id:
            doctor_result = await db.execute(
                select(User).where(User.id == c.doctor_id)
            )
            doctor = doctor_result.scalar_one_or_none()
            doctor_name = f"Dr. {doctor.last_name}" if doctor else None
        
        items.append(ConsultationStaffResponse(
            id=c.id,
            consultation_type=c.consultation_type,
            status=c.status,
            priority=c.priority,
            subject=c.subject,
            description=c.description,
            symptoms=c.symptoms,
            scheduled_at=c.scheduled_at,
            scheduled_duration_minutes=c.scheduled_duration_minutes,
            room_id=c.room_id,
            call_started_at=c.call_started_at,
            call_ended_at=c.call_ended_at,
            actual_duration_seconds=c.actual_duration_seconds,
            recording_consent=c.recording_consent,
            follow_up_required=c.follow_up_required,
            follow_up_notes=c.follow_up_notes,
            created_at=c.created_at,
            updated_at=c.updated_at,
            patient_id=c.patient_id,
            patient_name=patient_name,
            patient_phone=patient_phone,
            doctor_id=c.doctor_id,
            doctor_name=doctor_name,
            ticket_id=c.ticket_id,
            connection_quality=c.connection_quality,
            patient_rating=c.patient_rating,
        ))
    
    return ConsultationStaffListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post("/staff/{consultation_id}/schedule", response_model=ConsultationStaffResponse)
async def schedule_consultation_staff(
    consultation_id: uuid.UUID,
    schedule_data: ConsultationSchedule,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User,
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
) -> ConsultationStaffResponse:
    """
    Schedule a consultation (assign doctor and time).

    Args:
        consultation_id: Consultation ID.
        schedule_data: Doctor ID and scheduled time.
        db: Database session.
        current_user: Authenticated staff.

    Returns:
        ConsultationStaffResponse: Scheduled consultation.
    """
    consultation = await schedule_consultation(
        db=db,
        consultation_id=consultation_id,
        schedule_data=schedule_data,
        scheduled_by_id=current_user.id,
    )
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Beratung nicht gefunden",
        )
    
    # Get patient info
    from sqlalchemy import select
    patient_result = await db.execute(
        select(User).where(User.id == consultation.patient_id)
    )
    patient = patient_result.scalar_one_or_none()
    patient_name = f"{patient.first_name} {patient.last_name}" if patient else "Unbekannt"
    
    return ConsultationStaffResponse(
        id=consultation.id,
        consultation_type=consultation.consultation_type,
        status=consultation.status,
        priority=consultation.priority,
        subject=consultation.subject,
        description=consultation.description,
        symptoms=consultation.symptoms,
        scheduled_at=consultation.scheduled_at,
        scheduled_duration_minutes=consultation.scheduled_duration_minutes,
        room_id=consultation.room_id,
        call_started_at=consultation.call_started_at,
        call_ended_at=consultation.call_ended_at,
        actual_duration_seconds=consultation.actual_duration_seconds,
        recording_consent=consultation.recording_consent,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        patient_id=consultation.patient_id,
        patient_name=patient_name,
        patient_phone=patient.phone if patient else None,
        doctor_id=consultation.doctor_id,
        doctor_name=None,  # Will be populated in response
        ticket_id=consultation.ticket_id,
        connection_quality=consultation.connection_quality,
        patient_rating=consultation.patient_rating,
    )
