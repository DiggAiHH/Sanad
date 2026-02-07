"""
Document Request Router.

API endpoints for patient document requests (Rezept, AU, Überweisung etc.).

Security:
    - Patients can only access their own requests.
    - Staff endpoints require appropriate role.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, require_roles
from app.models.models import User, UserRole
from app.models.document_request import (
    DocumentType,
    DocumentRequestStatus,
    DocumentRequestPriority,
)
from app.schemas.document_request_schemas import (
    DocumentRequestCreate,
    DocumentRequestUpdate,
    DocumentRequestResponse,
    DocumentRequestStaffResponse,
    DocumentRequestListResponse,
    DocumentRequestStaffListResponse,
    QuickRezeptRequest,
    QuickAURequest,
    QuickUeberweisungRequest,
)
from app.schemas.schemas import MessageResponse
from app.services.document_request_service import (
    create_document_request,
    get_patient_document_requests,
    get_practice_document_requests,
    get_document_request,
    update_document_request,
    cancel_document_request,
    get_pending_requests_count,
)


router = APIRouter()


# =============================================================================
# Patient Endpoints
# =============================================================================


@router.post(
    "/",
    response_model=DocumentRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_request(
    request_data: DocumentRequestCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Create a new document request.

    Patients can request:
    - Rezept (prescription)
    - Überweisung (referral)
    - AU-Bescheinigung (sick note)
    - And other documents

    Args:
        request_data: Document request details.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Created request.
    """
    # TODO: Get practice_id from user's registration or settings
    # For now, use a default practice (first one)
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    document_request = await create_document_request(
        db=db,
        patient_id=current_user.id,
        practice_id=practice.id,
        request_data=request_data,
    )
    
    return DocumentRequestResponse.model_validate(document_request)


@router.post(
    "/quick/rezept",
    response_model=DocumentRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
async def quick_rezept_request(
    request_data: QuickRezeptRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Quick prescription request with simplified form.

    Args:
        request_data: Medication details.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Created request.
    """
    full_request = DocumentRequestCreate(
        document_type=DocumentType.REZEPT,
        title=f"Rezept: {request_data.medication_name}",
        description=request_data.notes,
        priority=request_data.priority,
        medication_name=request_data.medication_name,
        medication_dosage=request_data.medication_dosage,
        medication_quantity=request_data.medication_quantity,
    )
    
    # Reuse main create endpoint logic
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    document_request = await create_document_request(
        db=db,
        patient_id=current_user.id,
        practice_id=practice.id,
        request_data=full_request,
    )
    
    return DocumentRequestResponse.model_validate(document_request)


@router.post(
    "/quick/au",
    response_model=DocumentRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
async def quick_au_request(
    request_data: QuickAURequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Quick sick note request.

    Args:
        request_data: AU details.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Created request.
    """
    full_request = DocumentRequestCreate(
        document_type=DocumentType.AU_BESCHEINIGUNG,
        title=f"AU-Bescheinigung ({request_data.start_date.strftime('%d.%m')} - {request_data.end_date.strftime('%d.%m.%Y')})",
        priority=request_data.priority,
        au_start_date=request_data.start_date,
        au_end_date=request_data.end_date,
        au_reason=request_data.symptoms_description,
    )
    
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    document_request = await create_document_request(
        db=db,
        patient_id=current_user.id,
        practice_id=practice.id,
        request_data=full_request,
    )
    
    return DocumentRequestResponse.model_validate(document_request)


@router.post(
    "/quick/ueberweisung",
    response_model=DocumentRequestResponse,
    status_code=status.HTTP_201_CREATED,
)
async def quick_ueberweisung_request(
    request_data: QuickUeberweisungRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Quick referral request.

    Args:
        request_data: Referral details.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Created request.
    """
    full_request = DocumentRequestCreate(
        document_type=DocumentType.UEBERWEISUNG,
        title=f"Überweisung: {request_data.specialty}",
        priority=request_data.priority,
        referral_specialty=request_data.specialty,
        referral_reason=request_data.reason,
    )
    
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    document_request = await create_document_request(
        db=db,
        patient_id=current_user.id,
        practice_id=practice.id,
        request_data=full_request,
    )
    
    return DocumentRequestResponse.model_validate(document_request)


@router.get("/my-requests", response_model=DocumentRequestListResponse)
async def list_my_requests(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    status_filter: Annotated[
        Optional[list[DocumentRequestStatus]], Query(alias="status")
    ] = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
) -> DocumentRequestListResponse:
    """
    List my document requests.

    Args:
        db: Database session.
        current_user: Authenticated patient.
        status_filter: Optional status filter.
        page: Page number.
        page_size: Items per page.

    Returns:
        DocumentRequestListResponse: Paginated list.
    """
    requests, total = await get_patient_document_requests(
        db=db,
        patient_id=current_user.id,
        status_filter=status_filter,
        page=page,
        page_size=page_size,
    )
    
    return DocumentRequestListResponse(
        items=[DocumentRequestResponse.model_validate(r) for r in requests],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/my-requests/{request_id}", response_model=DocumentRequestResponse)
async def get_my_request(
    request_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Get a specific document request.

    Args:
        request_id: Request ID.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Request details.
    """
    document_request = await get_document_request(db, request_id)
    
    if not document_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anfrage nicht gefunden",
        )
    
    # Verify ownership
    if document_request.patient_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Kein Zugriff auf diese Anfrage",
        )
    
    return DocumentRequestResponse.model_validate(document_request)


@router.post("/my-requests/{request_id}/cancel", response_model=DocumentRequestResponse)
async def cancel_my_request(
    request_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> DocumentRequestResponse:
    """
    Cancel a document request.

    Only pending requests can be cancelled.

    Args:
        request_id: Request ID.
        db: Database session.
        current_user: Authenticated patient.

    Returns:
        DocumentRequestResponse: Cancelled request.
    """
    document_request = await cancel_document_request(
        db=db,
        request_id=request_id,
        patient_id=current_user.id,
    )
    
    if not document_request:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Anfrage kann nicht storniert werden",
        )
    
    return DocumentRequestResponse.model_validate(document_request)


# =============================================================================
# Staff Endpoints
# =============================================================================


@router.get("/staff/all", response_model=DocumentRequestStaffListResponse)
async def list_all_requests(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User, 
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
    status_filter: Annotated[
        Optional[list[DocumentRequestStatus]], Query(alias="status")
    ] = None,
    type_filter: Annotated[
        Optional[list[DocumentType]], Query(alias="type")
    ] = None,
    priority_filter: Annotated[
        Optional[list[DocumentRequestPriority]], Query(alias="priority")
    ] = None,
    assigned_to: Annotated[Optional[uuid.UUID], Query()] = None,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
) -> DocumentRequestStaffListResponse:
    """
    List all document requests (staff view).

    Args:
        db: Database session.
        current_user: Authenticated staff member.
        status_filter: Optional status filter.
        type_filter: Optional type filter.
        priority_filter: Optional priority filter.
        assigned_to: Filter by assigned staff.
        page: Page number.
        page_size: Items per page.

    Returns:
        DocumentRequestStaffListResponse: Paginated list with internal fields.
    """
    # Get practice ID (TODO: from user's practice assignment)
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine Praxis gefunden",
        )
    
    requests, total = await get_practice_document_requests(
        db=db,
        practice_id=practice.id,
        status_filter=status_filter,
        document_type_filter=type_filter,
        priority_filter=priority_filter,
        assigned_to_id=assigned_to,
        page=page,
        page_size=page_size,
    )
    
    return DocumentRequestStaffListResponse(
        items=[DocumentRequestStaffResponse.model_validate(r) for r in requests],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/staff/{request_id}", response_model=DocumentRequestStaffResponse)
async def get_request_staff(
    request_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User, 
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
) -> DocumentRequestStaffResponse:
    """
    Get a document request (staff view).

    Args:
        request_id: Request ID.
        db: Database session.
        current_user: Authenticated staff.

    Returns:
        DocumentRequestStaffResponse: Full request details.
    """
    document_request = await get_document_request(db, request_id)
    
    if not document_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anfrage nicht gefunden",
        )
    
    return DocumentRequestStaffResponse.model_validate(document_request)


@router.patch("/staff/{request_id}", response_model=DocumentRequestStaffResponse)
async def update_request_staff(
    request_id: uuid.UUID,
    update_data: DocumentRequestUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User, 
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
) -> DocumentRequestStaffResponse:
    """
    Update a document request (staff action).

    Args:
        request_id: Request ID.
        update_data: Update data.
        db: Database session.
        current_user: Authenticated staff.

    Returns:
        DocumentRequestStaffResponse: Updated request.
    """
    document_request = await update_document_request(
        db=db,
        request_id=request_id,
        update_data=update_data,
        updated_by_id=current_user.id,
    )
    
    if not document_request:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Anfrage nicht gefunden",
        )
    
    return DocumentRequestStaffResponse.model_validate(document_request)


@router.get("/staff/stats/pending", response_model=dict)
async def get_pending_stats(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[
        User, 
        Depends(require_roles([UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA]))
    ],
) -> dict:
    """
    Get counts of pending requests by type.

    Args:
        db: Database session.
        current_user: Authenticated staff.

    Returns:
        dict: Counts by document type.
    """
    from sqlalchemy import select
    from app.models.models import Practice
    
    result = await db.execute(select(Practice).limit(1))
    practice = result.scalar_one_or_none()
    
    if not practice:
        return {}
    
    counts = await get_pending_requests_count(db, practice.id)
    
    return counts
