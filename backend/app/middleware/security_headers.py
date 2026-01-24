"""
Security headers middleware for Sanad Backend.
"""

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Apply baseline security headers to all responses.

    Args:
        app: ASGI app instance.
        enable_hsts: Enable Strict-Transport-Security header.

    Returns:
        None.

    Raises:
        None.

    Security Implications:
        - Enforces browser hardening defaults for API responses.
    """

    def __init__(self, app, enable_hsts: bool = False) -> None:
        super().__init__(app)
        self.enable_hsts = enable_hsts

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """
        Add security headers to response.

        Args:
            request: Incoming request object.
            call_next: Next middleware or endpoint handler.

        Returns:
            Response: Response with security headers applied.

        Raises:
            None.

        Security Implications:
            - Avoids clickjacking, MIME sniffing, and leakage via referrer.
        """
        response = await call_next(request)

        response.headers.setdefault("X-Frame-Options", "DENY")
        response.headers.setdefault("X-Content-Type-Options", "nosniff")
        response.headers.setdefault("Referrer-Policy", "strict-origin-when-cross-origin")
        response.headers.setdefault(
            "Permissions-Policy",
            "camera=(), microphone=(), geolocation=()",
        )
        response.headers.setdefault("X-XSS-Protection", "1; mode=block")

        if self.enable_hsts:
            response.headers.setdefault(
                "Strict-Transport-Security",
                "max-age=31536000; includeSubDomains",
            )

        return response
