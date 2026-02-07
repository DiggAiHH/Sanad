"""
Users router.

Handles user CRUD operations.
"""

import uuid
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import RequireAdmin, get_current_user
from app.models.models import User, UserRole
from app.schemas.schemas import (
    MessageResponse,
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.services.auth_service import create_user


router = APIRouter()


@router.get("", response_model=UserListResponse)
async def list_users(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    role: Optional[UserRole] = None,
    search: Optional[str] = None,
    is_active: Optional[bool] = None,
) -> UserListResponse:
    """
    List all users with pagination and filters.

    Args:
        db: Database session.
        current_user: Authenticated user.
        page: Page number (1-indexed).
        page_size: Items per page.
        role: Optional role filter.
        search: Optional search term for name/email.
        is_active: Optional active status filter.

    Returns:
        UserListResponse: Paginated list of users.
    """
    # Staff can only see users, admins see all
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

    query = select(User)
    count_query = select(func.count(User.id))

    # Apply filters
    if role:
        query = query.where(User.role == role)
        count_query = count_query.where(User.role == role)

    if is_active is not None:
        query = query.where(User.is_active == is_active)
        count_query = count_query.where(User.is_active == is_active)

    if search:
        search_term = f"%{search}%"
        search_filter = (
            User.email.ilike(search_term)
            | User.first_name.ilike(search_term)
            | User.last_name.ilike(search_term)
        )
        query = query.where(search_filter)
        count_query = count_query.where(search_filter)

    # Get total count
    count_result = await db.execute(count_query)
    total = count_result.scalar() or 0

    # Apply pagination
    offset = (page - 1) * page_size
    query = query.order_by(User.created_at.desc()).limit(page_size).offset(offset)

    result = await db.execute(query)
    users = list(result.scalars().all())

    return UserListResponse(
        items=users,
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Return the currently authenticated user."""
    return current_user


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """
    Get a specific user by ID.

    Args:
        user_id: User UUID.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        UserResponse: User data.

    Raises:
        HTTPException: If user not found.
    """
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Benutzer nicht gefunden",
        )

    return user


@router.post(
    "",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[RequireAdmin],
)
async def create_new_user(
    request: UserCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """
    Create a new user (admin only).

    Args:
        request: User creation data.
        db: Database session.

    Returns:
        UserResponse: Created user.
    """
    try:
        user = await create_user(
            db=db,
            email=request.email,
            password=request.password,
            first_name=request.first_name,
            last_name=request.last_name,
            role=request.role,
            phone=request.phone,
        )
        return user
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.patch("/{user_id}", response_model=UserResponse, dependencies=[RequireAdmin])
async def update_user(
    user_id: uuid.UUID,
    request: UserUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """
    Update a user (admin only).

    Args:
        user_id: User UUID.
        request: User update data.
        db: Database session.

    Returns:
        UserResponse: Updated user.
    """
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Benutzer nicht gefunden",
        )

    # Update fields
    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    await db.commit()
    await db.refresh(user)
    return user


@router.delete(
    "/{user_id}", response_model=MessageResponse, dependencies=[RequireAdmin]
)
async def delete_user(
    user_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Deactivate a user (admin only).

    Note: Users are soft-deleted (deactivated) for audit purposes.

    Args:
        user_id: User UUID.
        db: Database session.
        current_user: Authenticated admin.

    Returns:
        MessageResponse: Deletion confirmation.
    """
    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Eigenes Konto kann nicht gelöscht werden",
        )

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Benutzer nicht gefunden",
        )

    user.is_active = False
    await db.commit()

    return MessageResponse(message="Benutzer erfolgreich deaktiviert")


@router.get("/role/{role}", response_model=list[UserResponse])
async def get_users_by_role(
    role: UserRole,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
) -> list[User]:
    """
    Get all active users with a specific role.

    Args:
        role: User role.
        db: Database session.
        current_user: Authenticated user.

    Returns:
        list[UserResponse]: Users with the specified role.
    """
    result = await db.execute(
        select(User)
        .where(User.role == role)
        .where(User.is_active.is_(True))
        .order_by(User.last_name, User.first_name)
    )
    return list(result.scalars().all())
