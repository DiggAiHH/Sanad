import pytest


@pytest.mark.asyncio
async def test_http_exception_handler_includes_error_code(client):
    response = await client.get("/api/v1/auth/me")

    assert response.status_code == 401
    payload = response.json()
    assert payload.get("error_code") == "http_exception"
    assert payload.get("detail")
    assert payload.get("correlation_id")


@pytest.mark.asyncio
async def test_validation_error_handler_includes_error_code(client):
    response = await client.post("/api/v1/auth/login", json={})

    assert response.status_code == 422
    payload = response.json()
    assert payload.get("error_code") == "validation_error"
    assert isinstance(payload.get("detail"), list)
    assert payload.get("correlation_id")
