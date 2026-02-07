"""
Authentication dependencies for route protection.

Security:
    - All protected routes require valid JWT.
    - Role-based access control via dependencies.
"""

import uuid
from typing import Annotated, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.models import User, UserRole
from app.services.auth_service import decode_token


security = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Annotated[Optional[HTTPAuthorizationCredentials], Depends(security)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User:
    """
    Get the current authenticated user from JWT token.

    Args:
        credentials: HTTP Bearer token.
        db: Database session.

    Returns:
        User: Authenticated user.

    Raises:
        HTTPException: If token is invalid or user not found.

    Security Implications:
        - Validates token signature and expiration.
        - Verifies user exists and is active.
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Nicht authentifiziert",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    payload = decode_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültiges oder abgelaufenes Token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if payload.type != "access":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültiger Token-Typ",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = uuid.UUID(payload.sub)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ungültiges Token-Format",
            headers={"WWW-Authenticate": "Bearer"},
        )

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Benutzer nicht gefunden",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Benutzer ist deaktiviert",
        )

    return user


async def get_current_user_optional(
    credentials: Annotated[
        Optional[HTTPAuthorizationCredentials], Depends(HTTPBearer(auto_error=False))
    ],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> Optional[User]:
    """
    Get the current user if authenticated, otherwise None.

    Args:
        credentials: Optional HTTP Bearer token.
        db: Database session.

    Returns:
        User: Authenticated user or None.
    """
    if not credentials:
        return None

    try:
        return await get_current_user(credentials, db)
    except HTTPException:
        return None


def require_role(*roles: UserRole):
    """
    Dependency factory for role-based access control.

    Args:
        *roles: Allowed roles.

    Returns:
        Dependency function.

    Example:
        @router.get("/admin", dependencies=[Depends(require_role(UserRole.ADMIN))])
    """

    async def role_checker(
        current_user: Annotated[User, Depends(get_current_user)]
    ) -> User:
        if current_user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Keine Berechtigung für diese Aktion",
            )
        return current_user

    return role_checker


def require_roles(*roles: UserRole):
    """
    Backwards-compatible alias for require_role.

    Args:
        *roles: Allowed roles.

    Returns:
        Dependency function.

    Security Implications:
        - Ensures role checks are consistently applied.
    """
    return require_role(*roles)


# Pre-defined role dependencies
RequireAdmin = Depends(require_role(UserRole.ADMIN))
RequireDoctor = Depends(require_role(UserRole.ADMIN, UserRole.DOCTOR))
RequireStaff = Depends(
    require_role(UserRole.ADMIN, UserRole.DOCTOR, UserRole.MFA, UserRole.STAFF)
)
RequireMFA = Depends(require_role(UserRole.ADMIN, UserRole.MFA))
