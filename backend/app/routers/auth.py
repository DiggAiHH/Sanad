"""
Authentication router.

Handles login, logout, token refresh, and registration.
"""

from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import User
from app.schemas.schemas import (
    LoginRequest,
    MessageResponse,
    RefreshTokenRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
)
from app.services.auth_service import (
    authenticate_user,
    create_access_token,
    create_user,
    decode_token,
    generate_tokens,
)


router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TokenResponse:
    """
    Authenticate user and return JWT tokens.
    
    Args:
        request: Login credentials.
        db: Database session.
        
    Returns:
        TokenResponse: Access and refresh tokens.
        
    Raises:
        HTTPException: If credentials are invalid.
    """
    user = await authenticate_user(db, request.email, request.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültige E-Mail oder Passwort",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Update last login
    user.last_login = datetime.now(timezone.utc)
    await db.commit()
    
    return generate_tokens(user)


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    request: UserCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """
    Register a new user.
    
    Args:
        request: User registration data.
        db: Database session.
        
    Returns:
        UserResponse: Created user.
        
    Raises:
        HTTPException: If email already exists.
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


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    request: RefreshTokenRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> TokenResponse:
    """
    Refresh access token using refresh token.
    
    Args:
        request: Refresh token.
        db: Database session.
        
    Returns:
        TokenResponse: New access and refresh tokens.
        
    Raises:
        HTTPException: If refresh token is invalid.
    """
    payload = decode_token(request.refresh_token)
    
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültiges oder abgelaufenes Refresh-Token",
        )

    if payload.type != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültiger Token-Typ",
        )
    
    # Get user
    from uuid import UUID
    result = await db.execute(select(User).where(User.id == UUID(payload.sub)))
    user = result.scalar_one_or_none()
    
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Benutzer nicht gefunden oder deaktiviert",
        )
    
    return generate_tokens(user)


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """
    Get current authenticated user information.
    
    Args:
        current_user: Authenticated user from token.
        
    Returns:
        UserResponse: Current user data.
    """
    return current_user


@router.post("/logout", response_model=MessageResponse)
async def logout(
    current_user: Annotated[User, Depends(get_current_user)],
) -> MessageResponse:
    """
    Logout current user.
    
    Note: JWT tokens are stateless, so logout is handled client-side.
    This endpoint is for audit logging purposes.
    
    Args:
        current_user: Authenticated user.
        
    Returns:
        MessageResponse: Logout confirmation.
    """
    # In a production system, you would:
    # 1. Add token to a blacklist (Redis)
    # 2. Log the logout event
    return MessageResponse(message="Erfolgreich abgemeldet")
