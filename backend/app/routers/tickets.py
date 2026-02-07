"""
Tickets router.

Handles ticket CRUD and queue operations.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import Ticket, TicketStatus, User, UserRole
from app.schemas.schemas import (
    TicketCreate,
    TicketListResponse,
    PublicTicketResponse,
    TicketResponse,
    TicketUpdate,
)
from app.services.queue_service import (
    call_next_ticket,
    create_ticket,
    get_ticket_by_number,
    get_tickets_by_queue,
    update_ticket_status,
)


router = APIRouter()


@router.get("", response_model=TicketListResponse)
async def list_tickets(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    queue_id: Optional[uuid.UUID] = None,
    status_filter: Optional[TicketStatus] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
) -> TicketListResponse:
    """
    List tickets with filters.

    Args:
        db: Database session.
        current_user: Authenticated user.
        queue_id: Optional queue filter.
        status_filter: Optional status filter.
        page: Page number.
        page_size: Items per page.

    Returns:
        TicketListResponse: Paginated list of tickets.
    """
    if not queue_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="queue_id ist erforderlich",
        )

    offset = (page - 1) * page_size
    tickets, total = await get_tickets_by_queue(
        db, queue_id, status_filter, page_size, offset
    )

    return TicketListResponse(
        items=tickets,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/number/{ticket_number}", response_model=PublicTicketResponse)
async def get_ticket_by_display_number(
    ticket_number: str,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Ticket:
    """
    Get a ticket by its display number (public endpoint for patients).

    Args:
        ticket_number: Ticket display number (e.g., "A-001").
        db: Database session.

    Returns:
        TicketResponse: Ticket data.
    """
    ticket = await get_ticket_by_number(db, ticket_number)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.get("/{ticket_number}/status", response_model=PublicTicketResponse)
async def get_ticket_status(
    ticket_number: str,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Ticket:
    """Get ticket status by display number (public endpoint).

    Security Implications:
        - Uses PublicTicketResponse to avoid returning PII.
        - Safe for unauthenticated polling by patients.
    """
    ticket = await get_ticket_by_number(db, ticket_number)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.get("/{ticket_id}", response_model=TicketResponse)
async def get_ticket(
    ticket_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Get a specific ticket by ID.

    Args:
        ticket_id: Ticket UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: Ticket data.
    """
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.post("", response_model=TicketResponse, status_code=status.HTTP_201_CREATED)
async def create_new_ticket(
    request: TicketCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Create a new ticket in a queue.

    Args:
        request: Ticket creation data.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: Created ticket.
    """
    # Only staff can create tickets
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA, UserRole.STAFF]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Keine Berechtigung zum Erstellen von Tickets",
        )

    try:
        ticket = await create_ticket(db, request, current_user.id)
        return ticket
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.patch("/{ticket_id}", response_model=TicketResponse)
async def update_ticket(
    ticket_id: uuid.UUID,
    request: TicketUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Update a ticket.

    Args:
        ticket_id: Ticket UUID.
        request: Ticket update data.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: Updated ticket.
    """
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    update_data = request.model_dump(exclude_unset=True)

    if "status" in update_data:
        ticket = await update_ticket_status(
            db, ticket_id, update_data["status"], update_data.get("assigned_to_id")
        )
    else:
        for field, value in update_data.items():
            setattr(ticket, field, value)
        await db.commit()
        await db.refresh(ticket)

    return ticket


@router.post("/{ticket_id}/call", response_model=TicketResponse)
async def call_ticket(
    ticket_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Call a specific ticket.

    Args:
        ticket_id: Ticket UUID.
        db: Database session.
        current_user: Authenticated user (doctor/staff).

    Returns:
        TicketResponse: Called ticket.
    """
    if current_user.role not in [
        UserRole.ADMIN,
        UserRole.DOCTOR,
        UserRole.MFA,
        UserRole.STAFF,
    ]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Keine Berechtigung",
        )

    ticket = await update_ticket_status(
        db, ticket_id, TicketStatus.CALLED, current_user.id
    )

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.post("/queue/{queue_id}/call-next", response_model=TicketResponse)
async def call_next_in_queue(
    queue_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Call the next waiting ticket in a queue.

    Args:
        queue_id: Queue UUID.
        db: Database session.
        current_user: Authenticated user (doctor/staff).

    Returns:
        TicketResponse: Called ticket.
    """
    if current_user.role not in [
        UserRole.ADMIN,
        UserRole.DOCTOR,
        UserRole.MFA,
        UserRole.STAFF,
    ]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Keine Berechtigung",
        )

    ticket = await call_next_ticket(db, queue_id, current_user.id)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Keine wartenden Tickets in dieser Warteschlange",
        )

    return ticket


@router.post("/{ticket_id}/complete", response_model=TicketResponse)
async def complete_ticket(
    ticket_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Mark a ticket as completed.

    Args:
        ticket_id: Ticket UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: Completed ticket.
    """
    ticket = await update_ticket_status(db, ticket_id, TicketStatus.COMPLETED)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.post("/{ticket_id}/cancel", response_model=TicketResponse)
async def cancel_ticket(
    ticket_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Cancel a ticket.

    Args:
        ticket_id: Ticket UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: Cancelled ticket.
    """
    ticket = await update_ticket_status(db, ticket_id, TicketStatus.CANCELLED)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket


@router.post("/{ticket_id}/no-show", response_model=TicketResponse)
async def mark_no_show(
    ticket_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Ticket:
    """
    Mark a ticket as no-show.

    Args:
        ticket_id: Ticket UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        TicketResponse: No-show ticket.
    """
    ticket = await update_ticket_status(db, ticket_id, TicketStatus.NO_SHOW)

    if not ticket:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ticket nicht gefunden",
        )

    return ticket
