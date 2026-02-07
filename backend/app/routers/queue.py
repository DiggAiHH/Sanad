"""
Queue router.

Handles queue management and statistics.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import RequireAdmin, get_current_user
from app.models.models import Queue, User
from app.schemas.schemas import (
    MessageResponse,
    PublicQueueSummaryResponse,
    QueueCreate,
    QueueResponse,
    QueueStatsResponse,
    QueueUpdate,
)
from app.services.queue_service import (
    create_queue,
    get_queue,
    get_queue_stats,
    get_public_queue_summary,
)


router = APIRouter()


@router.get("", response_model=list[QueueResponse])
async def list_queues(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    practice_id: Optional[uuid.UUID] = None,
    is_active: Optional[bool] = True,
) -> list[Queue]:
    """
    List all queues.

    Args:
        db: Database session.
        current_user: Authenticated user.
        practice_id: Optional practice filter.
        is_active: Optional active status filter.

    Returns:
        list[QueueResponse]: List of queues.
    """
    query = select(Queue)

    if practice_id:
        query = query.where(Queue.practice_id == practice_id)

    if is_active is not None:
        query = query.where(Queue.is_active == is_active)

    query = query.order_by(Queue.code)

    result = await db.execute(query)
    return list(result.scalars().all())


@router.get("/stats")
async def get_global_queue_stats(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> None:
    """Placeholder global stats endpoint.

    Security Implications:
        - Keeps routing predictable (avoids treating "stats" as queue_id).
        - Does not disclose any data without a clear contract.
    """
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Nicht implementiert",
    )


@router.get("/public/summary", response_model=PublicQueueSummaryResponse)
async def get_public_queue_summary_endpoint(
    db: Annotated[AsyncSession, Depends(get_db)],
    practice_id: Optional[uuid.UUID] = None,
) -> PublicQueueSummaryResponse:
    """
    Get public queue summary for patient-facing screens.

    Args:
        db: Database session.
        practice_id: Optional practice UUID for filtering.

    Returns:
        PublicQueueSummaryResponse: Public summary data.

    Raises:
        HTTPException: If no active practice is found.

    Security Implications:
        - Returns aggregated queue stats without PII.
        - Safe for unauthenticated access by patients.
    """
    try:
        return await get_public_queue_summary(db, practice_id)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        )


@router.get("/{queue_id}", response_model=QueueResponse)
async def get_queue_by_id(
    queue_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Queue:
    """
    Get a specific queue by ID.

    Args:
        queue_id: Queue UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        QueueResponse: Queue data.
    """
    queue = await get_queue(db, queue_id)

    if not queue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Warteschlange nicht gefunden",
        )

    return queue


@router.get("/{queue_id}/stats", response_model=QueueStatsResponse)
async def get_queue_statistics(
    queue_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> QueueStatsResponse:
    """
    Get statistics for a queue.

    Args:
        queue_id: Queue UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        QueueStatsResponse: Queue statistics.
    """
    try:
        return await get_queue_stats(db, queue_id)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.post(
    "",
    response_model=QueueResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[RequireAdmin],
)
async def create_new_queue(
    request: QueueCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Queue:
    """
    Create a new queue (admin only).

    Args:
        request: Queue creation data.
        db: Database session.

    Returns:
        QueueResponse: Created queue.
    """
    return await create_queue(db, request)


@router.patch("/{queue_id}", response_model=QueueResponse, dependencies=[RequireAdmin])
async def update_queue(
    queue_id: uuid.UUID,
    request: QueueUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Queue:
    """
    Update a queue (admin only).

    Args:
        queue_id: Queue UUID.
        request: Queue update data.
        db: Database session.

    Returns:
        QueueResponse: Updated queue.
    """
    queue = await get_queue(db, queue_id)

    if not queue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Warteschlange nicht gefunden",
        )

    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(queue, field, value)

    await db.commit()
    await db.refresh(queue)
    return queue


@router.delete(
    "/{queue_id}", response_model=MessageResponse, dependencies=[RequireAdmin]
)
async def delete_queue(
    queue_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> MessageResponse:
    """
    Deactivate a queue (admin only).

    Args:
        queue_id: Queue UUID.
        db: Database session.

    Returns:
        MessageResponse: Deletion confirmation.
    """
    queue = await get_queue(db, queue_id)

    if not queue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Warteschlange nicht gefunden",
        )

    queue.is_active = False
    await db.commit()

    return MessageResponse(message="Warteschlange erfolgreich deaktiviert")


@router.post(
    "/{queue_id}/reset", response_model=QueueResponse, dependencies=[RequireAdmin]
)
async def reset_queue_counter(
    queue_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Queue:
    """
    Reset queue counter to 0 (admin only).

    Typically used at the start of a new day.

    Args:
        queue_id: Queue UUID.
        db: Database session.

    Returns:
        QueueResponse: Updated queue.
    """
    queue = await get_queue(db, queue_id)

    if not queue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Warteschlange nicht gefunden",
        )

    queue.current_number = 0
    await db.commit()
    await db.refresh(queue)

    return queue
