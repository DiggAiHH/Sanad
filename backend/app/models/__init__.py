"""Models package."""

from app.models.models import (
    Base,
    User,
    UserRole,
    Practice,
    Queue,
    Ticket,
    TicketStatus,
    TicketPriority,
    Task,
    TaskStatus,
    TaskPriority,
    ChatRoom,
    ChatParticipant,
    ChatMessage,
    IoTDevice,
    DeviceType,
    DeviceStatus,
    Zone,
    LEDSegment,
    WayfindingRoute,
    LEDPattern,
    PatientNFCCard,
    NFCCardType,
    CheckInEvent,
    CheckInMethod,
    WaitTimeLog,
    PushDeviceToken,
    DevicePlatform,
)

from app.models.document_request import (
    DocumentRequest,
    DocumentType,
    DocumentRequestStatus,
    DocumentRequestPriority,
    DeliveryMethod,
)

from app.models.patient_consultation import (
    PatientConsultation,
    PatientConsultationMessage,
    ConsultationType,
    ConsultationStatus,
    ConsultationPriority,
)

__all__ = [
    # Base
    "Base",
    # User
    "User",
    "UserRole",
    # Practice
    "Practice",
    # Queue & Tickets
    "Queue",
    "Ticket",
    "TicketStatus",
    "TicketPriority",
    # Tasks
    "Task",
    "TaskStatus",
    "TaskPriority",
    # Chat
    "ChatRoom",
    "ChatParticipant",
    "ChatMessage",
    # IoT
    "IoTDevice",
    "DeviceType",
    "DeviceStatus",
    "Zone",
    "LEDSegment",
    "WayfindingRoute",
    "LEDPattern",
    "PatientNFCCard",
    "NFCCardType",
    "CheckInEvent",
    "CheckInMethod",
    "WaitTimeLog",
    # Push
    "PushDeviceToken",
    "DevicePlatform",
    # Document Requests
    "DocumentRequest",
    "DocumentType",
    "DocumentRequestStatus",
    "DocumentRequestPriority",
    "DeliveryMethod",
    # Patient Consultation
    "PatientConsultation",
    "PatientConsultationMessage",
    "ConsultationType",
    "ConsultationStatus",
    "ConsultationPriority",
]
