"""
Public patient-facing endpoint tests.
"""

import uuid
from datetime import datetime, timezone

import pytest
from httpx import AsyncClient

from app.models.models import Practice, Queue, Ticket, TicketStatus


@pytest.mark.asyncio
async def test_public_practice_info(
    client: AsyncClient, db_session
) -> None:
    """Test public practice info endpoint returns active practice.

    Args:
        client: Async test client.
        db_session: Async DB session fixture.

    Returns:
        None.

    Raises:
        None.

    Security Implications:
        - Uses synthetic test data only.
    """
    practice = Practice(
        id=uuid.uuid4(),
        name="Praxis Test",
        address="Teststraße 1, 12345 Teststadt",
        phone="+49 123 456789",
        email="praxis@test.de",
        website="https://praxis-test.de",
        opening_hours="Mo-Fr: 08:00-18:00",
        max_daily_tickets=50,
        average_wait_time_minutes=12,
        is_active=True,
    )
    db_session.add(practice)
    await db_session.commit()

    response = await client.get("/api/v1/practice/public/default")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Praxis Test"
    assert data["opening_hours"] == "Mo-Fr: 08:00-18:00"
    assert data["website"] == "https://praxis-test.de"


@pytest.mark.asyncio
async def test_public_queue_summary(
    client: AsyncClient, db_session
) -> None:
    """Test public queue summary returns queues and now-serving ticket.

    Args:
        client: Async test client.
        db_session: Async DB session fixture.

    Returns:
        None.

    Raises:
        None.

    Security Implications:
        - Uses synthetic test data only.
    """
    practice = Practice(
        id=uuid.uuid4(),
        name="Praxis Test",
        address="Teststraße 1, 12345 Teststadt",
        phone="+49 123 456789",
        email="praxis@test.de",
        website="https://praxis-test.de",
        opening_hours="Mo-Fr: 08:00-18:00",
        max_daily_tickets=50,
        average_wait_time_minutes=15,
        is_active=True,
    )
    queue = Queue(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="Allgemeinmedizin",
        code="A",
        description="Test",
        color="#0066CC",
        is_active=True,
        current_number=5,
        average_wait_minutes=15,
        created_at=datetime.now(timezone.utc),
    )
    waiting_ticket = Ticket(
        id=uuid.uuid4(),
        queue_id=queue.id,
        ticket_number="A-005",
        status=TicketStatus.WAITING,
        estimated_wait_minutes=15,
        created_at=datetime.now(timezone.utc),
    )
    called_ticket = Ticket(
        id=uuid.uuid4(),
        queue_id=queue.id,
        ticket_number="A-004",
        status=TicketStatus.CALLED,
        estimated_wait_minutes=0,
        called_at=datetime.now(timezone.utc),
        created_at=datetime.now(timezone.utc),
    )
    db_session.add_all([practice, queue, waiting_ticket, called_ticket])
    await db_session.commit()

    response = await client.get("/api/v1/queue/public/summary")
    assert response.status_code == 200
    data = response.json()
    assert data["practice_name"] == "Praxis Test"
    assert data["now_serving_ticket"] == "A-004"
    assert data["queues"][0]["waiting_count"] == 1
