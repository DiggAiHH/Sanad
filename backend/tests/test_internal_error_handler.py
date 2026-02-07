import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from app.main import internal_exception_handler
from app.middleware import CorrelationIdMiddleware


@pytest.mark.asyncio
async def test_internal_error_handler_returns_sanitized_payload() -> None:
    app = FastAPI()
    app.add_middleware(CorrelationIdMiddleware)
    app.add_exception_handler(Exception, internal_exception_handler)

    @app.get("/boom")
    async def boom() -> dict:
        raise RuntimeError("boom")

    transport = ASGITransport(app=app, raise_app_exceptions=False)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/boom")

    assert response.status_code == 500
    payload = response.json()
    assert payload.get("error_code") == "internal_error"
    assert payload.get("detail") == "Internal server error"
    assert payload.get("correlation_id")
