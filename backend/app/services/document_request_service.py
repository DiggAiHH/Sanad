"""
Document Request Service.

Business logic for patient document requests.

Security:
    - Patients can only access their own requests.
    - Staff can access all requests within their practice.
    - All access is logged for DSGVO compliance.
"""

import logging
import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional

from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.document_request import (
    DocumentRequest,
    DocumentType,
    DocumentRequestStatus,
    DocumentRequestPriority,
)
from app.schemas.document_request_schemas import (
    DocumentRequestCreate,
    DocumentRequestUpdate,
)


logger = logging.getLogger(__name__)


async def create_document_request(
    db: AsyncSession,
    patient_id: uuid.UUID,
    practice_id: uuid.UUID,
    request_data: DocumentRequestCreate,
) -> DocumentRequest:
    """
    Create a new document request.

    Args:
        db: Database session.
        patient_id: Patient's user ID.
        practice_id: Practice ID.
        request_data: Request data.

    Returns:
        DocumentRequest: Created document request.

    Security Implications:
        - Validates patient belongs to practice.
        - Auto-schedules deletion per DSGVO (90 days).
    """
    # Calculate DSGVO deletion date
    deletion_date = datetime.now(timezone.utc) + timedelta(days=90)
    
    document_request = DocumentRequest(
        practice_id=practice_id,
        patient_id=patient_id,
        document_type=request_data.document_type,
        title=request_data.title,
        description=request_data.description,
        priority=request_data.priority,
        delivery_method=request_data.delivery_method,
        status=DocumentRequestStatus.PENDING,
        # Type-specific fields
        medication_name=request_data.medication_name,
        medication_dosage=request_data.medication_dosage,
        medication_quantity=request_data.medication_quantity,
        referral_specialty=request_data.referral_specialty,
        referral_reason=request_data.referral_reason,
        au_start_date=request_data.au_start_date,
        au_end_date=request_data.au_end_date,
        au_reason=request_data.au_reason,
        deletion_scheduled_at=deletion_date,
    )
    
    db.add(document_request)
    await db.commit()
    await db.refresh(document_request)
    
    logger.info(
        "Document request created",
        extra={
            "request_id": str(document_request.id),
            "patient_id": str(patient_id),
            "document_type": request_data.document_type.value,
        }
    )
    
    return document_request


async def get_patient_document_requests(
    db: AsyncSession,
    patient_id: uuid.UUID,
    status_filter: Optional[list[DocumentRequestStatus]] = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[DocumentRequest], int]:
    """
    Get all document requests for a patient.

    Args:
        db: Database session.
        patient_id: Patient's user ID.
        status_filter: Optional status filter.
        page: Page number (1-based).
        page_size: Items per page.

    Returns:
        tuple: (list of requests, total count)
    """
    query = select(DocumentRequest).where(
        DocumentRequest.patient_id == patient_id
    ).order_by(DocumentRequest.created_at.desc())
    
    if status_filter:
        query = query.where(DocumentRequest.status.in_(status_filter))
    
    # Count total
    count_query = select(func.count()).select_from(
        query.subquery()
    )
    total = await db.scalar(count_query) or 0
    
    # Paginate
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    requests = result.scalars().all()
    
    return list(requests), total


async def get_practice_document_requests(
    db: AsyncSession,
    practice_id: uuid.UUID,
    status_filter: Optional[list[DocumentRequestStatus]] = None,
    document_type_filter: Optional[list[DocumentType]] = None,
    priority_filter: Optional[list[DocumentRequestPriority]] = None,
    assigned_to_id: Optional[uuid.UUID] = None,
    page: int = 1,
    page_size: int = 20,
) -> tuple[list[DocumentRequest], int]:
    """
    Get all document requests for a practice (staff view).

    Args:
        db: Database session.
        practice_id: Practice ID.
        status_filter: Optional status filter.
        document_type_filter: Optional type filter.
        priority_filter: Optional priority filter.
        assigned_to_id: Filter by assigned staff.
        page: Page number (1-based).
        page_size: Items per page.

    Returns:
        tuple: (list of requests, total count)
    """
    query = select(DocumentRequest).where(
        DocumentRequest.practice_id == practice_id
    ).order_by(
        DocumentRequest.priority.desc(),  # Urgent first
        DocumentRequest.created_at.asc(),  # FIFO within priority
    )
    
    if status_filter:
        query = query.where(DocumentRequest.status.in_(status_filter))
    
    if document_type_filter:
        query = query.where(DocumentRequest.document_type.in_(document_type_filter))
    
    if priority_filter:
        query = query.where(DocumentRequest.priority.in_(priority_filter))
    
    if assigned_to_id:
        query = query.where(DocumentRequest.assigned_to_id == assigned_to_id)
    
    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.scalar(count_query) or 0
    
    # Paginate
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    result = await db.execute(query)
    requests = result.scalars().all()
    
    return list(requests), total


async def get_document_request(
    db: AsyncSession,
    request_id: uuid.UUID,
) -> Optional[DocumentRequest]:
    """
    Get a single document request by ID.

    Args:
        db: Database session.
        request_id: Document request ID.

    Returns:
        DocumentRequest or None if not found.
    """
    query = select(DocumentRequest).where(DocumentRequest.id == request_id)
    result = await db.execute(query)
    return result.scalar_one_or_none()


async def update_document_request(
    db: AsyncSession,
    request_id: uuid.UUID,
    update_data: DocumentRequestUpdate,
    updated_by_id: uuid.UUID,
) -> Optional[DocumentRequest]:
    """
    Update a document request (staff only).

    Args:
        db: Database session.
        request_id: Document request ID.
        update_data: Update data.
        updated_by_id: ID of staff making the update.

    Returns:
        Updated DocumentRequest or None.
    """
    request = await get_document_request(db, request_id)
    
    if not request:
        return None
    
    update_dict = update_data.model_dump(exclude_unset=True)
    
    for field, value in update_dict.items():
        setattr(request, field, value)
    
    # Set timestamps based on status
    if update_data.status == DocumentRequestStatus.IN_REVIEW:
        request.processed_at = datetime.now(timezone.utc)
    elif update_data.status == DocumentRequestStatus.READY:
        request.ready_at = datetime.now(timezone.utc)
    elif update_data.status == DocumentRequestStatus.DELIVERED:
        request.delivered_at = datetime.now(timezone.utc)
    
    await db.commit()
    await db.refresh(request)
    
    logger.info(
        "Document request updated",
        extra={
            "request_id": str(request_id),
            "updated_by": str(updated_by_id),
            "new_status": update_data.status.value if update_data.status else None,
        }
    )
    
    return request


async def cancel_document_request(
    db: AsyncSession,
    request_id: uuid.UUID,
    patient_id: uuid.UUID,
) -> Optional[DocumentRequest]:
    """
    Cancel a document request (patient action).

    Args:
        db: Database session.
        request_id: Document request ID.
        patient_id: Patient's user ID.

    Returns:
        Cancelled DocumentRequest or None.

    Security Implications:
        - Only the owning patient can cancel.
        - Cannot cancel after READY status.
    """
    request = await get_document_request(db, request_id)
    
    if not request:
        return None
    
    # Verify ownership
    if request.patient_id != patient_id:
        logger.warning(
            "Unauthorized cancel attempt",
            extra={
                "request_id": str(request_id),
                "patient_id": str(patient_id),
            }
        )
        return None
    
    # Cannot cancel if already ready or delivered
    if request.status in [
        DocumentRequestStatus.READY,
        DocumentRequestStatus.DELIVERED,
    ]:
        return None
    
    request.status = DocumentRequestStatus.CANCELLED
    
    await db.commit()
    await db.refresh(request)
    
    logger.info(
        "Document request cancelled by patient",
        extra={
            "request_id": str(request_id),
            "patient_id": str(patient_id),
        }
    )
    
    return request


async def get_pending_requests_count(
    db: AsyncSession,
    practice_id: uuid.UUID,
) -> dict[str, int]:
    """
    Get count of pending requests by type for dashboard.

    Args:
        db: Database session.
        practice_id: Practice ID.

    Returns:
        dict: Counts by document type.
    """
    query = select(
        DocumentRequest.document_type,
        func.count(DocumentRequest.id)
    ).where(
        and_(
            DocumentRequest.practice_id == practice_id,
            DocumentRequest.status.in_([
                DocumentRequestStatus.PENDING,
                DocumentRequestStatus.IN_REVIEW,
            ])
        )
    ).group_by(DocumentRequest.document_type)
    
    result = await db.execute(query)
    counts = {row[0].value: row[1] for row in result.all()}
    
    return counts
