"""
Queue management service.

Handles ticket creation, queue statistics, and wait time calculations.
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import Practice, Queue, Ticket, TicketStatus
from app.schemas.schemas import (
    PublicQueueSummaryItem,
    PublicQueueSummaryResponse,
    QueueCreate,
    QueueStatsResponse,
    TicketCreate,
)


async def get_queue(db: AsyncSession, queue_id: uuid.UUID) -> Optional[Queue]:
    """
    Get a queue by ID.

    Args:
        db: Database session.
        queue_id: Queue UUID.

    Returns:
        Queue: Queue object or None.
    """
    result = await db.execute(select(Queue).where(Queue.id == queue_id))
    return result.scalar_one_or_none()


async def get_queues_by_practice(
    db: AsyncSession, practice_id: uuid.UUID
) -> list[Queue]:
    """
    Get all queues for a practice.

    Args:
        db: Database session.
        practice_id: Practice UUID.

    Returns:
        list[Queue]: List of queues.
    """
    result = await db.execute(
        select(Queue)
        .where(Queue.practice_id == practice_id)
        .where(Queue.is_active.is_(True))
        .order_by(Queue.code)
    )
    return list(result.scalars().all())


async def create_queue(db: AsyncSession, queue_data: QueueCreate) -> Queue:
    """
    Create a new queue.

    Args:
        db: Database session.
        queue_data: Queue creation data.

    Returns:
        Queue: Created queue.
    """
    queue = Queue(
        practice_id=queue_data.practice_id,
        name=queue_data.name,
        code=queue_data.code.upper(),
        description=queue_data.description,
        color=queue_data.color,
        average_wait_minutes=queue_data.average_wait_minutes,
    )
    db.add(queue)
    await db.commit()
    await db.refresh(queue)
    return queue


async def get_queue_stats(db: AsyncSession, queue_id: uuid.UUID) -> QueueStatsResponse:
    """
    Get statistics for a queue.

    Args:
        db: Database session.
        queue_id: Queue UUID.

    Returns:
        QueueStatsResponse: Queue statistics.
    """
    queue = await get_queue(db, queue_id)
    if not queue:
        raise ValueError("Queue not found")

    today_start = datetime.now(timezone.utc).replace(
        hour=0, minute=0, second=0, microsecond=0
    )

    # Count waiting tickets
    waiting_result = await db.execute(
        select(func.count(Ticket.id))
        .where(Ticket.queue_id == queue_id)
        .where(Ticket.status == TicketStatus.WAITING)
    )
    waiting_count = waiting_result.scalar() or 0

    # Count in-progress tickets
    in_progress_result = await db.execute(
        select(func.count(Ticket.id))
        .where(Ticket.queue_id == queue_id)
        .where(Ticket.status == TicketStatus.IN_PROGRESS)
    )
    in_progress_count = in_progress_result.scalar() or 0

    # Count completed today
    completed_result = await db.execute(
        select(func.count(Ticket.id))
        .where(Ticket.queue_id == queue_id)
        .where(Ticket.status == TicketStatus.COMPLETED)
        .where(Ticket.completed_at >= today_start)
    )
    completed_today = completed_result.scalar() or 0

    # Calculate average wait time
    average_wait = queue.average_wait_minutes * waiting_count

    return QueueStatsResponse(
        queue_id=queue.id,
        queue_name=queue.name,
        waiting_count=waiting_count,
        in_progress_count=in_progress_count,
        completed_today=completed_today,
        average_wait_time=average_wait,
        current_number=queue.current_number,
    )


async def get_public_queue_summary(
    db: AsyncSession,
    practice_id: Optional[uuid.UUID] = None,
) -> PublicQueueSummaryResponse:
    """
    Build a public queue summary for patient-facing screens.

    Args:
        db: Database session.
        practice_id: Optional practice UUID for filtering.

    Returns:
        PublicQueueSummaryResponse: Public summary for the selected practice.

    Raises:
        ValueError: If no active practice can be resolved.

    Security Implications:
        - Returns aggregated queue data only (no PII).
        - Excludes ticket identifiers except current display number.
    """
    practice_query = select(Practice).where(Practice.is_active.is_(True))
    if practice_id:
        practice_query = practice_query.where(Practice.id == practice_id)
    practice_query = practice_query.order_by(Practice.name)
    practice_result = await db.execute(practice_query)
    practice = practice_result.scalars().first()

    if not practice:
        raise ValueError("Practice not found")

    queues_result = await db.execute(
        select(Queue)
        .where(Queue.practice_id == practice.id)
        .where(Queue.is_active.is_(True))
        .order_by(Queue.code)
    )
    queues = list(queues_result.scalars().all())
    queue_ids = [queue.id for queue in queues]

    waiting_counts: dict[uuid.UUID, int] = {}
    if queue_ids:
        waiting_result = await db.execute(
            select(Ticket.queue_id, func.count(Ticket.id))
            .where(Ticket.queue_id.in_(queue_ids))
            .where(Ticket.status == TicketStatus.WAITING)
            .group_by(Ticket.queue_id)
        )
        waiting_counts = {row[0]: row[1] for row in waiting_result.all()}

    now_serving_ticket = None
    if queue_ids:
        now_serving_result = await db.execute(
            select(Ticket.ticket_number)
            .where(Ticket.queue_id.in_(queue_ids))
            .where(
                Ticket.status.in_(
                    [TicketStatus.CALLED, TicketStatus.IN_PROGRESS]
                )
            )
            .order_by(
                Ticket.called_at.is_(None),
                Ticket.called_at.desc(),
                Ticket.created_at.desc(),
            )
            .limit(1)
        )
        now_serving_ticket = now_serving_result.scalar_one_or_none()

    summary_items = [
        PublicQueueSummaryItem(
            queue_id=queue.id,
            name=queue.name,
            code=queue.code,
            color=queue.color,
            average_wait_minutes=queue.average_wait_minutes,
            waiting_count=waiting_counts.get(queue.id, 0),
        )
        for queue in queues
    ]

    return PublicQueueSummaryResponse(
        practice_id=practice.id,
        practice_name=practice.name,
        opening_hours=practice.opening_hours,
        average_wait_time_minutes=practice.average_wait_time_minutes,
        now_serving_ticket=now_serving_ticket,
        queues=summary_items,
        generated_at=datetime.now(timezone.utc),
    )


async def create_ticket(
    db: AsyncSession,
    ticket_data: TicketCreate,
    created_by_id: Optional[uuid.UUID] = None,
) -> Ticket:
    """
    Create a new ticket in the queue.

    Args:
        db: Database session.
        ticket_data: Ticket creation data.
        created_by_id: ID of the user creating the ticket.

    Returns:
        Ticket: Created ticket.

    Raises:
        ValueError: If queue not found.
    """
    queue = await get_queue(db, ticket_data.queue_id)
    if not queue:
        raise ValueError("Queue not found")

    # Increment queue number
    queue.current_number += 1
    ticket_number = f"{queue.code}-{queue.current_number:03d}"

    # Calculate estimated wait time
    stats = await get_queue_stats(db, queue.id)
    estimated_wait = queue.average_wait_minutes * (stats.waiting_count + 1)

    ticket = Ticket(
        queue_id=queue.id,
        ticket_number=ticket_number,
        patient_name=ticket_data.patient_name,
        patient_phone=ticket_data.patient_phone,
        priority=ticket_data.priority,
        notes=ticket_data.notes,
        estimated_wait_minutes=estimated_wait,
        created_by_id=created_by_id,
    )
    db.add(ticket)
    await db.commit()
    await db.refresh(ticket)
    return ticket


async def get_tickets_by_queue(
    db: AsyncSession,
    queue_id: uuid.UUID,
    status: Optional[TicketStatus] = None,
    limit: int = 50,
    offset: int = 0,
) -> tuple[list[Ticket], int]:
    """
    Get tickets for a queue with optional status filter.

    Args:
        db: Database session.
        queue_id: Queue UUID.
        status: Optional status filter.
        limit: Maximum number of results.
        offset: Number of results to skip.

    Returns:
        tuple: List of tickets and total count.
    """
    query = select(Ticket).where(Ticket.queue_id == queue_id)
    count_query = select(func.count(Ticket.id)).where(Ticket.queue_id == queue_id)

    if status:
        query = query.where(Ticket.status == status)
        count_query = count_query.where(Ticket.status == status)

    # Order by priority (emergency first) then by creation time
    query = (
        query.order_by(
            Ticket.priority.desc(),
            Ticket.created_at.asc(),
        )
        .limit(limit)
        .offset(offset)
    )

    result = await db.execute(query)
    tickets = list(result.scalars().all())

    count_result = await db.execute(count_query)
    total = count_result.scalar() or 0

    return tickets, total


async def update_ticket_status(
    db: AsyncSession,
    ticket_id: uuid.UUID,
    status: TicketStatus,
    assigned_to_id: Optional[uuid.UUID] = None,
) -> Optional[Ticket]:
    """
    Update ticket status.

    Args:
        db: Database session.
        ticket_id: Ticket UUID.
        status: New status.
        assigned_to_id: Optional assigned user ID.

    Returns:
        Ticket: Updated ticket or None.
    """
    result = await db.execute(select(Ticket).where(Ticket.id == ticket_id))
    ticket = result.scalar_one_or_none()

    if not ticket:
        return None

    ticket.status = status

    if assigned_to_id:
        ticket.assigned_to_id = assigned_to_id

    if status == TicketStatus.CALLED:
        ticket.called_at = datetime.now(timezone.utc)
    elif status == TicketStatus.COMPLETED:
        ticket.completed_at = datetime.now(timezone.utc)

    await db.commit()
    await db.refresh(ticket)
    return ticket


async def get_ticket_by_number(
    db: AsyncSession, ticket_number: str
) -> Optional[Ticket]:
    """
    Get a ticket by its display number.

    Args:
        db: Database session.
        ticket_number: Ticket display number (e.g., "A-001").

    Returns:
        Ticket: Ticket object or None.
    """
    result = await db.execute(
        select(Ticket).where(Ticket.ticket_number == ticket_number.upper())
    )
    return result.scalar_one_or_none()


async def call_next_ticket(
    db: AsyncSession, queue_id: uuid.UUID, assigned_to_id: uuid.UUID
) -> Optional[Ticket]:
    """
    Call the next waiting ticket in a queue.

    Args:
        db: Database session.
        queue_id: Queue UUID.
        assigned_to_id: ID of the user calling the ticket.

    Returns:
        Ticket: Called ticket or None if queue empty.
    """
    # Get next waiting ticket (priority order)
    result = await db.execute(
        select(Ticket)
        .where(Ticket.queue_id == queue_id)
        .where(Ticket.status == TicketStatus.WAITING)
        .order_by(Ticket.priority.desc(), Ticket.created_at.asc())
        .limit(1)
    )
    ticket = result.scalar_one_or_none()

    if not ticket:
        return None

    return await update_ticket_status(
        db, ticket.id, TicketStatus.CALLED, assigned_to_id
    )
