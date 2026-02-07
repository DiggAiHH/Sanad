"""
Pydantic schemas for Document Requests.

DSGVO-compliant schemas with proper validation.
"""

import uuid
from datetime import datetime
from typing import Optional
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class DocumentType(str, Enum):
    """Type of document request."""

    REZEPT = "rezept"
    UEBERWEISUNG = "ueberweisung"
    AU_BESCHEINIGUNG = "au_bescheinigung"
    BESCHEINIGUNG = "bescheinigung"
    BEFUND = "befund"
    ATTEST = "attest"
    SONSTIGE = "sonstige"


class DocumentRequestStatus(str, Enum):
    """Status of a document request."""

    PENDING = "pending"
    IN_REVIEW = "in_review"
    APPROVED = "approved"
    READY = "ready"
    DELIVERED = "delivered"
    REJECTED = "rejected"
    CANCELLED = "cancelled"


class DocumentRequestPriority(str, Enum):
    """Priority of document request."""

    NORMAL = "normal"
    URGENT = "urgent"
    EXPRESS = "express"


class DeliveryMethod(str, Enum):
    """How the document should be delivered."""

    PICKUP = "pickup"
    EMAIL = "email"
    POST = "post"
    DIGITAL_HEALTH = "digital_health"


# =============================================================================
# Base Schemas
# =============================================================================


class DocumentRequestBase(BaseModel):
    """Base document request schema."""

    document_type: DocumentType
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    priority: DocumentRequestPriority = DocumentRequestPriority.NORMAL
    delivery_method: DeliveryMethod = DeliveryMethod.PICKUP


class RezeptRequestCreate(DocumentRequestBase):
    """Create a prescription (Rezept) request."""

    document_type: DocumentType = DocumentType.REZEPT
    medication_name: str = Field(..., min_length=1, max_length=255)
    medication_dosage: Optional[str] = Field(None, max_length=100)
    medication_quantity: Optional[int] = Field(None, ge=1, le=100)


class UeberweisungRequestCreate(DocumentRequestBase):
    """Create a referral (Überweisung) request."""

    document_type: DocumentType = DocumentType.UEBERWEISUNG
    referral_specialty: str = Field(..., min_length=1, max_length=100)
    referral_reason: Optional[str] = None


class AUBescheinigungRequestCreate(DocumentRequestBase):
    """Create a sick note (AU-Bescheinigung) request."""

    document_type: DocumentType = DocumentType.AU_BESCHEINIGUNG
    au_start_date: datetime
    au_end_date: datetime
    au_reason: Optional[str] = Field(
        None, 
        description="Kurze Beschreibung der Symptome (nicht für AU-Schein, nur intern)"
    )


class GeneralDocumentRequestCreate(DocumentRequestBase):
    """Create a general document request."""

    pass


class DocumentRequestCreate(BaseModel):
    """Unified document request creation schema."""

    document_type: DocumentType
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    priority: DocumentRequestPriority = DocumentRequestPriority.NORMAL
    delivery_method: DeliveryMethod = DeliveryMethod.PICKUP
    
    # Optional type-specific fields
    medication_name: Optional[str] = Field(None, max_length=255)
    medication_dosage: Optional[str] = Field(None, max_length=100)
    medication_quantity: Optional[int] = Field(None, ge=1, le=100)
    
    referral_specialty: Optional[str] = Field(None, max_length=100)
    referral_reason: Optional[str] = None
    
    au_start_date: Optional[datetime] = None
    au_end_date: Optional[datetime] = None
    au_reason: Optional[str] = None


class DocumentRequestUpdate(BaseModel):
    """Update document request (staff only)."""

    status: Optional[DocumentRequestStatus] = None
    priority: Optional[DocumentRequestPriority] = None
    assigned_to_id: Optional[uuid.UUID] = None
    rejection_reason: Optional[str] = None
    internal_notes: Optional[str] = None
    document_file_url: Optional[str] = Field(None, max_length=500)


class DocumentRequestPatientUpdate(BaseModel):
    """Patient can only cancel their request."""

    status: DocumentRequestStatus = DocumentRequestStatus.CANCELLED


# =============================================================================
# Response Schemas
# =============================================================================


class DocumentRequestResponse(BaseModel):
    """Document request response for patients."""

    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    document_type: DocumentType
    title: str
    description: Optional[str]
    status: DocumentRequestStatus
    priority: DocumentRequestPriority
    delivery_method: DeliveryMethod
    
    # Type-specific (only shown if relevant)
    medication_name: Optional[str] = None
    medication_dosage: Optional[str] = None
    medication_quantity: Optional[int] = None
    
    referral_specialty: Optional[str] = None
    referral_reason: Optional[str] = None
    
    au_start_date: Optional[datetime] = None
    au_end_date: Optional[datetime] = None
    
    # Status info
    rejection_reason: Optional[str] = None
    
    # Timestamps
    created_at: datetime
    updated_at: datetime
    ready_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None


class DocumentRequestStaffResponse(DocumentRequestResponse):
    """Document request response for staff (includes internal fields)."""

    patient_id: uuid.UUID
    assigned_to_id: Optional[uuid.UUID] = None
    internal_notes: Optional[str] = None
    document_file_url: Optional[str] = None
    au_reason: Optional[str] = None
    processed_at: Optional[datetime] = None


class DocumentRequestListResponse(BaseModel):
    """Paginated document request list."""

    items: list[DocumentRequestResponse]
    total: int
    page: int
    page_size: int


class DocumentRequestStaffListResponse(BaseModel):
    """Paginated document request list for staff."""

    items: list[DocumentRequestStaffResponse]
    total: int
    page: int
    page_size: int


# =============================================================================
# Quick Request Schemas (for common requests)
# =============================================================================


class QuickRezeptRequest(BaseModel):
    """Quick prescription request with defaults."""

    medication_name: str = Field(..., min_length=1, max_length=255)
    medication_dosage: Optional[str] = Field(None, max_length=100)
    medication_quantity: int = Field(default=1, ge=1, le=100)
    priority: DocumentRequestPriority = DocumentRequestPriority.NORMAL
    notes: Optional[str] = None


class QuickAURequest(BaseModel):
    """Quick sick note request."""

    start_date: datetime
    end_date: datetime
    symptoms_description: Optional[str] = Field(
        None,
        description="Kurze Symptombeschreibung (nur intern, nicht auf AU)"
    )
    priority: DocumentRequestPriority = DocumentRequestPriority.NORMAL


class QuickUeberweisungRequest(BaseModel):
    """Quick referral request."""

    specialty: str = Field(..., min_length=1, max_length=100)
    reason: Optional[str] = None
    priority: DocumentRequestPriority = DocumentRequestPriority.NORMAL
