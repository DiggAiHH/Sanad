"""
Authentication endpoint tests.
"""

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient) -> None:
    """Test health check endpoint."""
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data


@pytest.mark.asyncio
async def test_root_endpoint(client: AsyncClient) -> None:
    """Test root endpoint."""
    response = await client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert "Sanad" in data["name"]


@pytest.mark.asyncio
async def test_register_user(client: AsyncClient) -> None:
    """Test user registration."""
    user_data = {
        "email": "test@example.de",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
        "role": "patient",
    }

    response = await client.post("/api/v1/auth/register", json=user_data)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["first_name"] == user_data["first_name"]
    assert "id" in data
    assert "hashed_password" not in data


@pytest.mark.asyncio
async def test_register_duplicate_email(client: AsyncClient) -> None:
    """Test registration with duplicate email."""
    user_data = {
        "email": "duplicate@example.de",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
    }

    # First registration
    response1 = await client.post("/api/v1/auth/register", json=user_data)
    assert response1.status_code == 201

    # Duplicate registration
    response2 = await client.post("/api/v1/auth/register", json=user_data)
    assert response2.status_code == 400


@pytest.mark.asyncio
async def test_login_success(client: AsyncClient) -> None:
    """Test successful login."""
    # First register
    user_data = {
        "email": "login@example.de",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
    }
    await client.post("/api/v1/auth/register", json=user_data)

    # Then login
    login_data = {
        "email": user_data["email"],
        "password": user_data["password"],
    }
    response = await client.post("/api/v1/auth/login", json=login_data)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_refresh_rejects_access_token(client: AsyncClient) -> None:
    """Abuse case: refresh endpoint must reject access tokens."""
    user_data = {
        "email": "refresh_abuse@example.de",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
    }
    await client.post("/api/v1/auth/register", json=user_data)

    login_response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": user_data["email"],
            "password": user_data["password"],
        },
    )
    assert login_response.status_code == 200
    access_token = login_response.json()["access_token"]

    refresh_response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": access_token},
    )
    assert refresh_response.status_code == 401


@pytest.mark.asyncio
async def test_login_invalid_credentials(client: AsyncClient) -> None:
    """Test login with invalid credentials."""
    login_data = {
        "email": "nonexistent@example.de",
        "password": "WrongPassword123!",
    }
    response = await client.post("/api/v1/auth/login", json=login_data)
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_protected_endpoint_without_token(client: AsyncClient) -> None:
    """Test accessing protected endpoint without token."""
    response = await client.get("/api/v1/users/me")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_protected_endpoint_with_token(client: AsyncClient) -> None:
    """Test accessing protected endpoint with valid token."""
    # Register and login
    user_data = {
        "email": "protected@example.de",
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
    }
    await client.post("/api/v1/auth/register", json=user_data)

    login_response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": user_data["email"],
            "password": user_data["password"],
        },
    )
    token = login_response.json()["access_token"]

    # Access protected endpoint
    response = await client.get(
        "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == user_data["email"]
