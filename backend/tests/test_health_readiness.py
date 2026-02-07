import pytest


@pytest.mark.asyncio
async def test_health_status_includes_database_flag(client):
    response = await client.get("/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload.get("status") in {"healthy", "degraded"}
    assert "database" in payload
    assert "version" in payload


@pytest.mark.asyncio
async def test_readiness_status_returns_database_flag(client):
    response = await client.get("/ready")

    assert response.status_code == 200
    payload = response.json()
    assert payload.get("status") in {"ready", "not_ready"}
    assert "database" in payload
