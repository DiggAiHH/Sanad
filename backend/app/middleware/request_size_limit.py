"""
Request size limiting middleware for Sanad Backend.
"""

from __future__ import annotations

import uuid
from typing import Iterable

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from app.middleware.observability import record_error


class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
    """
    Reject requests with payloads exceeding configured limits.

    Args:
        app: ASGI app instance.
        max_request_size_mb: Max allowed request size in megabytes.

    Returns:
        None.

    Raises:
        None.

    Security Implications:
        - Prevents oversized payload DoS.
        - Relies on Content-Length where present.
    """

    def __init__(self, app, max_request_size_mb: float = 5) -> None:
        super().__init__(app)
        self.max_request_size_mb = max(float(max_request_size_mb), 0.0)
        self._max_bytes = int(self.max_request_size_mb * 1024 * 1024)
        self._methods_with_body: Iterable[str] = {"POST", "PUT", "PATCH"}

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """
        Enforce request size limits.

        Args:
            request: Incoming request object.
            call_next: Next middleware or endpoint handler.

        Returns:
            Response: Downstream response or 413 rejection.

        Raises:
            None.

        Security Implications:
            - Blocks oversized requests early.
        """
        if self._max_bytes <= 0:
            return await call_next(request)

        if request.method in self._methods_with_body:
            content_length = request.headers.get("content-length")
            if content_length and content_length.isdigit():
                if int(content_length) > self._max_bytes:
                    record_error("request_too_large", request.url.path)
                    return self._too_large_response(request)
            else:
                body = await request.body()
                if len(body) > self._max_bytes:
                    record_error("request_too_large", request.url.path)
                    return self._too_large_response(request)

        return await call_next(request)

    def _too_large_response(self, request: Request) -> JSONResponse:
        """
        Build standardized 413 response.

        Args:
            request: Incoming request.

        Returns:
            JSONResponse: 413 response with metadata.

        Security Implications:
            - Avoids returning request payloads in responses.
        """
        correlation_id = request.headers.get(
            "X-Correlation-ID",
            request.headers.get("X-Request-ID", str(uuid.uuid4())),
        )
        return JSONResponse(
            status_code=413,
            content={
                "detail": "Request entity too large",
                "error_code": "request_too_large",
                "max_size_mb": self.max_request_size_mb,
                "correlation_id": correlation_id,
            },
            headers={"X-Correlation-ID": correlation_id},
        )
