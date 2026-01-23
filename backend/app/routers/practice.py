"""
Practice router.

Handles practice/clinic configuration.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import RequireAdmin, get_current_user
from app.models.models import Practice, User
from app.schemas.schemas import (
    MessageResponse,
    PublicPracticeResponse,
    PracticeCreate,
    PracticeResponse,
    PracticeUpdate,
)


router = APIRouter()


@router.get("", response_model=list[PracticeResponse])
async def list_practices(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    is_active: Optional[bool] = True,
) -> list[Practice]:
    """
    List all practices.

    Args:
        db: Database session.
        current_user: Authenticated user.
        is_active: Optional active status filter.

    Returns:
        list[PracticeResponse]: List of practices.
    """
    query = select(Practice)

    if is_active is not None:
        query = query.where(Practice.is_active == is_active)

    query = query.order_by(Practice.name)

    result = await db.execute(query)
    return list(result.scalars().all())


@router.get("/public/default", response_model=PublicPracticeResponse)
async def get_public_practice(
    db: Annotated[AsyncSession, Depends(get_db)],
    practice_id: Optional[uuid.UUID] = None,
) -> Practice:
    """
    Get public practice information for patient apps.

    Args:
        db: Database session.
        practice_id: Optional practice UUID for lookup.

    Returns:
        PublicPracticeResponse: Public practice details.

    Raises:
        HTTPException: If no active practice is found.

    Security Implications:
        - Returns only public-facing practice fields.
        - Safe for unauthenticated access by patients.
    """
    query = select(Practice).where(Practice.is_active.is_(True))
    if practice_id:
        query = query.where(Practice.id == practice_id)
    query = query.order_by(Practice.name)
    result = await db.execute(query)
    practice = result.scalars().first()

    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Praxis nicht gefunden",
        )

    return practice


@router.get("/{practice_id}", response_model=PracticeResponse)
async def get_practice(
    practice_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> Practice:
    """
    Get a specific practice by ID.

    Args:
        practice_id: Practice UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        PracticeResponse: Practice data.
    """
    result = await db.execute(select(Practice).where(Practice.id == practice_id))
    practice = result.scalar_one_or_none()

    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Praxis nicht gefunden",
        )

    return practice


@router.post(
    "",
    response_model=PracticeResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[RequireAdmin],
)
async def create_practice(
    request: PracticeCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Practice:
    """
    Create a new practice (admin only).

    Args:
        request: Practice creation data.
        db: Database session.

    Returns:
        PracticeResponse: Created practice.
    """
    practice = Practice(
        name=request.name,
        address=request.address,
        phone=request.phone,
        email=request.email,
        website=request.website,
        opening_hours=request.opening_hours,
        max_daily_tickets=request.max_daily_tickets,
        average_wait_time_minutes=request.average_wait_time_minutes,
    )
    db.add(practice)
    await db.commit()
    await db.refresh(practice)
    return practice


@router.patch(
    "/{practice_id}", response_model=PracticeResponse, dependencies=[RequireAdmin]
)
async def update_practice(
    practice_id: uuid.UUID,
    request: PracticeUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Practice:
    """
    Update a practice (admin only).

    Args:
        practice_id: Practice UUID.
        request: Practice update data.
        db: Database session.

    Returns:
        PracticeResponse: Updated practice.
    """
    result = await db.execute(select(Practice).where(Practice.id == practice_id))
    practice = result.scalar_one_or_none()

    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Praxis nicht gefunden",
        )

    update_data = request.model_dump(exclude_unset=True)
    if "website" in update_data and update_data["website"] is not None:
        update_data["website"] = str(update_data["website"])
    for field, value in update_data.items():
        setattr(practice, field, value)

    await db.commit()
    await db.refresh(practice)
    return practice


@router.delete(
    "/{practice_id}", response_model=MessageResponse, dependencies=[RequireAdmin]
)
async def delete_practice(
    practice_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> MessageResponse:
    """
    Deactivate a practice (admin only).

    Args:
        practice_id: Practice UUID.
        db: Database session.

    Returns:
        MessageResponse: Deletion confirmation.
    """
    result = await db.execute(select(Practice).where(Practice.id == practice_id))
    practice = result.scalar_one_or_none()

    if not practice:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Praxis nicht gefunden",
        )

    practice.is_active = False
    await db.commit()

    return MessageResponse(message="Praxis erfolgreich deaktiviert")
