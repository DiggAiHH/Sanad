import pytest


@pytest.mark.asyncio
async def test_not_found_handler_returns_error_code(client):
    response = await client.get("/api/v1/this-route-does-not-exist")

    assert response.status_code == 404
    payload = response.json()
    assert payload.get("error_code") == "http_exception"
    assert payload.get("detail")
    assert payload.get("correlation_id")
