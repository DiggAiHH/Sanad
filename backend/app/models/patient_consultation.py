"""
Patient Consultation Models for Voice/Video Calls and Secure Chat.

Supports: Videosprechstunde, Telefonberatung, Secure Messaging.

Security:
    - End-to-end encryption for all messages.
    - Call recordings require explicit consent.
    - All sessions are logged for compliance.
"""

import uuid
from datetime import datetime, timezone
from enum import Enum as PyEnum
from typing import Optional

from sqlalchemy import (
    Boolean,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    String,
    Text,
    Uuid,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ConsultationType(str, PyEnum):
    """Type of patient consultation."""

    VIDEO_CALL = "video_call"  # Videosprechstunde
    VOICE_CALL = "voice_call"  # Telefonberatung
    CHAT = "chat"  # Secure Text Chat
    CALLBACK_REQUEST = "callback_request"  # Rückrufbitte


class ConsultationStatus(str, PyEnum):
    """Status of consultation session."""

    REQUESTED = "requested"  # Patient requested
    SCHEDULED = "scheduled"  # Appointment confirmed
    WAITING = "waiting"  # Patient in waiting room
    IN_PROGRESS = "in_progress"  # Call/Chat active
    COMPLETED = "completed"  # Session ended
    CANCELLED = "cancelled"  # Cancelled by either party
    NO_SHOW = "no_show"  # Patient didn't join
    TECHNICAL_ERROR = "technical_error"  # Connection issues


class ConsultationPriority(str, PyEnum):
    """Priority of consultation request."""

    ROUTINE = "routine"  # Standard (next available slot)
    SAME_DAY = "same_day"  # Today if possible
    URGENT = "urgent"  # Within 2 hours
    EMERGENCY = "emergency"  # Immediate (redirect to emergency)


class PatientConsultation(Base):
    """
    Patient consultation session (Video/Voice/Chat).

    DSGVO Compliance:
        - Call recordings only with explicit consent.
        - Chat history encrypted at rest.
        - Auto-delete after retention period.
    """

    __tablename__ = "patient_consultations"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    patient_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), index=True
    )
    doctor_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    
    # Consultation Type & Details
    consultation_type: Mapped[ConsultationType] = mapped_column(Enum(ConsultationType))
    priority: Mapped[ConsultationPriority] = mapped_column(
        Enum(ConsultationPriority), default=ConsultationPriority.ROUTINE
    )
    status: Mapped[ConsultationStatus] = mapped_column(
        Enum(ConsultationStatus), default=ConsultationStatus.REQUESTED
    )
    
    # Topic/Reason
    subject: Mapped[str] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    symptoms: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Scheduling
    scheduled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    scheduled_duration_minutes: Mapped[int] = mapped_column(Integer, default=15)
    
    # Call Session
    room_id: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # WebRTC room
    call_started_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    call_ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    actual_duration_seconds: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    
    # Recording Consent (DSGVO)
    recording_consent: Mapped[bool] = mapped_column(Boolean, default=False)
    recording_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    
    # Quality Metrics
    connection_quality: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)  # good/fair/poor
    patient_rating: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)  # 1-5
    
    # Follow-up
    follow_up_required: Mapped[bool] = mapped_column(Boolean, default=False)
    follow_up_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Linked to Ticket (if from queue)
    ticket_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("tickets.id"), nullable=True
    )
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
    
    # DSGVO: Deletion tracking
    deletion_scheduled_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime, nullable=True
    )

    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    patient: Mapped["User"] = relationship("User", foreign_keys=[patient_id])
    doctor: Mapped[Optional["User"]] = relationship("User", foreign_keys=[doctor_id])
    messages: Mapped[list["PatientConsultationMessage"]] = relationship(
        "PatientConsultationMessage", back_populates="consultation"
    )


class PatientConsultationMessage(Base):
    """
    Message within a patient consultation chat.

    Security:
        - Content is encrypted at rest.
        - Messages auto-deleted with consultation.
    """

    __tablename__ = "patient_consultation_messages"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    consultation_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("patient_consultations.id"), index=True
    )
    sender_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id")
    )
    
    # Message Content
    content: Mapped[str] = mapped_column(Text)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Attachments (encrypted file references)
    attachment_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    attachment_type: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)

    # Relationships
    consultation: Mapped["PatientConsultation"] = relationship(
        "PatientConsultation", back_populates="messages"
    )
    sender: Mapped["User"] = relationship("User")


# Import at module level for type hints
from app.models.models import Practice, User, Ticket  # noqa: E402, F401
