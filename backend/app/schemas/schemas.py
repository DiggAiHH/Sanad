"""
Pydantic schemas for API request/response validation.

All schemas follow strict validation rules per EU CRA compliance.
"""

import uuid
from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# ============================================================================
# Enums
# ============================================================================

class UserRole(str, Enum):
    """User role enumeration."""
    ADMIN = "admin"
    DOCTOR = "doctor"
    MFA = "mfa"
    STAFF = "staff"
    PATIENT = "patient"


class TicketStatus(str, Enum):
    """Ticket status enumeration."""
    WAITING = "waiting"
    CALLED = "called"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"


class TicketPriority(str, Enum):
    """Ticket priority enumeration."""
    NORMAL = "normal"
    HIGH = "high"
    EMERGENCY = "emergency"


class TaskStatus(str, Enum):
    """Task status enumeration."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class TaskPriority(str, Enum):
    """Task priority enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


# ============================================================================
# Auth Schemas
# ============================================================================

class TokenPayload(BaseModel):
    """JWT token payload."""
    sub: str
    exp: datetime
    iat: datetime
    role: UserRole
    type: str


class TokenResponse(BaseModel):
    """Token response for login."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class LoginRequest(BaseModel):
    """Login request schema."""
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)


class RefreshTokenRequest(BaseModel):
    """Refresh token request."""
    refresh_token: str


# ============================================================================
# User Schemas
# ============================================================================

class UserBase(BaseModel):
    """Base user schema."""
    email: EmailStr
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)
    phone: Optional[str] = Field(None, max_length=50)


class UserCreate(UserBase):
    """User creation schema."""
    password: str = Field(..., min_length=8, max_length=128)
    role: UserRole = UserRole.PATIENT


class UserUpdate(BaseModel):
    """User update schema."""
    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    phone: Optional[str] = Field(None, max_length=50)
    is_active: Optional[bool] = None


class UserResponse(UserBase):
    """User response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    role: UserRole
    avatar_url: Optional[str]
    is_active: bool
    is_verified: bool
    created_at: datetime
    last_login: Optional[datetime]


class UserListResponse(BaseModel):
    """Paginated user list response."""
    items: list[UserResponse]
    total: int
    page: int
    page_size: int


# ============================================================================
# Practice Schemas
# ============================================================================

class PracticeBase(BaseModel):
    """Base practice schema."""
    name: str = Field(..., min_length=1, max_length=255)
    address: str
    phone: str = Field(..., max_length=50)
    email: EmailStr


class PracticeCreate(PracticeBase):
    """Practice creation schema."""
    opening_hours: Optional[str] = None
    max_daily_tickets: int = Field(default=100, ge=1, le=1000)
    average_wait_time_minutes: int = Field(default=15, ge=1, le=180)


class PracticeUpdate(BaseModel):
    """Practice update schema."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    address: Optional[str] = None
    phone: Optional[str] = Field(None, max_length=50)
    email: Optional[EmailStr] = None
    opening_hours: Optional[str] = None
    max_daily_tickets: Optional[int] = Field(None, ge=1, le=1000)
    average_wait_time_minutes: Optional[int] = Field(None, ge=1, le=180)
    is_active: Optional[bool] = None


class PracticeResponse(PracticeBase):
    """Practice response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    opening_hours: Optional[str]
    max_daily_tickets: int
    average_wait_time_minutes: int
    is_active: bool
    created_at: datetime
    updated_at: datetime


# ============================================================================
# Queue Schemas
# ============================================================================

class QueueBase(BaseModel):
    """Base queue schema."""
    name: str = Field(..., min_length=1, max_length=100)
    code: str = Field(..., min_length=1, max_length=10)
    description: Optional[str] = None
    color: str = Field(default="#0066CC", pattern=r"^#[0-9A-Fa-f]{6}$")


class QueueCreate(QueueBase):
    """Queue creation schema."""
    practice_id: uuid.UUID
    average_wait_minutes: int = Field(default=15, ge=1, le=180)


class QueueUpdate(BaseModel):
    """Queue update schema."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    color: Optional[str] = Field(None, pattern=r"^#[0-9A-Fa-f]{6}$")
    is_active: Optional[bool] = None
    average_wait_minutes: Optional[int] = Field(None, ge=1, le=180)


class QueueResponse(QueueBase):
    """Queue response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    practice_id: uuid.UUID
    is_active: bool
    current_number: int
    average_wait_minutes: int
    created_at: datetime


class QueueStatsResponse(BaseModel):
    """Queue statistics response."""
    queue_id: uuid.UUID
    queue_name: str
    waiting_count: int
    in_progress_count: int
    completed_today: int
    average_wait_time: int
    current_number: int


# ============================================================================
# Ticket Schemas
# ============================================================================

class TicketBase(BaseModel):
    """Base ticket schema."""
    patient_name: Optional[str] = Field(None, max_length=200)
    patient_phone: Optional[str] = Field(None, max_length=50)
    notes: Optional[str] = None


class TicketCreate(TicketBase):
    """Ticket creation schema."""
    queue_id: uuid.UUID
    priority: TicketPriority = TicketPriority.NORMAL


class TicketUpdate(BaseModel):
    """Ticket update schema."""
    status: Optional[TicketStatus] = None
    priority: Optional[TicketPriority] = None
    notes: Optional[str] = None
    assigned_to_id: Optional[uuid.UUID] = None


class TicketResponse(TicketBase):
    """Ticket response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    queue_id: uuid.UUID
    ticket_number: str
    status: TicketStatus
    priority: TicketPriority
    estimated_wait_minutes: int
    created_by_id: Optional[uuid.UUID]
    assigned_to_id: Optional[uuid.UUID]
    called_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime


class PublicTicketResponse(BaseModel):
    """Public ticket response without PII.

    Security Implications:
        - Excludes patient_name, patient_phone, notes and staff identifiers.
        - Safe for unauthenticated ticket status lookups.
    """

    model_config = ConfigDict(from_attributes=True)

    queue_id: uuid.UUID
    ticket_number: str
    status: TicketStatus
    estimated_wait_minutes: int
    called_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime


class TicketListResponse(BaseModel):
    """Paginated ticket list response."""
    items: list[TicketResponse]
    total: int
    page: int
    page_size: int


# ============================================================================
# Task Schemas
# ============================================================================

class TaskBase(BaseModel):
    """Base task schema."""
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class TaskCreate(TaskBase):
    """Task creation schema."""
    priority: TaskPriority = TaskPriority.MEDIUM
    assignee_id: Optional[uuid.UUID] = None
    due_date: Optional[datetime] = None


class TaskUpdate(BaseModel):
    """Task update schema."""
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    status: Optional[TaskStatus] = None
    priority: Optional[TaskPriority] = None
    assignee_id: Optional[uuid.UUID] = None
    due_date: Optional[datetime] = None


class TaskResponse(TaskBase):
    """Task response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    status: TaskStatus
    priority: TaskPriority
    assignee_id: Optional[uuid.UUID]
    due_date: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime


class TaskListResponse(BaseModel):
    """Paginated task list response."""
    items: list[TaskResponse]
    total: int
    page: int
    page_size: int


# ============================================================================
# Chat Schemas
# ============================================================================

class ChatRoomBase(BaseModel):
    """Base chat room schema."""
    name: str = Field(..., min_length=1, max_length=255)
    is_group: bool = False


class ChatRoomCreate(ChatRoomBase):
    """Chat room creation schema."""
    participant_ids: list[uuid.UUID] = Field(..., min_length=1)


class ChatRoomResponse(ChatRoomBase):
    """Chat room response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime
    last_message: Optional["ChatMessageResponse"] = None
    unread_count: int = 0


class ChatMessageBase(BaseModel):
    """Base chat message schema."""
    content: str = Field(..., min_length=1, max_length=5000)


class ChatMessageCreate(ChatMessageBase):
    """Chat message creation schema."""
    room_id: uuid.UUID


class ChatMessageResponse(ChatMessageBase):
    """Chat message response schema."""
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    room_id: uuid.UUID
    sender_id: uuid.UUID
    is_read: bool
    created_at: datetime
    sender: Optional[UserResponse] = None


class ChatRoomListResponse(BaseModel):
    """Chat room list response."""
    items: list[ChatRoomResponse]
    total: int


class ChatMessageListResponse(BaseModel):
    """Paginated chat message list response."""
    items: list[ChatMessageResponse]
    total: int
    page: int
    page_size: int


# ============================================================================
# Common Schemas
# ============================================================================

class MessageResponse(BaseModel):
    """Generic message response."""
    message: str
    success: bool = True


class ErrorResponse(BaseModel):
    """Error response schema."""
    detail: str
    code: Optional[str] = None
