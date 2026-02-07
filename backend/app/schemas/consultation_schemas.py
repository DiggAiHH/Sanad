"""
Pydantic schemas for Patient Consultations (Video/Voice/Chat).

DSGVO-compliant with explicit consent tracking.
"""

import uuid
from datetime import datetime
from typing import Optional
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class ConsultationType(str, Enum):
    """Type of patient consultation."""

    VIDEO_CALL = "video_call"
    VOICE_CALL = "voice_call"
    CHAT = "chat"
    CALLBACK_REQUEST = "callback_request"


class ConsultationStatus(str, Enum):
    """Status of consultation session."""

    REQUESTED = "requested"
    SCHEDULED = "scheduled"
    WAITING = "waiting"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"
    TECHNICAL_ERROR = "technical_error"


class ConsultationPriority(str, Enum):
    """Priority of consultation request."""

    ROUTINE = "routine"
    SAME_DAY = "same_day"
    URGENT = "urgent"
    EMERGENCY = "emergency"


# =============================================================================
# Request Schemas
# =============================================================================


class ConsultationRequestCreate(BaseModel):
    """Request a new consultation."""

    consultation_type: ConsultationType
    subject: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    symptoms: Optional[str] = None
    priority: ConsultationPriority = ConsultationPriority.ROUTINE
    preferred_date: Optional[datetime] = Field(
        None, 
        description="Wunschtermin (nicht garantiert)"
    )
    preferred_duration_minutes: int = Field(
        default=15, ge=5, le=60,
        description="Gewünschte Dauer in Minuten"
    )
    recording_consent: bool = Field(
        default=False,
        description="DSGVO: Zustimmung zur Aufnahme"
    )


class ConsultationSchedule(BaseModel):
    """Schedule a consultation (staff only)."""

    doctor_id: uuid.UUID
    scheduled_at: datetime
    scheduled_duration_minutes: int = Field(default=15, ge=5, le=60)


class ConsultationStatusUpdate(BaseModel):
    """Update consultation status."""

    status: ConsultationStatus
    room_id: Optional[str] = Field(None, max_length=100)
    follow_up_required: Optional[bool] = None
    follow_up_notes: Optional[str] = None


class ConsultationJoin(BaseModel):
    """Join a consultation session."""

    consultation_id: uuid.UUID


class ConsultationEnd(BaseModel):
    """End a consultation session."""

    consultation_id: uuid.UUID
    patient_rating: Optional[int] = Field(None, ge=1, le=5)
    follow_up_required: bool = False
    follow_up_notes: Optional[str] = None


class ConsultationCancel(BaseModel):
    """Cancel a consultation."""

    reason: Optional[str] = None


# =============================================================================
# Message Schemas
# =============================================================================


class ConsultationMessageCreate(BaseModel):
    """Send a message in consultation chat."""

    content: str = Field(..., min_length=1, max_length=5000)
    attachment_url: Optional[str] = Field(None, max_length=500)
    attachment_type: Optional[str] = Field(None, max_length=50)


class ConsultationMessageResponse(BaseModel):
    """Consultation message response."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    consultation_id: uuid.UUID
    sender_id: uuid.UUID
    content: str
    is_read: bool
    attachment_url: Optional[str] = None
    attachment_type: Optional[str] = None
    created_at: datetime
    read_at: Optional[datetime] = None
    
    # Sender info (populated from join)
    sender_name: Optional[str] = None
    sender_role: Optional[str] = None


class ConsultationMessageListResponse(BaseModel):
    """List of consultation messages."""

    items: list[ConsultationMessageResponse]
    total: int
    has_more: bool


# =============================================================================
# Response Schemas
# =============================================================================


class ConsultationResponse(BaseModel):
    """Consultation response."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    consultation_type: ConsultationType
    status: ConsultationStatus
    priority: ConsultationPriority
    
    subject: str
    description: Optional[str] = None
    symptoms: Optional[str] = None
    
    # Scheduling
    scheduled_at: Optional[datetime] = None
    scheduled_duration_minutes: int
    
    # Call info
    room_id: Optional[str] = None
    call_started_at: Optional[datetime] = None
    call_ended_at: Optional[datetime] = None
    actual_duration_seconds: Optional[int] = None
    
    # Consent
    recording_consent: bool
    
    # Follow-up
    follow_up_required: bool
    follow_up_notes: Optional[str] = None
    
    # Timestamps
    created_at: datetime
    updated_at: datetime


class ConsultationPatientResponse(ConsultationResponse):
    """Consultation response for patient view."""

    doctor_name: Optional[str] = None
    doctor_specialty: Optional[str] = None
    unread_messages: int = 0


class ConsultationStaffResponse(ConsultationResponse):
    """Consultation response for staff view."""

    patient_id: uuid.UUID
    patient_name: str
    patient_phone: Optional[str] = None
    doctor_id: Optional[uuid.UUID] = None
    doctor_name: Optional[str] = None
    ticket_id: Optional[uuid.UUID] = None
    connection_quality: Optional[str] = None
    patient_rating: Optional[int] = None


class ConsultationListResponse(BaseModel):
    """Paginated consultation list."""

    items: list[ConsultationPatientResponse]
    total: int
    page: int
    page_size: int


class ConsultationStaffListResponse(BaseModel):
    """Paginated consultation list for staff."""

    items: list[ConsultationStaffResponse]
    total: int
    page: int
    page_size: int


# =============================================================================
# WebRTC Schemas
# =============================================================================


class WebRTCOffer(BaseModel):
    """WebRTC session offer."""

    sdp: str = Field(..., description="Session Description Protocol")
    type: str = Field("offer", pattern="^(offer|answer)$")


class WebRTCAnswer(BaseModel):
    """WebRTC session answer."""

    sdp: str
    type: str = Field("answer", pattern="^(offer|answer)$")


class WebRTCIceCandidate(BaseModel):
    """WebRTC ICE candidate."""

    candidate: str
    sdp_mid: Optional[str] = None
    sdp_m_line_index: Optional[int] = None


class WebRTCSignal(BaseModel):
    """Generic WebRTC signal for real-time communication."""

    signal_type: str = Field(..., description="offer, answer, ice-candidate")
    payload: dict
    sender_id: uuid.UUID
    timestamp: datetime


class WebRTCRoomInfo(BaseModel):
    """WebRTC room information."""

    room_id: str
    consultation_id: uuid.UUID
    ice_servers: list[dict] = Field(
        default_factory=lambda: [
            {"urls": "stun:stun.l.google.com:19302"}
        ]
    )
    turn_servers: Optional[list[dict]] = None


# =============================================================================
# Callback Request Schemas
# =============================================================================


class CallbackRequest(BaseModel):
    """Request a callback from the practice."""

    phone_number: str = Field(..., min_length=5, max_length=50)
    preferred_time: Optional[str] = Field(
        None, 
        description="z.B. 'Vormittags', 'Nach 14 Uhr'"
    )
    reason: str = Field(..., min_length=1, max_length=500)
    priority: ConsultationPriority = ConsultationPriority.ROUTINE


class CallbackResponse(BaseModel):
    """Callback request response."""

    id: uuid.UUID
    status: ConsultationStatus
    phone_number: str
    preferred_time: Optional[str]
    reason: str
    created_at: datetime
    estimated_callback_time: Optional[str] = None
