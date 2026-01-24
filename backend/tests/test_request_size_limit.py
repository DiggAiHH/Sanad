import pytest
from fastapi import FastAPI
from httpx import AsyncClient

from app.middleware.request_size_limit import RequestSizeLimitMiddleware


async def _build_client() -> AsyncClient:
    app = FastAPI()
    app.add_middleware(RequestSizeLimitMiddleware, max_request_size_mb=0.001)

    @app.post("/echo")
    async def echo(payload: dict) -> dict:
        return {"ok": True, "size": len(str(payload))}

    return AsyncClient(app=app, base_url="http://test")


@pytest.mark.asyncio
async def test_request_size_limit_blocks_large_payload() -> None:
    async with await _build_client() as client:
        small_payload = {"data": "a" * 100}
        response = await client.post("/echo", json=small_payload)
        assert response.status_code == 200

        large_payload = {"data": "a" * 5000}
        response = await client.post("/echo", json=large_payload)
        assert response.status_code == 413
        assert response.json().get("error_code") == "request_too_large"
