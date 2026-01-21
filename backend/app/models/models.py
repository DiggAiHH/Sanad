"""
SQLAlchemy database models.

All models use UUID primary keys for security and scalability.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum
from typing import Optional

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class UserRole(str, PyEnum):
    """User role enumeration."""
    ADMIN = "admin"
    DOCTOR = "doctor"
    MFA = "mfa"
    STAFF = "staff"
    PATIENT = "patient"


class TicketStatus(str, PyEnum):
    """Ticket status enumeration."""
    WAITING = "waiting"
    CALLED = "called"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    NO_SHOW = "no_show"


class TicketPriority(str, PyEnum):
    """Ticket priority enumeration."""
    NORMAL = "normal"
    HIGH = "high"
    EMERGENCY = "emergency"


class TaskStatus(str, PyEnum):
    """Task status enumeration."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class TaskPriority(str, PyEnum):
    """Task priority enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class User(Base):
    """
    User model for all system users.
    
    Security:
        - Passwords stored as bcrypt hashes only.
        - Email must be unique.
    """
    __tablename__ = "users"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    first_name: Mapped[str] = mapped_column(String(100))
    last_name: Mapped[str] = mapped_column(String(100))
    role: Mapped[UserRole] = mapped_column(Enum(UserRole), default=UserRole.PATIENT)
    phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    last_login: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    assigned_tickets: Mapped[list["Ticket"]] = relationship(
        "Ticket", back_populates="assigned_to", foreign_keys="Ticket.assigned_to_id"
    )
    created_tickets: Mapped[list["Ticket"]] = relationship(
        "Ticket", back_populates="created_by", foreign_keys="Ticket.created_by_id"
    )
    assigned_tasks: Mapped[list["Task"]] = relationship(
        "Task", back_populates="assignee", foreign_keys="Task.assignee_id"
    )
    messages: Mapped[list["ChatMessage"]] = relationship("ChatMessage", back_populates="sender")


class Practice(Base):
    """Practice/clinic configuration."""
    __tablename__ = "practices"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(255))
    address: Mapped[str] = mapped_column(Text)
    phone: Mapped[str] = mapped_column(String(50))
    email: Mapped[str] = mapped_column(String(255))
    opening_hours: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    max_daily_tickets: Mapped[int] = mapped_column(Integer, default=100)
    average_wait_time_minutes: Mapped[int] = mapped_column(Integer, default=15)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    
    # Relationships
    queues: Mapped[list["Queue"]] = relationship("Queue", back_populates="practice")


class Queue(Base):
    """Queue/category for tickets."""
    __tablename__ = "queues"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    zone_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id"), nullable=True
    )
    name: Mapped[str] = mapped_column(String(100))
    code: Mapped[str] = mapped_column(String(10))  # e.g., "A", "B", "C"
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    color: Mapped[str] = mapped_column(String(7), default="#0066CC")  # Hex color
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    current_number: Mapped[int] = mapped_column(Integer, default=0)
    average_wait_minutes: Mapped[int] = mapped_column(Integer, default=15)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice", back_populates="queues")
    zone: Mapped[Optional["Zone"]] = relationship("Zone")
    tickets: Mapped[list["Ticket"]] = relationship("Ticket", back_populates="queue")


class Ticket(Base):
    """Patient ticket in the queue."""
    __tablename__ = "tickets"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    queue_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("queues.id")
    )
    ticket_number: Mapped[str] = mapped_column(String(20), index=True)  # e.g., "A-042"
    patient_name: Mapped[Optional[str]] = mapped_column(String(200), nullable=True)
    patient_phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    status: Mapped[TicketStatus] = mapped_column(
        Enum(TicketStatus), default=TicketStatus.WAITING
    )
    priority: Mapped[TicketPriority] = mapped_column(
        Enum(TicketPriority), default=TicketPriority.NORMAL
    )
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    estimated_wait_minutes: Mapped[int] = mapped_column(Integer, default=15)
    created_by_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    assigned_to_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    called_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    queue: Mapped["Queue"] = relationship("Queue", back_populates="tickets")
    created_by: Mapped[Optional["User"]] = relationship(
        "User", back_populates="created_tickets", foreign_keys=[created_by_id]
    )
    assigned_to: Mapped[Optional["User"]] = relationship(
        "User", back_populates="assigned_tickets", foreign_keys=[assigned_to_id]
    )


class Task(Base):
    """Staff task/todo item."""
    __tablename__ = "tasks"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    status: Mapped[TaskStatus] = mapped_column(Enum(TaskStatus), default=TaskStatus.TODO)
    priority: Mapped[TaskPriority] = mapped_column(
        Enum(TaskPriority), default=TaskPriority.MEDIUM
    )
    assignee_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    due_date: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    
    # Relationships
    assignee: Mapped[Optional["User"]] = relationship(
        "User", back_populates="assigned_tasks"
    )


class ChatRoom(Base):
    """Chat room for team communication."""
    __tablename__ = "chat_rooms"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    name: Mapped[str] = mapped_column(String(255))
    is_group: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    
    # Relationships
    messages: Mapped[list["ChatMessage"]] = relationship(
        "ChatMessage", back_populates="room"
    )
    participants: Mapped[list["ChatParticipant"]] = relationship(
        "ChatParticipant", back_populates="room"
    )


class ChatParticipant(Base):
    """Chat room participant."""
    __tablename__ = "chat_participants"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    room_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("chat_rooms.id")
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id")
    )
    joined_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    room: Mapped["ChatRoom"] = relationship("ChatRoom", back_populates="participants")


class ChatMessage(Base):
    """Chat message."""
    __tablename__ = "chat_messages"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    room_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("chat_rooms.id")
    )
    sender_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id")
    )
    content: Mapped[str] = mapped_column(Text)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    room: Mapped["ChatRoom"] = relationship("ChatRoom", back_populates="messages")
    sender: Mapped["User"] = relationship("User", back_populates="messages")


# ============================================================================
# ZERO-TOUCH RECEPTION MODELS (NFC, LED, Wayfinding)
# ============================================================================

class CheckInMethod(str, PyEnum):
    """Method used for patient check-in."""
    NFC = "nfc"
    QR = "qr"
    MANUAL = "manual"
    KIOSK = "kiosk"
    ONLINE = "online"


class DeviceType(str, PyEnum):
    """IoT device type enumeration."""
    NFC_READER = "nfc_reader"
    LED_CONTROLLER = "led_controller"
    DISPLAY = "display"
    KIOSK = "kiosk"


class DeviceStatus(str, PyEnum):
    """IoT device online status."""
    ONLINE = "online"
    OFFLINE = "offline"
    ERROR = "error"
    MAINTENANCE = "maintenance"


class LEDPattern(str, PyEnum):
    """LED animation patterns for wayfinding."""
    SOLID = "solid"
    PULSE = "pulse"
    CHASE = "chase"
    RAINBOW = "rainbow"
    BREATHE = "breathe"
    WIPE = "wipe"


class NFCCardType(str, PyEnum):
    """Type of NFC card/token."""
    EGK = "egk"              # Elektronische Gesundheitskarte
    CUSTOM = "custom"        # Praxis-eigene Karte
    TEMPORARY = "temporary"  # Temporär-Karte für Neupatienten
    MOBILE = "mobile"        # Smartphone HCE


class IoTDevice(Base):
    """
    IoT device registry for NFC readers, LED controllers, displays.
    
    Security:
        - device_secret is hashed, used for MQTT authentication.
        - All devices must be registered before connecting.
    """
    __tablename__ = "iot_devices"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    device_type: Mapped[DeviceType] = mapped_column(Enum(DeviceType))
    device_name: Mapped[str] = mapped_column(String(100))  # z.B. "Empfang-Terminal-1"
    device_serial: Mapped[str] = mapped_column(String(100), unique=True)  # Hardware-ID
    device_secret_hash: Mapped[str] = mapped_column(String(255))  # Hashed secret
    location: Mapped[str] = mapped_column(String(100))  # z.B. "Eingang", "Flur-A"
    zone_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id"), nullable=True
    )
    ip_address: Mapped[Optional[str]] = mapped_column(String(45), nullable=True)  # IPv4/IPv6
    firmware_version: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    status: Mapped[DeviceStatus] = mapped_column(
        Enum(DeviceStatus), default=DeviceStatus.OFFLINE
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    last_heartbeat: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    zone: Mapped[Optional["Zone"]] = relationship("Zone", back_populates="devices")
    check_in_events: Mapped[list["CheckInEvent"]] = relationship(
        "CheckInEvent", back_populates="device"
    )


class Zone(Base):
    """
    Physical zone in the practice for wayfinding.
    
    Examples: "Eingang", "Wartebereich", "Flur-A", "Zimmer-1"
    """
    __tablename__ = "zones"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    name: Mapped[str] = mapped_column(String(100))  # z.B. "Wartebereich"
    code: Mapped[str] = mapped_column(String(20))   # z.B. "WB-1", "ZIM-3"
    zone_type: Mapped[str] = mapped_column(String(50))  # entrance, corridor, waiting, room
    floor: Mapped[int] = mapped_column(Integer, default=0)
    x_position: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)  # Grid position
    y_position: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    is_destination: Mapped[bool] = mapped_column(Boolean, default=False)  # Can be routed to
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    devices: Mapped[list["IoTDevice"]] = relationship("IoTDevice", back_populates="zone")
    led_segments: Mapped[list["LEDSegment"]] = relationship("LEDSegment", back_populates="zone")
    routes_from: Mapped[list["WayfindingRoute"]] = relationship(
        "WayfindingRoute", back_populates="from_zone", foreign_keys="WayfindingRoute.from_zone_id"
    )
    routes_to: Mapped[list["WayfindingRoute"]] = relationship(
        "WayfindingRoute", back_populates="to_zone", foreign_keys="WayfindingRoute.to_zone_id"
    )


class LEDSegment(Base):
    """
    LED strip segment configuration for a zone.
    
    Maps to WLED segments for granular control.
    """
    __tablename__ = "led_segments"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    zone_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id")
    )
    controller_device_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("iot_devices.id")
    )
    segment_id: Mapped[int] = mapped_column(Integer)  # WLED segment ID (0-15)
    start_led: Mapped[int] = mapped_column(Integer)   # First LED index
    end_led: Mapped[int] = mapped_column(Integer)     # Last LED index
    default_color: Mapped[str] = mapped_column(String(7), default="#0066CC")  # Hex
    default_brightness: Mapped[int] = mapped_column(Integer, default=128)  # 0-255
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    zone: Mapped["Zone"] = relationship("Zone", back_populates="led_segments")
    controller: Mapped["IoTDevice"] = relationship("IoTDevice")


class WayfindingRoute(Base):
    """
    Pre-defined route between two zones.
    
    Used to calculate which LED segments to activate.
    """
    __tablename__ = "wayfinding_routes"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    from_zone_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id")
    )
    to_zone_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id")
    )
    name: Mapped[str] = mapped_column(String(100))  # z.B. "Eingang -> Zimmer 3"
    led_segment_ids: Mapped[str] = mapped_column(Text)  # JSON array of segment UUIDs
    led_pattern: Mapped[LEDPattern] = mapped_column(
        Enum(LEDPattern), default=LEDPattern.CHASE
    )
    led_color: Mapped[str] = mapped_column(String(7), default="#00FF00")  # Green for go
    duration_seconds: Mapped[int] = mapped_column(Integer, default=30)  # How long to show
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    from_zone: Mapped["Zone"] = relationship(
        "Zone", back_populates="routes_from", foreign_keys=[from_zone_id]
    )
    to_zone: Mapped["Zone"] = relationship(
        "Zone", back_populates="routes_to", foreign_keys=[to_zone_id]
    )


class PatientNFCCard(Base):
    """
    NFC card/token assigned to a patient.
    
    Security:
        - nfc_uid is stored encrypted (AES-256).
        - One patient can have multiple cards (e.g., eGK + temporary).
    """
    __tablename__ = "patient_nfc_cards"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    patient_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id")
    )
    nfc_uid_encrypted: Mapped[str] = mapped_column(String(255))  # Encrypted UID
    nfc_uid_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)  # SHA-256 for lookup
    card_type: Mapped[NFCCardType] = mapped_column(Enum(NFCCardType))
    card_label: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)  # "Hauptkarte"
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    issued_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    last_used_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    patient: Mapped["User"] = relationship("User")
    check_in_events: Mapped[list["CheckInEvent"]] = relationship(
        "CheckInEvent", back_populates="nfc_card"
    )


class CheckInEvent(Base):
    """
    Automated check-in event log.
    
    Records every check-in attempt for audit and analytics.
    """
    __tablename__ = "check_in_events"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    ticket_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("tickets.id"), nullable=True
    )
    device_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("iot_devices.id"), nullable=True
    )
    nfc_card_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("patient_nfc_cards.id"), nullable=True
    )
    check_in_method: Mapped[CheckInMethod] = mapped_column(Enum(CheckInMethod))
    patient_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    raw_nfc_uid_hash: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)  # For unregistered cards
    success: Mapped[bool] = mapped_column(Boolean, default=True)
    failure_reason: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    assigned_room: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    wayfinding_route_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("wayfinding_routes.id"), nullable=True
    )
    checked_in_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    ticket: Mapped[Optional["Ticket"]] = relationship("Ticket")
    device: Mapped[Optional["IoTDevice"]] = relationship(
        "IoTDevice", back_populates="check_in_events"
    )
    nfc_card: Mapped[Optional["PatientNFCCard"]] = relationship(
        "PatientNFCCard", back_populates="check_in_events"
    )
    patient: Mapped[Optional["User"]] = relationship("User")
    wayfinding_route: Mapped[Optional["WayfindingRoute"]] = relationship("WayfindingRoute")


class WaitTimeLog(Base):
    """
    Waiting time analytics for LED color visualization.
    
    Used to calculate average wait times and trigger LED color changes.
    """
    __tablename__ = "wait_time_logs"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    queue_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("queues.id")
    )
    zone_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("zones.id"), nullable=True
    )
    waiting_count: Mapped[int] = mapped_column(Integer, default=0)
    average_wait_minutes: Mapped[int] = mapped_column(Integer, default=0)
    max_wait_minutes: Mapped[int] = mapped_column(Integer, default=0)
    led_color_state: Mapped[str] = mapped_column(String(7), default="#00FF00")  # Green/Yellow/Red
    recorded_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    queue: Mapped["Queue"] = relationship("Queue")
    zone: Mapped[Optional["Zone"]] = relationship("Zone")


class DevicePlatform(str, PyEnum):
    """Mobile device platform for push notifications."""
    IOS = "ios"
    ANDROID = "android"
    WEB = "web"


class PushDeviceToken(Base):
    """
    FCM device tokens for push notifications.
    
    Security:
        - Tokens are stored per user + device.
        - Old tokens are automatically invalidated.
    """
    __tablename__ = "push_device_tokens"
    
    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), index=True
    )
    fcm_token: Mapped[str] = mapped_column(String(500), unique=True)
    platform: Mapped[DevicePlatform] = mapped_column(Enum(DevicePlatform))
    device_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    app_version: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_used_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user: Mapped["User"] = relationship("User")
