"""
Authentication service for JWT token management.

Security:
    - Passwords hashed with bcrypt (cost factor 12).
    - Tokens signed with HS256.
    - No sensitive data in token payload.
"""

import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.models import User, UserRole
from app.schemas.schemas import TokenPayload, TokenResponse


settings = get_settings()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """
    Hash a password using bcrypt.

    Args:
        password: Plain text password.

    Returns:
        str: Bcrypt hashed password.

    Security Implications:
        - Uses bcrypt with default cost factor.
        - Resistant to rainbow table attacks.
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against a hash.

    Args:
        plain_password: Plain text password to verify.
        hashed_password: Stored bcrypt hash.

    Returns:
        bool: True if password matches.

    Security Implications:
        - Constant-time comparison prevents timing attacks.
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(user_id: uuid.UUID, role: UserRole) -> str:
    """
    Create a JWT access token.

    Args:
        user_id: User's UUID.
        role: User's role for authorization.

    Returns:
        str: Signed JWT access token.

    Security Implications:
        - Short expiration time (30 minutes default).
        - Contains only non-sensitive data (id, role).
    """
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {
        "sub": str(user_id),
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "role": role.value,
        "type": "access",
    }
    return jwt.encode(
        payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM
    )


def create_refresh_token(user_id: uuid.UUID) -> str:
    """
    Create a JWT refresh token.

    Args:
        user_id: User's UUID.

    Returns:
        str: Signed JWT refresh token.

    Security Implications:
        - Longer expiration (7 days default).
        - Should be stored securely on client.
    """
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS
    )
    payload = {
        "sub": str(user_id),
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "refresh",
    }
    return jwt.encode(
        payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM
    )


def decode_token(token: str) -> Optional[TokenPayload]:
    """
    Decode and validate a JWT token.

    Args:
        token: JWT token string.

    Returns:
        TokenPayload: Decoded payload or None if invalid.

    Security Implications:
        - Validates signature and expiration.
        - Returns None for any invalid token.
    """
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        return TokenPayload(
            sub=payload["sub"],
            exp=datetime.fromtimestamp(payload["exp"], tz=timezone.utc),
            iat=datetime.fromtimestamp(payload["iat"], tz=timezone.utc),
            role=UserRole(payload.get("role", "patient")),
            type=str(payload.get("type", "")),
        )
    except JWTError:
        return None


async def authenticate_user(
    db: AsyncSession, email: str, password: str
) -> Optional[User]:
    """
    Authenticate a user by email and password.

    Args:
        db: Database session.
        email: User's email address.
        password: Plain text password.

    Returns:
        User: Authenticated user or None.

    Security Implications:
        - Constant-time password comparison.
        - Does not reveal which field was incorrect.
    """
    result = await db.execute(select(User).where(User.email == email.lower()))
    user = result.scalar_one_or_none()

    if not user:
        # Perform dummy hash to prevent timing attacks
        pwd_context.hash("dummy")
        return None

    if not verify_password(password, user.hashed_password):
        return None

    if not user.is_active:
        return None

    return user


async def create_user(
    db: AsyncSession,
    email: str,
    password: str,
    first_name: str,
    last_name: str,
    role: UserRole = UserRole.PATIENT,
    phone: Optional[str] = None,
) -> User:
    """
    Create a new user.

    Args:
        db: Database session.
        email: User's email address.
        password: Plain text password (will be hashed).
        first_name: User's first name.
        last_name: User's last name.
        role: User's role (default: patient).
        phone: Optional phone number.

    Returns:
        User: Created user.

    Raises:
        ValueError: If email already exists.

    Security Implications:
        - Password is immediately hashed.
        - Email is normalized to lowercase.
    """
    # Check if email exists
    existing = await db.execute(select(User).where(User.email == email.lower()))
    if existing.scalar_one_or_none():
        raise ValueError("Email already registered")

    user = User(
        email=email.lower(),
        hashed_password=hash_password(password),
        first_name=first_name,
        last_name=last_name,
        role=role,
        phone=phone,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


def generate_tokens(user: User) -> TokenResponse:
    """
    Generate access and refresh tokens for a user.

    Args:
        user: Authenticated user.

    Returns:
        TokenResponse: Access and refresh tokens.
    """
    access_token = create_access_token(user.id, user.role)
    refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )
