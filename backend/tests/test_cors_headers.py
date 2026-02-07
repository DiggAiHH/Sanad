import pytest


@pytest.mark.asyncio
async def test_cors_preflight_headers(client):
    response = await client.options(
        "/api/v1/auth/login",
        headers={
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "authorization, content-type",
        },
    )

    assert response.status_code == 200
    assert response.headers.get("access-control-allow-origin") == "http://localhost:3000"
    assert "authorization" in response.headers.get(
        "access-control-allow-headers", ""
    ).lower()
