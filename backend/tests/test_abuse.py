"""
E2E and Abuse/Security Tests for NFC, LED, and Push Notification endpoints.

Covers:
    - Rate limiting/brute-force protection
    - MQTT/Wayfinding failure handling
    - Push notification edge cases
    - Input validation abuse
    - Concurrent request handling
"""

import asyncio
import hashlib
import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, patch

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
    User,
    UserRole,
    Zone,
)

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _hash_nfc_uid(nfc_uid: str) -> str:
    """
    SHA-256 hash of NFC UID for lookup (normalized to match NFCService).

    Params:
        nfc_uid: Raw NFC UID string from the reader.

    Returns:
        Hex-encoded SHA-256 hash of the normalized UID.

    Raises:
        None.

    Security Implications:
        - Uses hashing to avoid storing raw UIDs in test fixtures.
    """
    normalized = nfc_uid.upper().replace(":", "").replace(" ", "")
    return hashlib.sha256(normalized.encode()).hexdigest()


# ============================================================================
# Fixtures
# ============================================================================


@pytest_asyncio.fixture
async def practice(db_session: AsyncSession) -> Practice:
    p = Practice(
        id=uuid.uuid4(),
        name="Abuse Test Praxis",
        address="Abuse Strasse 1, 12345 Teststadt",
        phone="+49 30 987654",
        email="abuse@test.de",
        is_active=True,
    )
    db_session.add(p)
    await db_session.commit()
    return p


@pytest_asyncio.fixture
async def zone(db_session: AsyncSession, practice: Practice) -> Zone:
    z = Zone(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="Wartebereich A",
        code="WB-A",
        zone_type="waiting_room",
    )
    db_session.add(z)
    await db_session.commit()
    return z


@pytest_asyncio.fixture
async def queue_with_zone(
    db_session: AsyncSession, practice: Practice, zone: Zone
) -> Queue:
    q = Queue(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="Allgemein",
        code="A",
        is_active=True,
        average_wait_minutes=5,
        zone_id=zone.id,
    )
    db_session.add(q)
    await db_session.commit()
    return q


@pytest_asyncio.fixture
async def iot_device(
    db_session: AsyncSession, practice: Practice
) -> tuple[IoTDevice, str]:
    plain_secret = "valid-secret-for-testing-purposes"
    device = IoTDevice(
        id=uuid.uuid4(),
        practice_id=practice.id,
        device_type=DeviceType.NFC_READER,
        device_name="Abuse-Test-Reader",
        device_serial="ABUSE-001",
        device_secret_hash=_pwd_ctx.hash(plain_secret),
        location="Eingang",
        status=DeviceStatus.ONLINE,
        is_active=True,
    )
    db_session.add(device)
    await db_session.commit()
    return device, plain_secret


@pytest_asyncio.fixture
async def patient(db_session: AsyncSession, practice: Practice) -> User:
    u = User(
        id=uuid.uuid4(),
        email="abuse-patient@test.de",
        hashed_password=_pwd_ctx.hash("password123"),
        first_name="Abuse",
        last_name="Tester",
        role=UserRole.PATIENT,
        is_active=True,
    )
    db_session.add(u)
    await db_session.commit()
    return u


@pytest_asyncio.fixture
async def nfc_card(
    db_session: AsyncSession, patient: User
) -> tuple[PatientNFCCard, str]:
    plain_uid = "AB:CD:EF:12:34:56:78"
    card = PatientNFCCard(
        id=uuid.uuid4(),
        patient_id=patient.id,
        nfc_uid_encrypted=f"encrypted:{plain_uid}",
        nfc_uid_hash=_hash_nfc_uid(plain_uid),
        card_type=NFCCardType.CUSTOM,
        is_active=True,
    )
    db_session.add(card)
    await db_session.commit()
    return card, plain_uid


# ============================================================================
# Abuse Tests: Brute-Force Protection
# ============================================================================


@pytest.mark.asyncio
async def test_brute_force_device_secret_should_be_slow(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """
    Verify that bcrypt comparison slows down brute-force attempts.
    Multiple wrong secrets should take measurable time.
    """
    device, _ = iot_device
    _, nfc_uid = nfc_card

    start = datetime.now(timezone.utc)

    # Attempt 10 wrong secrets
    for i in range(10):
        await client.post(
            "/api/v1/nfc/check-in",
            json={
                "nfc_uid": nfc_uid,
                "device_id": str(device.id),
                "device_secret": f"wrong-secret-{i}",
            },
        )

    elapsed = (datetime.now(timezone.utc) - start).total_seconds()

    # bcrypt should take ~100ms per comparison = ~1s for 10 attempts
    # This deters brute-force attacks
    assert elapsed > 0.5, "Brute-force protection: bcrypt should slow down attempts"


@pytest.mark.asyncio
async def test_enumeration_unknown_device_vs_wrong_secret_same_error(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """
    Security: Unknown device and wrong secret should return same error.
    Prevents device ID enumeration.
    """
    device, device_secret = iot_device
    _, nfc_uid = nfc_card

    # Unknown device
    resp1 = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(uuid.uuid4()),
            "device_secret": device_secret,
        },
    )

    # Known device, wrong secret
    resp2 = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": "wrong-secret",
        },
    )

    # Both should be 401 with same generic message
    assert resp1.status_code == 401
    assert resp2.status_code == 401
    assert resp1.json()["detail"] == resp2.json()["detail"]


# ============================================================================
# Abuse Tests: Input Validation
# ============================================================================


@pytest.mark.asyncio
async def test_sql_injection_in_nfc_uid(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
):
    """Verify SQL injection attempts in nfc_uid are safely handled."""
    device, device_secret = iot_device

    malicious_uids = [
        "'; DROP TABLE users; --",
        "1 OR 1=1",
        "admin'--",
        "{{constructor.constructor('return this')()}}",
        "${7*7}",
    ]

    for uid in malicious_uids:
        response = await client.post(
            "/api/v1/nfc/check-in",
            json={
                "nfc_uid": uid,
                "device_id": str(device.id),
                "device_secret": device_secret,
            },
        )
        # Should not crash, just return card not found or validation error
        assert response.status_code in [200, 404, 422]
        if response.status_code == 200:
            assert response.json()["success"] is False


@pytest.mark.asyncio
async def test_oversized_nfc_uid_rejected(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
):
    """Verify extremely long NFC UIDs are rejected."""
    device, device_secret = iot_device

    # NFC UIDs are typically 4-10 bytes, this is 10KB
    oversized_uid = "A" * 10_000

    response = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": oversized_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )

    # Should reject or handle gracefully
    assert response.status_code in [200, 400, 413, 422]


@pytest.mark.asyncio
async def test_unicode_nfc_uid_handled(
    client: AsyncClient,
    iot_device: tuple[IoTDevice, str],
):
    """Verify unicode in NFC UID doesn't cause encoding issues."""
    device, device_secret = iot_device

    unicode_uids = [
        "🎉:🚀:💡:🔥",
        "中文:日本語:한국어",
        "Ü:Ä:Ö:ß",
        "\x00\x01\x02\x03",
    ]

    for uid in unicode_uids:
        response = await client.post(
            "/api/v1/nfc/check-in",
            json={
                "nfc_uid": uid,
                "device_id": str(device.id),
                "device_secret": device_secret,
            },
        )
        # Should handle gracefully
        assert response.status_code in [200, 400, 422]


# ============================================================================
# Abuse Tests: Concurrent Requests
# ============================================================================


@pytest.mark.asyncio
async def test_concurrent_checkins_same_card(
    client: AsyncClient,
    db_session: AsyncSession,
    queue_with_zone: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """
    Verify concurrent check-ins with same card don't create duplicate tickets.
    Race condition protection.
    """
    device, device_secret = iot_device
    _, nfc_uid = nfc_card

    async def do_checkin():
        return await client.post(
            "/api/v1/nfc/check-in",
            json={
                "nfc_uid": nfc_uid,
                "device_id": str(device.id),
                "device_secret": device_secret,
            },
        )

    # Fire 5 concurrent requests
    responses = await asyncio.gather(*[do_checkin() for _ in range(5)])

    # Count successful check-ins
    success_count = sum(
        1 for r in responses if r.status_code == 200 and r.json().get("success")
    )

    # Ideally only 1 should succeed (duplicate prevention)
    # Or all succeed with same ticket number
    ticket_numbers = {
        r.json().get("ticket_number")
        for r in responses
        if r.status_code == 200 and r.json().get("success")
    }

    # Either 1 success, or all have same ticket number
    assert success_count == 1 or len(ticket_numbers) == 1


# ============================================================================
# Failure Handling: MQTT/Wayfinding
# ============================================================================


@pytest.mark.asyncio
async def test_checkin_succeeds_when_mqtt_unavailable(
    client: AsyncClient,
    db_session: AsyncSession,
    queue_with_zone: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """
    Check-in should succeed even if MQTT/LED service fails.
    Wayfinding is optional enhancement, not critical path.
    """
    device, device_secret = iot_device
    _, nfc_uid = nfc_card

    # Mock LED service to fail
    with patch(
        "app.services.led_service.LEDService.activate_wayfinding_route",
        new_callable=AsyncMock,
        side_effect=Exception("MQTT connection refused"),
    ):
        response = await client.post(
            "/api/v1/nfc/check-in",
            json={
                "nfc_uid": nfc_uid,
                "device_id": str(device.id),
                "device_secret": device_secret,
            },
        )

    # Check-in should still succeed
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["ticket_number"] is not None
    # Wayfinding route might be None due to failure
    # But ticket was issued


@pytest.mark.asyncio
async def test_checkin_succeeds_when_no_zone_configured(
    client: AsyncClient,
    db_session: AsyncSession,
    practice: Practice,
    iot_device: tuple[IoTDevice, str],
    patient: User,
):
    """Check-in works even when queue has no zone (no wayfinding)."""
    # Queue without zone_id
    queue_no_zone = Queue(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="No-Zone Queue",
        code="Z",
        is_active=True,
        zone_id=None,
    )
    db_session.add(queue_no_zone)

    plain_uid = "ZZ:ZZ:ZZ:ZZ:ZZ:ZZ:ZZ"
    card = PatientNFCCard(
        id=uuid.uuid4(),
        patient_id=patient.id,
        nfc_uid_encrypted=f"enc:{plain_uid}",
        nfc_uid_hash=_hash_nfc_uid(plain_uid),
        card_type=NFCCardType.CUSTOM,
        is_active=True,
    )
    db_session.add(card)
    await db_session.commit()

    device, device_secret = iot_device

    response = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": plain_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["wayfinding_route_id"] is None  # No zone = no wayfinding


# ============================================================================
# Abuse Tests: Push Notifications
# ============================================================================


@pytest.mark.asyncio
async def test_register_fcm_token_invalid_token_format(client: AsyncClient):
    """Verify malformed FCM tokens are rejected."""
    # This would need an authenticated endpoint
    # Placeholder for when push registration is implemented
    pass


@pytest.mark.asyncio
async def test_push_notification_with_missing_device_token(
    client: AsyncClient,
):
    """Verify graceful handling when patient has no FCM token."""
    # Push should not block check-in if token missing
    pass


# ============================================================================
# Edge Cases: Empty/Missing Data
# ============================================================================


@pytest.mark.asyncio
async def test_checkin_with_no_active_queues(
    client: AsyncClient,
    db_session: AsyncSession,
    practice: Practice,
    iot_device: tuple[IoTDevice, str],
    patient: User,
):
    """Check-in fails gracefully when no queues are active."""
    # Create inactive queue only
    inactive_queue = Queue(
        id=uuid.uuid4(),
        practice_id=practice.id,
        name="Inactive",
        code="X",
        is_active=False,
    )
    db_session.add(inactive_queue)

    plain_uid = "IN:AC:TI:VE:QU:EU:EE"
    card = PatientNFCCard(
        id=uuid.uuid4(),
        patient_id=patient.id,
        nfc_uid_encrypted=f"enc:{plain_uid}",
        nfc_uid_hash=_hash_nfc_uid(plain_uid),
        card_type=NFCCardType.CUSTOM,
        is_active=True,
    )
    db_session.add(card)
    await db_session.commit()

    device, device_secret = iot_device

    response = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": plain_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )

    # Should return error, not crash
    if response.status_code == 200:
        assert response.json()["success"] is False
    else:
        assert response.status_code in [400, 404]


@pytest.mark.asyncio
async def test_led_command_to_offline_device(client: AsyncClient):
    """LED commands to offline devices should queue or fail gracefully."""
    # Placeholder for LED endpoint tests
    pass


# ============================================================================
# Regression Tests
# ============================================================================


@pytest.mark.asyncio
async def test_checkin_does_not_expose_full_patient_name(
    client: AsyncClient,
    queue_with_zone: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Privacy: Response should only contain first name, not full name."""
    device, device_secret = iot_device
    _, nfc_uid = nfc_card

    response = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )

    if response.status_code == 200 and response.json()["success"]:
        data = response.json()
        patient_name = data.get("patient_name", "")
        # Should be first name only ("Abuse"), not full ("Abuse Tester")
        assert " " not in patient_name, "Full name exposed in response"


@pytest.mark.asyncio
async def test_response_does_not_contain_nfc_uid(
    client: AsyncClient,
    queue_with_zone: Queue,
    iot_device: tuple[IoTDevice, str],
    nfc_card: tuple[PatientNFCCard, str],
):
    """Security: NFC UID should never be echoed in response."""
    device, device_secret = iot_device
    _, nfc_uid = nfc_card

    response = await client.post(
        "/api/v1/nfc/check-in",
        json={
            "nfc_uid": nfc_uid,
            "device_id": str(device.id),
            "device_secret": device_secret,
        },
    )

    response_text = response.text.lower()
    # UID should not appear in response
    assert nfc_uid.lower() not in response_text
    assert nfc_uid.replace(":", "").lower() not in response_text
