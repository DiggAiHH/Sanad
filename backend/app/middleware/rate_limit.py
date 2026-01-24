"""
Rate limiting middleware for Sanad Backend.

Implements a simple in-memory sliding window limiter.
"""

from __future__ import annotations

import asyncio
import time
import uuid
from collections import defaultdict, deque
from typing import Deque, DefaultDict

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from app.middleware.observability import record_error


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Enforce request rate limits per client key (IP-based).

    Args:
        app: ASGI app instance.
        requests_per_minute: Allowed requests per minute (per client).

    Returns:
        None.

    Raises:
        None.

    Security Implications:
        - In-memory limits are process-local and reset on restart.
        - For distributed deployments, replace with Redis-based limiter.
    """

    def __init__(self, app, requests_per_minute: int = 60) -> None:
        super().__init__(app)
        self.requests_per_minute = max(int(requests_per_minute), 0)
        self._window_seconds = 60.0
        self._requests: DefaultDict[str, Deque[float]] = defaultdict(deque)
        self._lock = asyncio.Lock()

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """
        Enforce per-client request limits.

        Args:
            request: Incoming request object.
            call_next: Next middleware or endpoint handler.

        Returns:
            Response: Downstream response or rate-limit rejection.

        Raises:
            None.

        Security Implications:
            - Prevents request floods from a single client.
            - Does not protect against distributed attacks.
        """
        if self.requests_per_minute <= 0:
            return await call_next(request)

        now = time.monotonic()
        client_key = self._get_client_key(request)

        async with self._lock:
            timestamps = self._requests[client_key]
            cutoff = now - self._window_seconds
            while timestamps and timestamps[0] <= cutoff:
                timestamps.popleft()

            if len(timestamps) >= self.requests_per_minute:
                retry_after = max(1, int(self._window_seconds - (now - timestamps[0])))
                record_error("rate_limit", request.url.path)
                return self._rate_limited_response(request, retry_after)

            timestamps.append(now)

        return await call_next(request)

    @staticmethod
    def _get_client_key(request: Request) -> str:
        """
        Resolve client key for rate limiting.

        Args:
            request: Incoming request.

        Returns:
            str: Client identifier (IP or fallback).
        """
        if request.client and request.client.host:
            return request.client.host
        return request.headers.get("x-forwarded-for", "unknown")

    @staticmethod
    def _rate_limited_response(request: Request, retry_after: int) -> JSONResponse:
        """
        Build a standardized rate-limit response.

        Args:
            request: Incoming request.
            retry_after: Suggested retry delay in seconds.

        Returns:
            JSONResponse: 429 response with details.

        Security Implications:
            - Avoids leaking internal limits beyond retry window.
        """
        correlation_id = request.headers.get(
            "X-Correlation-ID",
            request.headers.get("X-Request-ID", str(uuid.uuid4())),
        )
        return JSONResponse(
            status_code=429,
            content={
                "detail": "Rate limit exceeded",
                "error_code": "rate_limited",
                "retry_after_seconds": retry_after,
                "correlation_id": correlation_id,
            },
            headers={
                "Retry-After": str(retry_after),
                "X-Correlation-ID": correlation_id,
            },
        )
