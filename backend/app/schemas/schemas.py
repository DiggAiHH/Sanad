"""
Pydantic schemas for API request/response validation.

All schemas follow strict validation rules per EU CRA compliance.
"""

import uuid
from datetime import datetime
from uuid import UUID
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
    website: Optional[str] = Field(None, max_length=255)


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
    website: Optional[str] = Field(None, max_length=255)
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
# Public Practice Schemas
# ============================================================================


class PublicPracticeResponse(BaseModel):
    """Public practice info schema for patient apps."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    address: str
    phone: str
    email: EmailStr
    website: Optional[str]
    opening_hours: Optional[str]
    average_wait_time_minutes: int


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


# ============================================================================
# Public Queue Schemas
# ============================================================================


class PublicQueueSummaryItem(BaseModel):
    """Public summary data for a single queue."""

    queue_id: uuid.UUID
    name: str
    code: str
    color: str
    average_wait_minutes: int
    waiting_count: int


class PublicQueueSummaryResponse(BaseModel):
    """Public queue summary for patient home screen."""

    practice_id: uuid.UUID
    practice_name: str
    opening_hours: Optional[str]
    average_wait_time_minutes: int
    now_serving_ticket: Optional[str]
    queues: list[PublicQueueSummaryItem]
    generated_at: datetime


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


# ============================================================================
# IoT / Zero-Touch Reception Schemas
# ============================================================================


class DeviceType(str, Enum):
    """IoT device type enumeration."""

    NFC_READER = "nfc_reader"
    LED_CONTROLLER = "led_controller"
    DISPLAY = "display"
    KIOSK = "kiosk"


class DeviceStatus(str, Enum):
    """IoT device online status."""

    ONLINE = "online"
    OFFLINE = "offline"
    ERROR = "error"
    MAINTENANCE = "maintenance"


class LEDPattern(str, Enum):
    """LED animation patterns for wayfinding."""

    SOLID = "solid"
    PULSE = "pulse"
    CHASE = "chase"
    RAINBOW = "rainbow"
    BREATHE = "breathe"
    WIPE = "wipe"


class NFCCardType(str, Enum):
    """Type of NFC card/token."""

    EGK = "egk"
    CUSTOM = "custom"
    TEMPORARY = "temporary"
    MOBILE = "mobile"


class CheckInMethod(str, Enum):
    """Method used for patient check-in."""

    NFC = "nfc"
    QR = "qr"
    MANUAL = "manual"
    KIOSK = "kiosk"
    ONLINE = "online"


# --- NFC Schemas ---


class NFCCheckInRequest(BaseModel):
    """Request for NFC-based check-in."""

    nfc_uid: str = Field(
        ..., description="Raw NFC UID from reader (e.g., '04:A3:5B:1A:7C:8D:90')"
    )
    device_id: UUID = Field(..., description="ID of the NFC reader device")
    device_secret: str = Field(..., description="Device authentication secret")


class NFCCheckInResponse(BaseModel):
    """Response after successful NFC check-in."""

    success: bool
    ticket_number: Optional[str] = None
    queue_name: Optional[str] = None
    estimated_wait_minutes: Optional[int] = None
    assigned_room: Optional[str] = None
    wayfinding_route_id: Optional[UUID] = None
    patient_name: Optional[str] = Field(None, description="First name only for privacy")
    message: str


class NFCCardRegisterRequest(BaseModel):
    """Request to register a new NFC card for a patient."""

    patient_id: UUID
    nfc_uid: str = Field(..., description="Raw NFC UID from reader")
    card_type: NFCCardType = NFCCardType.CUSTOM
    card_label: Optional[str] = Field(None, description="Label like 'Hauptkarte'")
    expires_at: Optional[datetime] = None


class NFCCardResponse(BaseModel):
    """Response for NFC card information."""

    id: UUID
    patient_id: UUID
    card_type: NFCCardType
    card_label: Optional[str]
    is_active: bool
    created_at: datetime
    expires_at: Optional[datetime]
    last_used_at: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)


class NFCCardListResponse(BaseModel):
    """List of NFC cards."""

    items: list[NFCCardResponse]
    total: int


# --- IoT Device Schemas ---


class IoTDeviceBase(BaseModel):
    """Base IoT device schema."""

    device_name: str = Field(..., min_length=1, max_length=100)
    device_type: DeviceType
    location: Optional[str] = Field(
        None, description="Physical location (e.g., 'Empfang')"
    )
    ip_address: Optional[str] = None
    firmware_version: Optional[str] = None


class IoTDeviceCreate(IoTDeviceBase):
    """Create IoT device request."""

    device_serial: str = Field(..., description="Unique hardware serial number")


class IoTDeviceUpdate(BaseModel):
    """Update IoT device request."""

    device_name: Optional[str] = None
    location: Optional[str] = None
    ip_address: Optional[str] = None
    firmware_version: Optional[str] = None
    is_active: Optional[bool] = None


class IoTDeviceResponse(IoTDeviceBase):
    """IoT device response."""

    id: UUID
    practice_id: UUID
    device_serial: str
    status: DeviceStatus
    is_active: bool
    last_heartbeat: Optional[datetime]
    created_at: datetime
    device_secret: Optional[str] = Field(
        None, description="Plain device secret (only returned on creation)"
    )

    model_config = ConfigDict(from_attributes=True)


class IoTDeviceListResponse(BaseModel):
    """List of IoT devices."""

    items: list[IoTDeviceResponse]
    total: int


class DeviceHeartbeatRequest(BaseModel):
    """Heartbeat from IoT device."""

    device_serial: str
    device_secret: str
    firmware_version: Optional[str] = None
    uptime_seconds: Optional[int] = None
    free_memory: Optional[int] = None


class DeviceHeartbeatResponse(BaseModel):
    """Response to device heartbeat."""

    success: bool
    server_time: datetime
    commands: list[dict] = Field(
        default_factory=list, description="Pending commands for device"
    )


# --- LED / Wayfinding Schemas ---


class ZoneBase(BaseModel):
    """Base zone schema."""

    zone_name: str = Field(..., min_length=1, max_length=100)
    zone_code: str = Field(..., description="Short code like 'WARTE' or 'RAUM3'")
    zone_type: str = Field(..., description="Type: entrance, corridor, waiting, room")
    default_color: str = Field("#0066CC", description="Default hex color")


class ZoneCreate(ZoneBase):
    """Create zone request."""

    pass


class ZoneResponse(ZoneBase):
    """Zone response."""

    id: UUID
    practice_id: UUID
    is_active: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ZoneListResponse(BaseModel):
    """List of zones."""

    items: list[ZoneResponse]
    total: int


class LEDSegmentBase(BaseModel):
    """Base LED segment schema."""

    segment_id: int = Field(..., ge=0, le=15, description="WLED segment ID (0-15)")
    start_led: int = Field(..., ge=0, description="Start LED index")
    end_led: int = Field(..., ge=0, description="End LED index")
    default_color: str = Field("#FFFFFF", description="Default hex color")
    default_brightness: int = Field(128, ge=0, le=255)


class LEDSegmentCreate(LEDSegmentBase):
    """Create LED segment request."""

    zone_id: UUID
    controller_id: UUID


class LEDSegmentResponse(LEDSegmentBase):
    """LED segment response."""

    id: UUID
    zone_id: UUID
    controller_id: UUID
    is_active: bool

    model_config = ConfigDict(from_attributes=True)


class WayfindingRouteBase(BaseModel):
    """Base wayfinding route schema."""

    route_name: str = Field(..., description="Human-readable name")
    from_zone_id: UUID
    to_zone_id: UUID
    led_pattern: LEDPattern = LEDPattern.CHASE
    route_color: str = Field("#00FF00", description="Hex color for route")
    animation_speed: int = Field(50, ge=1, le=255, description="WLED animation speed")


class WayfindingRouteCreate(WayfindingRouteBase):
    """Create wayfinding route request."""

    segment_ids: list[UUID] = Field(..., description="Ordered list of LED segments")


class WayfindingRouteResponse(WayfindingRouteBase):
    """Wayfinding route response."""

    id: UUID
    practice_id: UUID
    is_active: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class WayfindingRouteListResponse(BaseModel):
    """List of wayfinding routes."""

    items: list[WayfindingRouteResponse]
    total: int


class TriggerRouteRequest(BaseModel):
    """Request to trigger a wayfinding route."""

    route_id: UUID
    duration_seconds: int = Field(
        30, ge=5, le=300, description="How long to show the route"
    )
    patient_ticket_id: Optional[UUID] = None


class TriggerRouteResponse(BaseModel):
    """Response after triggering a route."""

    success: bool
    message: str
    route_id: UUID
    expires_at: datetime


class LEDCommandRequest(BaseModel):
    """Direct LED command to a controller."""

    controller_id: UUID
    segment_id: int = Field(..., ge=0, le=15)
    color: str = Field(..., description="Hex color")
    brightness: int = Field(255, ge=0, le=255)
    pattern: LEDPattern = LEDPattern.SOLID
    duration_seconds: Optional[int] = Field(
        None, description="Auto-off after N seconds"
    )


class LEDCommandResponse(BaseModel):
    """Response to LED command."""

    success: bool
    controller_id: UUID
    segment_id: int


# --- Check-In Event Schemas ---


class CheckInEventResponse(BaseModel):
    """Check-in event log entry."""

    id: UUID
    ticket_id: UUID
    ticket_number: str
    check_in_method: CheckInMethod
    device_id: Optional[UUID]
    patient_name: Optional[str]
    checked_in_at: datetime
    assigned_room: Optional[str]

    model_config = ConfigDict(from_attributes=True)


class CheckInEventListResponse(BaseModel):
    """List of check-in events."""

    items: list[CheckInEventResponse]
    total: int


# --- Wait Time Visualization Schemas ---


class WaitTimeStatus(str, Enum):
    """Visual wait time status."""

    OK = "ok"  # Green: < 10 min
    WARNING = "warning"  # Yellow: 10-20 min
    CRITICAL = "critical"  # Red: > 20 min


class WaitTimeVisualization(BaseModel):
    """Wait time visualization data for LED zones."""

    zone_id: UUID
    zone_name: str
    current_wait_minutes: int
    status: WaitTimeStatus
    color: str  # Calculated hex color
    patient_count: int


class WaitTimeOverviewResponse(BaseModel):
    """Overview of all waiting areas."""

    zones: list[WaitTimeVisualization]
    total_waiting: int
    average_wait_minutes: float
    updated_at: datetime


# ============================================================================
# Push Notification Schemas
# ============================================================================


class DevicePlatform(str, Enum):
    """Mobile device platform."""

    IOS = "ios"
    ANDROID = "android"
    WEB = "web"


class PushNotificationType(str, Enum):
    """Type of push notification event."""

    TICKET_CALLED = "ticket_called"  # Patient: Your number is called
    TICKET_CREATED = "ticket_created"  # MFA: New ticket in queue
    QUEUE_UPDATE = "queue_update"  # Patient: Wait time changed
    CHECK_IN_SUCCESS = "check_in_success"  # Patient: Check-in confirmed
    APPOINTMENT_REMINDER = "appointment_reminder"
    SYSTEM_ALERT = "system_alert"


class RegisterDeviceTokenRequest(BaseModel):
    """Request to register FCM device token."""

    fcm_token: str = Field(..., min_length=50, max_length=500)
    platform: DevicePlatform
    device_name: Optional[str] = Field(None, max_length=100)
    app_version: Optional[str] = Field(None, max_length=20)


class RegisterDeviceTokenResponse(BaseModel):
    """Response after token registration."""

    success: bool
    device_id: UUID
    message: str


class UnregisterDeviceTokenRequest(BaseModel):
    """Request to unregister FCM device token."""

    fcm_token: str


class PushNotificationPayload(BaseModel):
    """Push notification payload structure."""

    notification_type: PushNotificationType
    title: str
    body: str
    data: Optional[dict] = None  # Custom data (ticket_number, queue_id, etc.)


class SendPushRequest(BaseModel):
    """Internal request to send push notification."""

    user_ids: list[UUID]
    payload: PushNotificationPayload


class PushNotificationStats(BaseModel):
    """Push notification delivery stats."""

    total_tokens: int
    successful: int
    failed: int
    invalid_tokens: list[str] = []
