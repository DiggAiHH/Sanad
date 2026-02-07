"""
Middleware package for Sanad Backend.
"""

from app.middleware.observability import (
    CorrelationIdMiddleware,
    RequestLoggingMiddleware,
    PrometheusMiddleware,
    PROMETHEUS_AVAILABLE,
    configure_logging,
    get_correlation_id,
    record_checkin_metric,
    record_ticket_created,
    record_error,
    record_push_notification,
    metrics_endpoint,
)
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response

try:
    from app.middleware.rate_limit import RateLimitMiddleware
except ModuleNotFoundError:
    class RateLimitMiddleware(BaseHTTPMiddleware):
        """Fallback rate-limit middleware (no-op)."""

        def __init__(self, app, requests_per_minute: int = 0) -> None:
            """
            Initialize the fallback middleware.

            Args:
                app: ASGI app instance.
                requests_per_minute: Allowed requests per minute (ignored).

            Returns:
                None.

            Raises:
                None.

            Security Implications:
                - Disables rate limiting when middleware is unavailable.
            """
            super().__init__(app)

        async def dispatch(
            self,
            request: Request,
            call_next: RequestResponseEndpoint,
        ) -> Response:
            """
            Pass through without rate limiting.

            Args:
                request: Incoming request object.
                call_next: Next middleware or endpoint handler.

            Returns:
                Response: Downstream response.

            Raises:
                None.

            Security Implications:
                - Disables rate limiting when middleware is unavailable.
            """
            return await call_next(request)

try:
    from app.middleware.security_headers import SecurityHeadersMiddleware
except ModuleNotFoundError:
    class SecurityHeadersMiddleware(BaseHTTPMiddleware):
        """Fallback security headers middleware (no-op)."""

        def __init__(self, app, enable_hsts: bool = False) -> None:
            """
            Initialize the fallback middleware.

            Args:
                app: ASGI app instance.
                enable_hsts: HSTS toggle (ignored).

            Returns:
                None.

            Raises:
                None.

            Security Implications:
                - Disables security headers when middleware is unavailable.
            """
            super().__init__(app)

        async def dispatch(
            self,
            request: Request,
            call_next: RequestResponseEndpoint,
        ) -> Response:
            """
            Pass through without adding security headers.

            Args:
                request: Incoming request object.
                call_next: Next middleware or endpoint handler.

            Returns:
                Response: Downstream response.

            Raises:
                None.

            Security Implications:
                - Omits default security headers when middleware is unavailable.
            """
            return await call_next(request)

try:
    from app.middleware.request_size_limit import RequestSizeLimitMiddleware
except ModuleNotFoundError:
    class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
        """Fallback request size limiter (no-op)."""

        def __init__(self, app, max_request_size_mb: int = 0) -> None:
            """
            Initialize the fallback middleware.

            Args:
                app: ASGI app instance.
                max_request_size_mb: Maximum request size (ignored).

            Returns:
                None.

            Raises:
                None.

            Security Implications:
                - Disables request size enforcement when middleware is unavailable.
            """
            super().__init__(app)

        async def dispatch(
            self,
            request: Request,
            call_next: RequestResponseEndpoint,
        ) -> Response:
            """
            Pass through without size checks.

            Args:
                request: Incoming request object.
                call_next: Next middleware or endpoint handler.

            Returns:
                Response: Downstream response.

            Raises:
                None.

            Security Implications:
                - Allows oversized requests when middleware is unavailable.
            """
            return await call_next(request)

__all__ = [
    "CorrelationIdMiddleware",
    "RequestLoggingMiddleware",
    "PrometheusMiddleware",
    "PROMETHEUS_AVAILABLE",
    "configure_logging",
    "get_correlation_id",
    "record_checkin_metric",
    "record_ticket_created",
    "record_error",
    "record_push_notification",
    "metrics_endpoint",
    "RateLimitMiddleware",
    "SecurityHeadersMiddleware",
    "RequestSizeLimitMiddleware",
]
