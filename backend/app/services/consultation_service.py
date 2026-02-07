"""
Patient Consultation Service.

Business logic for video/voice calls and patient chat.

Security:
    - End-to-end encryption recommended for messages.
    - Recording only with explicit consent.
    - All sessions logged for compliance.
"""

import logging
import uuid
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional

from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.patient_consultation import (
    PatientConsultation,
    PatientConsultationMessage,
    ConsultationType,
    ConsultationStatus,
    ConsultationPriority,
)
from app.models.models import User, UserRole
from app.schemas.consultation_schemas import (
    ConsultationRequestCreate,
    ConsultationSchedule,
    ConsultationStatusUpdate,
    ConsultationMessageCreate,
)


logger = logging.getLogger(__name__)


def generate_room_id() -> str:
    """Generate a secure, unique room ID for WebRTC."""
    return f"sanad-{secrets.token_urlsafe(16)}"


async def create_consultation(
    db: AsyncSession,
    patient_id: uuid.UUID,
    practice_id: uuid.UUID,
    request_data: ConsultationRequestCreate,
) -> PatientConsultation:
    """
    Create a new consultation request.

    Args:
        db: Database session.
        patient_id: Patient's user ID.
        practice_id: Practice ID.
        request_data: Consultation request data.

    Returns:
        PatientConsultation: Created consultation.

    Security Implications:
        - Recording consent explicitly stored.
        - Auto-deletion scheduled per DSGVO.
    """
    # Generate room ID for video/voice calls
    room_id = None
    if request_data.consultation_type in [
        ConsultationType.VIDEO_CALL,
        ConsultationType.VOICE_CALL,
    ]:
        room_id = generate_room_id()
    
    # DSGVO: Schedule deletion (30 days for completed, 90 for active)
    deletion_date = datetime.now(timezone.utc) + timedelta(days=90)
    
    consultation = PatientConsultation(
        practice_id=practice_id,
        patient_id=patient_id,
        consultation_type=request_data.consultation_type,
        priority=request_data.priority,
        status=ConsultationStatus.REQUESTED,
        subject=request_data.subject,
        description=request_data.description,
        symptoms=request_data.symptoms,
        scheduled_at=request_data.preferred_date,
        scheduled_duration_minutes=request_data.preferred_duration_minutes,
        room_id=room_id,
        recording_consent=request_data.recording_consent,
        deletion_scheduled_at=deletion_date,
    )
    
    db.add(consultation)
    await db.commit()
    await db.refresh(consultation)
    
    logger.info(
        "Consultation created",
        extra={
            "consultation_id": str(consultation.id),
            "patient_id": str(patient_id),
            "type": request_data.consultation_type.value,
            "recording_consent": request_data.recording_consent,
        }
    )
    
    return consultation


async def schedule_consultation(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    schedule_data: ConsultationSchedule,
    scheduled_by_id: uuid.UUID,
) -> Optional[PatientConsultation]:
    """
    Schedule a consultation (staff action).

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        schedule_data: Schedule data with doctor and time.
        scheduled_by_id: Staff user ID.

    Returns:
        PatientConsultation or None.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return None
    
    consultation.doctor_id = schedule_data.doctor_id
    consultation.scheduled_at = schedule_data.scheduled_at
    consultation.scheduled_duration_minutes = schedule_data.scheduled_duration_minutes
    consultation.status = ConsultationStatus.SCHEDULED
    
    # Generate room ID if not exists
    if not consultation.room_id and consultation.consultation_type in [
        ConsultationType.VIDEO_CALL,
        ConsultationType.VOICE_CALL,
    ]:
        consultation.room_id = generate_room_id()
    
    await db.commit()
    await db.refresh(consultation)
    
    logger.info(
        "Consultation scheduled",
        extra={
            "consultation_id": str(consultation_id),
            "doctor_id": str(schedule_data.doctor_id),
            "scheduled_at": schedule_data.scheduled_at.isoformat(),
        }
    )
    
    return consultation


async def start_consultation(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    started_by_id: uuid.UUID,
) -> Optional[PatientConsultation]:
    """
    Start a consultation session (mark as IN_PROGRESS).

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        started_by_id: User ID starting the session.

    Returns:
        PatientConsultation or None.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return None
    
    if consultation.status not in [
        ConsultationStatus.SCHEDULED,
        ConsultationStatus.WAITING,
    ]:
        return None
    
    consultation.status = ConsultationStatus.IN_PROGRESS
    consultation.call_started_at = datetime.now(timezone.utc)
    
    await db.commit()
    await db.refresh(consultation)
    
    logger.info(
        "Consultation started",
        extra={
            "consultation_id": str(consultation_id),
            "started_by": str(started_by_id),
        }
    )
    
    return consultation


async def end_consultation(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    ended_by_id: uuid.UUID,
    patient_rating: Optional[int] = None,
    follow_up_required: bool = False,
    follow_up_notes: Optional[str] = None,
) -> Optional[PatientConsultation]:
    """
    End a consultation session.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        ended_by_id: User ID ending the session.
        patient_rating: Optional 1-5 rating.
        follow_up_required: Whether follow-up is needed.
        follow_up_notes: Follow-up notes.

    Returns:
        PatientConsultation or None.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return None
    
    if consultation.status != ConsultationStatus.IN_PROGRESS:
        return None
    
    now = datetime.now(timezone.utc)
    consultation.status = ConsultationStatus.COMPLETED
    consultation.call_ended_at = now
    
    # Calculate duration
    if consultation.call_started_at:
        duration = (now - consultation.call_started_at).total_seconds()
        consultation.actual_duration_seconds = int(duration)
    
    consultation.patient_rating = patient_rating
    consultation.follow_up_required = follow_up_required
    consultation.follow_up_notes = follow_up_notes
    
    # Update DSGVO deletion (shorter for completed)
    consultation.deletion_scheduled_at = now + timedelta(days=30)
    
    await db.commit()
    await db.refresh(consultation)
    
    logger.info(
        "Consultation ended",
        extra={
            "consultation_id": str(consultation_id),
            "ended_by": str(ended_by_id),
            "duration_seconds": consultation.actual_duration_seconds,
            "rating": patient_rating,
        }
    )
    
    return consultation


async def get_consultation(
    db: AsyncSession,
    consultation_id: uuid.UUID,
) -> Optional[PatientConsultation]:
    """
    Get a single consultation by ID.

    Args:
        db: Database session.
        consultation_id: Consultation ID.

    Returns:
        PatientConsultation or None.
    """
    query = select(PatientConsultation).where(
        PatientConsultation.id == consultation_id
    ).options(
        selectinload(PatientConsultation.messages)
    )
    result = await db.execute(query)
    return result.scalar_one_or_none()


async def get_patient_consultations(
    db: AsyncSession,
    patient_id: uuid.UUID,
    status_filter: Optional[list[ConsultationStatus]] = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[PatientConsultation], int]:
    """
    Get all consultations for a patient.

    Args:
        db: Database session.
        patient_id: Patient's user ID.
        status_filter: Optional status filter.
        page: Page number (1-based).
        page_size: Items per page.

    Returns:
        tuple: (list of consultations, total count)
    """
    query = select(PatientConsultation).where(
        PatientConsultation.patient_id == patient_id
    ).order_by(PatientConsultation.created_at.desc())
    
    if status_filter:
        query = query.where(PatientConsultation.status.in_(status_filter))
    
    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.scalar(count_query) or 0
    
    # Paginate
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    consultations = result.scalars().all()
    
    return list(consultations), total


async def get_doctor_consultations(
    db: AsyncSession,
    doctor_id: uuid.UUID,
    status_filter: Optional[list[ConsultationStatus]] = None,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[PatientConsultation], int]:
    """
    Get all consultations for a doctor.

    Args:
        db: Database session.
        doctor_id: Doctor's user ID.
        status_filter: Optional status filter.
        date_from: Start date filter.
        date_to: End date filter.
        page: Page number (1-based).
        page_size: Items per page.

    Returns:
        tuple: (list of consultations, total count)
    """
    query = select(PatientConsultation).where(
        PatientConsultation.doctor_id == doctor_id
    ).order_by(PatientConsultation.scheduled_at.asc())
    
    if status_filter:
        query = query.where(PatientConsultation.status.in_(status_filter))
    
    if date_from:
        query = query.where(PatientConsultation.scheduled_at >= date_from)
    
    if date_to:
        query = query.where(PatientConsultation.scheduled_at <= date_to)
    
    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.scalar(count_query) or 0
    
    # Paginate
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    consultations = result.scalars().all()
    
    return list(consultations), total


async def send_consultation_message(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    sender_id: uuid.UUID,
    message_data: ConsultationMessageCreate,
) -> Optional[PatientConsultationMessage]:
    """
    Send a message in a consultation chat.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        sender_id: Sender's user ID.
        message_data: Message content.

    Returns:
        PatientConsultationMessage or None.

    Security Implications:
        - Only participants can send messages.
        - Content should be encrypted at rest.
    """
    # Verify consultation exists and sender is participant
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return None
    
    # Check sender is participant (patient or doctor)
    if sender_id not in [consultation.patient_id, consultation.doctor_id]:
        logger.warning(
            "Unauthorized message attempt",
            extra={
                "consultation_id": str(consultation_id),
                "sender_id": str(sender_id),
            }
        )
        return None
    
    message = PatientConsultationMessage(
        consultation_id=consultation_id,
        sender_id=sender_id,
        content=message_data.content,
        attachment_url=message_data.attachment_url,
        attachment_type=message_data.attachment_type,
    )
    
    db.add(message)
    
    # Update consultation status if needed
    if consultation.status == ConsultationStatus.REQUESTED:
        consultation.status = ConsultationStatus.IN_PROGRESS
    
    await db.commit()
    await db.refresh(message)
    
    logger.info(
        "Consultation message sent",
        extra={
            "consultation_id": str(consultation_id),
            "sender_id": str(sender_id),
            "has_attachment": bool(message_data.attachment_url),
        }
    )
    
    return message


async def get_consultation_messages(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    user_id: uuid.UUID,
    page: int = 1,
    page_size: int = 50,
) -> tuple[list[PatientConsultationMessage], int]:
    """
    Get messages for a consultation.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        user_id: Requesting user's ID (for authorization).
        page: Page number (1-based).
        page_size: Items per page.

    Returns:
        tuple: (list of messages, total count)
    """
    # Verify user is participant
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return [], 0
    
    if user_id not in [consultation.patient_id, consultation.doctor_id]:
        return [], 0
    
    query = select(PatientConsultationMessage).where(
        PatientConsultationMessage.consultation_id == consultation_id
    ).order_by(PatientConsultationMessage.created_at.asc())
    
    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.scalar(count_query) or 0
    
    # Paginate (from end for chat)
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    messages = result.scalars().all()
    
    return list(messages), total


async def mark_messages_read(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    user_id: uuid.UUID,
) -> int:
    """
    Mark all messages as read for a user.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        user_id: User marking messages as read.

    Returns:
        int: Number of messages marked as read.
    """
    # Get unread messages not sent by this user
    query = select(PatientConsultationMessage).where(
        and_(
            PatientConsultationMessage.consultation_id == consultation_id,
            PatientConsultationMessage.sender_id != user_id,
            PatientConsultationMessage.is_read == False,
        )
    )
    
    result = await db.execute(query)
    messages = result.scalars().all()
    
    now = datetime.now(timezone.utc)
    for msg in messages:
        msg.is_read = True
        msg.read_at = now
    
    await db.commit()
    
    return len(messages)


async def get_unread_message_count(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    user_id: uuid.UUID,
) -> int:
    """
    Get count of unread messages for a user in a consultation.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        user_id: User to check unread for.

    Returns:
        int: Number of unread messages.
    """
    query = select(func.count()).where(
        and_(
            PatientConsultationMessage.consultation_id == consultation_id,
            PatientConsultationMessage.sender_id != user_id,
            PatientConsultationMessage.is_read == False,
        )
    )
    
    return await db.scalar(query) or 0


async def cancel_consultation(
    db: AsyncSession,
    consultation_id: uuid.UUID,
    cancelled_by_id: uuid.UUID,
    reason: Optional[str] = None,
) -> Optional[PatientConsultation]:
    """
    Cancel a consultation.

    Args:
        db: Database session.
        consultation_id: Consultation ID.
        cancelled_by_id: User cancelling.
        reason: Cancellation reason.

    Returns:
        PatientConsultation or None.
    """
    consultation = await get_consultation(db, consultation_id)
    
    if not consultation:
        return None
    
    # Can only cancel if not already completed
    if consultation.status in [
        ConsultationStatus.COMPLETED,
        ConsultationStatus.CANCELLED,
    ]:
        return None
    
    consultation.status = ConsultationStatus.CANCELLED
    
    if reason:
        consultation.follow_up_notes = f"Storniert: {reason}"
    
    await db.commit()
    await db.refresh(consultation)
    
    logger.info(
        "Consultation cancelled",
        extra={
            "consultation_id": str(consultation_id),
            "cancelled_by": str(cancelled_by_id),
        }
    )
    
    return consultation
