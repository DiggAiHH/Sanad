import pytest
from fastapi import FastAPI
from httpx import AsyncClient

from app.middleware.rate_limit import RateLimitMiddleware


async def _build_client() -> AsyncClient:
    app = FastAPI()
    app.add_middleware(RateLimitMiddleware, requests_per_minute=2)

    @app.get("/ping")
    async def ping() -> dict:
        return {"ok": True}

    return AsyncClient(app=app, base_url="http://test")


@pytest.mark.asyncio
async def test_rate_limit_blocks_excess_requests() -> None:
    async with await _build_client() as client:
        assert (await client.get("/ping")).status_code == 200
        assert (await client.get("/ping")).status_code == 200

        response = await client.get("/ping")
        assert response.status_code == 429
        assert response.json().get("error_code") == "rate_limited"
