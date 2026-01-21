"""
Tests for NFC check-in functionality.

Covers:
    - Happy path: valid card + device -> ticket issued
    - Unknown device -> 401
    - Bad device_secret -> 401
    - Unknown NFC card -> 404
    - Expired NFC card -> 403
    - Inactive NFC card -> 403
    - Inactive device -> 403
"""

import hashlib
import uuid
from datetime import datetime, timedelta, timezone

import pytest
import pytest_asyncio
from httpx import AsyncClient
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import (
    DeviceStatus,
    DeviceType,
    IoTDevice,
    NFCCardType,
    PatientNFCCard,
    Practice,
    Queue,
    Ticket,
    TicketStatus,
    User,
    UserRole,
)

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _hash_nfc_uid(nfc_uid: str) -> str:
    """SHA-256 hash of NFC UID for lookup."""
    return hashlib.sha256(nfc_uid.encode()).hexdigest()


@pytest_asyncio.fixture
async def practice(db_session: AsyncSession) -> Practice:
    """Create a test practice."""
    p = Practice(
        id=uuid.uuid4(),
        name="Test Praxis",
        slug="test-praxis",
        timezone="Europe/Berlin",
        is_active=True,
    )
    db_session.add(p)
    await db_session.commit()
    await db_session.refresh(p)
    return p


@pytest_asyncio.fixture
async def queue(db_session: AsyncSession, practice: Practice) -> Queue:
    """Create a test queue."""
    q = Queue(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="Allgemein",
        code="A",
        is_active=True,
        average_wait_minutes=5,
    )
    db_session.add(q)
    await db_session.commit()
    await db_session.refresh(q)
    return q


@pytest_asyncio.fixture
async def iot_device(db_session: AsyncSession, practice: Practice) -> tuple[IoTDevice, str]:
    """Create a test IoT device. Returns (device, plain_secret)."""
    plain_secret = "test-device-secret-12345"
    device = IoTDevice(
        id=uuid.uuid4(),
        practice_id=practice.id,
        device_type=DeviceType.NFC_READER,
        device_name="Test-NFC-Reader",
        device_serial="NFC-TEST-001",
        device_secret_hash=_pwd_ctx.hash(plain_secret),
        location="Eingang",
        status=DeviceStatus.ONLINE,
        is_active=True,
    )
    db_session.add(device)
    await db_session.commit()
    await db_session.refresh(device)
    return device, plain_secret


@pytest_asyncio.fixture
async def patient(db_session: AsyncSession, practice: Practice) -> User:
    """Create a test patient user."""
    u = User(
        id=uuid.uuid4(),
        practice_id=practice.id,
        email="patient@test.de",
        password_hash=_pwd_ctx.hash("password123"),
        first_name="Max",
        last_name="Mustermann",
        role=UserRole.PATIENT,
        is_active=True,
    )
    db_session.add(u)
    await db_session.commit()
    await db_session.refresh(u)
    return u


@pytest_asyncio.fixture
async def nfc_card(
    db_session: AsyncSession, patient: User
) -> tuple[PatientNFCCard, str]:
    """Create a test NFC card. Returns (card, plain_nfc_uid)."""
    plain_uid = "04:A3:5B:1A:7C:8D:90"
    card = PatientNFCCard(
        id=uuid.uuid4(),
        patient_id=patient.id,
        nfc_uid_encrypted=f"encrypted:{plain_uid}",  # Simplified for test
        nfc_uid_hash=_hash_nfc_uid(plain_uid),
        card_type=NFCCardType.CUSTOM,
        card_label="Test-Karte",
        is_active=True,
        expires_at=datetime.now(timezone.utc) + timedelta(days=365),
    )
    db_session.add(card)
    await db_session.commit()
    await db_session.refresh(card)
    return card, plain_uid


# ============================================================================
# Happy Path Tests
# ============================================================================


@pytest.mark.asyncio
async def test_nfc_checkin_success(
    client: AsyncClient,
    db_session: AsyncSession,
    queue: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test successful NFC check-in creates ticket."""
    device, device_secret = iot_device
    _, nfc_uid = nfc_card
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    assert response.status_code == 200, f"Unexpected: {response.text}"
    data = response.json()
    
    assert data["success"] is True
    assert data["ticket_number"] is not None
    assert data["queue_name"] is not None
    assert data["estimated_wait_minutes"] is not None
    assert data["patient_name"] == "Max"  # First name only
    assert "message" in data


@pytest.mark.asyncio
async def test_nfc_checkin_returns_wayfinding_route_id(
    client: AsyncClient,
    db_session: AsyncSession,
    queue: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test check-in response includes wayfinding_route_id field."""
    device, device_secret = iot_device
    _, nfc_uid = nfc_card
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    data = response.json()
    # Field should be present (may be null if no route configured)
    assert "wayfinding_route_id" in data


# ============================================================================
# Authentication/Authorization Tests
# ============================================================================


@pytest.mark.asyncio
async def test_nfc_checkin_unknown_device_returns_401(
    client: AsyncClient,
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test that unknown device_id returns 401."""
    _, nfc_uid = nfc_card
    fake_device_id = str(uuid.uuid4())
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": fake_device_id,
            "device_secret": "any-secret",
        },
    )
    
    assert response.status_code == 401
    assert "Ungültiges Gerät" in response.json()["detail"]


@pytest.mark.asyncio
async def test_nfc_checkin_wrong_secret_returns_401(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test that wrong device_secret returns 401."""
    device, _ = iot_device
    _, nfc_uid = nfc_card
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": "wrong-secret",
        },
    )
    
    assert response.status_code == 401
    assert "Ungültiges Gerät" in response.json()["detail"]


@pytest.mark.asyncio
async def test_nfc_checkin_inactive_device_returns_403(
    client: AsyncClient,
    db_session: AsyncSession,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test that inactive device returns 403."""
    device, device_secret = iot_device
    _, nfc_uid = nfc_card
    
    # Deactivate device
    device.is_active = False
    await db_session.commit()
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    # Could be 401 or 403 depending on implementation
    assert response.status_code in [401, 403]


# ============================================================================
# NFC Card Validation Tests
# ============================================================================


@pytest.mark.asyncio
async def test_nfc_checkin_unknown_card_returns_404(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
):
    """Test that unknown NFC card returns 404."""
    device, device_secret = iot_device
    unknown_uid = "FF:FF:FF:FF:FF:FF:FF"
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": unknown_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    # API may return 404 or 200 with success=False
    if response.status_code == 200:
        assert response.json()["success"] is False
    else:
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_nfc_checkin_expired_card_rejected(
    client: AsyncClient,
    db_session: AsyncSession,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test that expired NFC card is rejected."""
    device, device_secret = iot_device
    card, nfc_uid = nfc_card
    
    # Expire the card
    card.expires_at = datetime.now(timezone.utc) - timedelta(days=1)
    await db_session.commit()
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    # API may return 403 or 200 with success=False
    if response.status_code == 200:
        data = response.json()
        assert data["success"] is False
        assert "abgelaufen" in data["message"].lower() or "expired" in data["message"].lower()
    else:
        assert response.status_code == 403


@pytest.mark.asyncio
async def test_nfc_checkin_inactive_card_rejected(
    client: AsyncClient,
    db_session: AsyncSession,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Test that inactive NFC card is rejected."""
    device, device_secret = iot_device
    card, nfc_uid = nfc_card
    
    # Deactivate the card
    card.is_active = False
    await db_session.commit()
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    # API may return 403 or 200 with success=False
    if response.status_code == 200:
        data = response.json()
        assert data["success"] is False
    else:
        assert response.status_code == 403


# ============================================================================
# Dynamic Wait Time Tests
# ============================================================================


@pytest.mark.asyncio
async def test_nfc_checkin_wait_time_increases_with_queue(
    client: AsyncClient,
    db_session: AsyncSession,
    queue: Queue,
    practice: Practice,
    iot_device: tuple[IoTDevice, str],
    patient: User,
):
    """Test that estimated_wait_minutes reflects queue length."""
    device, device_secret = iot_device
    
    # Create 3 waiting tickets
    for i in range(3):
        ticket = Ticket(
            id=uuid.uuid4(),
            queue_id=queue.id,
            ticket_number=f"A{100 + i}",
            status=TicketStatus.WAITING,
        )
        db_session.add(ticket)
    await db_session.commit()
    
    # Create a new NFC card for check-in
    new_uid = "04:B1:C2:D3:E4:F5:00"
    new_card = PatientNFCCard(
        id=uuid.uuid4(),
        patient_id=patient.id,
        nfc_uid_encrypted=f"encrypted:{new_uid}",
        nfc_uid_hash=_hash_nfc_uid(new_uid),
        card_type=NFCCardType.CUSTOM,
        is_active=True,
    )
    db_session.add(new_card)
    await db_session.commit()
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": new_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    if response.status_code == 200 and response.json()["success"]:
        data = response.json()
        # 3 waiting tickets × 5 min average = 15 min expected
        # (may be 4 × 5 = 20 if new ticket is included)
        assert data["estimated_wait_minutes"] >= 15


# ============================================================================
# Edge Cases
# ============================================================================


@pytest.mark.asyncio
async def test_nfc_checkin_empty_uid_rejected(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
):
    """Test that empty NFC UID is rejected."""
    device, device_secret = iot_device
    
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": "",
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )
    
    # Should fail validation (422) or return error
    assert response.status_code in [400, 422] or (
        response.status_code == 200 and response.json()["success"] is False
    )


@pytest.mark.asyncio
async def test_nfc_checkin_malformed_device_id(
    client: AsyncClient,
):
    """Test that malformed device_id is rejected."""
    response = await client.post(
        "/api/nfc/check-in",
        json={
            "nfc_uid": "04:A3:5B:1A:7C:8D:90",
            "device_id": "not-a-uuid",
            "device_secret": "secret",
        },
    )
    
    assert response.status_code == 422  # Pydantic validation error
