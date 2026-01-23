"""
Test configuration and fixtures.
"""

import base64
import os
from typing import AsyncGenerator

import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool

os.environ.setdefault(
    "DATABASE_URL",
    "sqlite+aiosqlite:////tmp/sanad_test.db",
)
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-not-for-production")
os.environ.setdefault("TESTING", "true")
os.environ.setdefault(
    "NFC_ENCRYPTION_KEY",
    base64.b64encode(b"0123456789ABCDEF0123456789ABCDEF").decode(),
)

from app.database import Base, get_db  # noqa: E402
from app.main import app  # noqa: E402


# Use file-backed SQLite for concurrent sessions in tests
TEST_DATABASE_URL = "sqlite+aiosqlite:////tmp/sanad_test.db"


@pytest_asyncio.fixture(scope="function")
async def async_session_factory() -> AsyncGenerator[sessionmaker, None]:
    """
    Create an async session factory backed by a file-based SQLite engine.

    Params:
        None.

    Returns:
        AsyncGenerator: Session factory for creating AsyncSession instances.

    Raises:
        None.

    Security Implications:
        - Uses a file-based database isolated per test run.
    """
    engine = create_async_engine(
        TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=NullPool,
        echo=False,
    )

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    factory = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    yield factory

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest_asyncio.fixture(scope="function")
async def db_session(
    async_session_factory: sessionmaker,
) -> AsyncGenerator[AsyncSession, None]:
    """
    Create a new database session for each test.

    Params:
        async_session_factory: Session factory fixture.

    Returns:
        AsyncGenerator: AsyncSession for test setup/queries.

    Raises:
        None.

    Security Implications:
        - Uses isolated in-memory DB sessions for tests.
    """
    async with async_session_factory() as session:
        yield session


@pytest_asyncio.fixture(scope="function")
async def client(
    async_session_factory: sessionmaker,
) -> AsyncGenerator[AsyncClient, None]:
    """
    Create test client with database override.

    Params:
        async_session_factory: Session factory fixture.

    Returns:
        AsyncGenerator: Async HTTP client bound to the FastAPI app.

    Raises:
        None.

    Security Implications:
        - Provides per-request sessions to avoid cross-request state leaks.
    """

    async def override_get_db():
        async with async_session_factory() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


@pytest_asyncio.fixture(scope="function")
async def auth_headers(client: AsyncClient) -> dict:
    """
    Create authenticated user and return auth headers.

    Returns:
        dict: Authorization headers with Bearer token.
    """
    # Register a test user
    user_data = {
        "email": "testuser@example.de",
        "password": "TestPass123!",
        "first_name": "Test",
        "last_name": "User",
        "role": "patient",
    }
    await client.post("/api/v1/auth/register", json=user_data)
    
    # Login to get token
    login_response = await client.post(
        "/api/v1/auth/login",
        data={"username": user_data["email"], "password": user_data["password"]},
    )
    
    if login_response.status_code == 200:
        token = login_response.json().get("access_token", "")
        return {"Authorization": f"Bearer {token}"}
    
    # Fallback: return empty headers (tests will fail with 401)
    return {}
