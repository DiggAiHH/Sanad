"""
Document Request Models for Patient Requests.

Supports: Rezept, Überweisung, AU-Bescheinigung, Sonstige Dokumente.

Security:
    - All patient data is encrypted at rest.
    - Access restricted to patient owner and assigned staff.
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


class DocumentType(str, PyEnum):
    """Type of document request."""

    REZEPT = "rezept"  # Medikamentenrezept
    UEBERWEISUNG = "ueberweisung"  # Überweisung zu Facharzt
    AU_BESCHEINIGUNG = "au_bescheinigung"  # Arbeitsunfähigkeitsbescheinigung
    BESCHEINIGUNG = "bescheinigung"  # Sonstige Bescheinigung
    BEFUND = "befund"  # Befundanfrage
    ATTEST = "attest"  # Ärztliches Attest
    SONSTIGE = "sonstige"  # Sonstige Dokumente


class DocumentRequestStatus(str, PyEnum):
    """Status of a document request."""

    PENDING = "pending"  # Angefragt, noch nicht bearbeitet
    IN_REVIEW = "in_review"  # Wird geprüft
    APPROVED = "approved"  # Genehmigt, wird erstellt
    READY = "ready"  # Fertig, kann abgeholt werden
    DELIVERED = "delivered"  # An Patient übergeben
    REJECTED = "rejected"  # Abgelehnt (mit Begründung)
    CANCELLED = "cancelled"  # Vom Patienten storniert


class DocumentRequestPriority(str, PyEnum):
    """Priority of document request."""

    NORMAL = "normal"  # Standard (2-3 Werktage)
    URGENT = "urgent"  # Dringend (24h)
    EXPRESS = "express"  # Express (gleicher Tag, Aufpreis)


class DeliveryMethod(str, PyEnum):
    """How the document should be delivered."""

    PICKUP = "pickup"  # Abholung in der Praxis
    EMAIL = "email"  # Per E-Mail (nur bestimmte Dokumente)
    POST = "post"  # Per Post
    DIGITAL_HEALTH = "digital_health"  # ePA / digitale Gesundheitsakte


class DocumentRequest(Base):
    """
    Patient document request (Rezept, AU, Überweisung etc.).

    DSGVO Compliance:
        - Requests are auto-deleted after 90 days.
        - Patient can request deletion.
        - All access is logged.
    """

    __tablename__ = "document_requests"

    id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    practice_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("practices.id")
    )
    patient_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), index=True
    )
    
    # Document Type & Details
    document_type: Mapped[DocumentType] = mapped_column(Enum(DocumentType))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # For Rezept: medication details
    medication_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    medication_dosage: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    medication_quantity: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    
    # For Überweisung: specialist info
    referral_specialty: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    referral_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # For AU: date range
    au_start_date: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    au_end_date: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    au_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Status & Processing
    status: Mapped[DocumentRequestStatus] = mapped_column(
        Enum(DocumentRequestStatus), default=DocumentRequestStatus.PENDING
    )
    priority: Mapped[DocumentRequestPriority] = mapped_column(
        Enum(DocumentRequestPriority), default=DocumentRequestPriority.NORMAL
    )
    delivery_method: Mapped[DeliveryMethod] = mapped_column(
        Enum(DeliveryMethod), default=DeliveryMethod.PICKUP
    )
    
    # Assignment
    assigned_to_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    
    # Rejection reason (if rejected)
    rejection_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # Internal notes (not visible to patient)
    internal_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    # File attachment (if document generated)
    document_file_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
    processed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    ready_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    delivered_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    
    # DSGVO: Auto-delete marker
    deletion_scheduled_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime, nullable=True
    )

    # Relationships
    practice: Mapped["Practice"] = relationship("Practice")
    patient: Mapped["User"] = relationship("User", foreign_keys=[patient_id])
    assigned_to: Mapped[Optional["User"]] = relationship(
        "User", foreign_keys=[assigned_to_id]
    )


# Import at module level for type hints
from app.models.models import Practice, User  # noqa: E402, F401
