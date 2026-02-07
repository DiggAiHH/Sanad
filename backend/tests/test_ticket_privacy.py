"""Ticket privacy tests.

Security:
    - Public ticket lookup must not leak PII (patient_name/phone/notes).
"""

import pytest
from httpx import AsyncClient


async def _register_and_login(client: AsyncClient, *, email: str, role: str) -> str:
    user_data = {
        "email": email,
        "password": "SecurePass123!",
        "first_name": "Test",
        "last_name": "User",
        "role": role,
    }
    resp = await client.post("/api/v1/auth/register", json=user_data)
    assert resp.status_code == 201

    login = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": user_data["password"]},
    )
    assert login.status_code == 200
    return login.json()["access_token"]


@pytest.mark.asyncio
async def test_public_ticket_lookup_redacts_pii(client: AsyncClient) -> None:
    """Happy path: create ticket and ensure public endpoint returns redacted payload."""

    admin_token = await _register_and_login(
        client,
        email="admin_privacy@example.de",
        role="admin",
    )

    # Create practice (admin)
    practice_resp = await client.post(
        "/api/v1/practice",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "name": "Test Praxis",
            "address": "Teststraße 1, 12345 Teststadt",
            "phone": "+49 123 456789",
            "email": "praxis@example.de",
            "opening_hours": "Mo-Fr 08:00-16:00",
            "max_daily_tickets": 10,
            "average_wait_time_minutes": 15,
        },
    )
    assert practice_resp.status_code == 201
    practice_id = practice_resp.json()["id"]

    # Create queue (admin)
    queue_resp = await client.post(
        "/api/v1/queue",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "practice_id": practice_id,
            "name": "Allgemein",
            "code": "A",
            "description": "Allgemeine Sprechstunde",
            "color": "#0066CC",
            "average_wait_minutes": 15,
        },
    )
    assert queue_resp.status_code == 201
    queue_id = queue_resp.json()["id"]

    # Create ticket (staff)
    staff_token = await _register_and_login(
        client,
        email="mfa_privacy@example.de",
        role="mfa",
    )

    ticket_resp = await client.post(
        "/api/v1/tickets",
        headers={"Authorization": f"Bearer {staff_token}"},
        json={
            "queue_id": queue_id,
            "patient_name": "Max Mustermann",
            "patient_phone": "+49 999 111",
            "priority": "normal",
            "notes": "Sehr sensible Notiz",
        },
    )
    assert ticket_resp.status_code == 201
    ticket_number = ticket_resp.json()["ticket_number"]

    # Public lookup must redact PII
    public_resp = await client.get(f"/api/v1/tickets/number/{ticket_number}")
    assert public_resp.status_code == 200
    data = public_resp.json()

    assert data["ticket_number"] == ticket_number
    assert "status" in data
    assert "estimated_wait_minutes" in data

    assert "patient_name" not in data
    assert "patient_phone" not in data
    assert "notes" not in data
    assert "created_by_id" not in data
    assert "assigned_to_id" not in data
