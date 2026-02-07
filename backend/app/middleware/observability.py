"""
Observability middleware for structured logging and metrics.

Features:
    - Request/Response logging with correlation IDs
    - Prometheus metrics (latency, request count)
    - Sensitive data masking
"""

import logging
import time
import uuid
from contextvars import ContextVar
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Context variable for correlation ID (thread-safe)
correlation_id_var: ContextVar[str] = ContextVar("correlation_id", default="")

logger = logging.getLogger(__name__)


# ============================================================================
# Correlation ID
# ============================================================================


def get_correlation_id() -> str:
    """Get current request's correlation ID."""
    return correlation_id_var.get()


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """
    Middleware to generate and propagate correlation IDs.

    Headers:
        X-Correlation-ID: Passed through from client or generated.
        X-Request-ID: Alias for correlation ID.
    """

    HEADER_NAME = "X-Correlation-ID"

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Get from header or generate new
        correlation_id = request.headers.get(
            self.HEADER_NAME, request.headers.get("X-Request-ID", str(uuid.uuid4()))
        )

        # Set in context var
        correlation_id_var.set(correlation_id)

        # Process request
        response = await call_next(request)

        # Add to response headers
        response.headers[self.HEADER_NAME] = correlation_id

        return response


# ============================================================================
# Structured Request Logging
# ============================================================================


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    Log all requests with structured data.

    Logs:
        - Method, path, status code
        - Latency
        - Correlation ID
        - Client IP (masked)
    """

    # Paths to skip logging (high frequency, low value)
    SKIP_PATHS = {"/health", "/", "/docs", "/openapi.json", "/redoc"}

    # Sensitive headers to mask
    SENSITIVE_HEADERS = {"authorization", "x-device-secret", "cookie"}

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Skip noisy endpoints
        if request.url.path in self.SKIP_PATHS:
            return await call_next(request)

        start_time = time.perf_counter()

        # Process request
        response = await call_next(request)

        # Calculate latency
        latency_ms = (time.perf_counter() - start_time) * 1000

        # Log request
        logger.info(
            "HTTP Request",
            extra={
                "correlation_id": get_correlation_id(),
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "latency_ms": round(latency_ms, 2),
                "client_ip": self._mask_ip(
                    request.client.host if request.client else "unknown"
                ),
                "user_agent": request.headers.get("user-agent", "")[:100],
            },
        )

        # Log slow requests
        if latency_ms > 1000:
            logger.warning(
                "Slow request detected",
                extra={
                    "correlation_id": get_correlation_id(),
                    "path": request.url.path,
                    "latency_ms": round(latency_ms, 2),
                },
            )

        return response

    @staticmethod
    def _mask_ip(ip: str) -> str:
        """Mask last octet of IPv4 for privacy."""
        if "." in ip:
            parts = ip.split(".")
            if len(parts) == 4:
                return f"{parts[0]}.{parts[1]}.{parts[2]}.xxx"
        return ip


# ============================================================================
# Prometheus Metrics (Optional)
# ============================================================================


try:
    from prometheus_client import (
        Counter,
        Histogram,
        generate_latest,
        CONTENT_TYPE_LATEST,
    )

    PROMETHEUS_AVAILABLE = True

    # Define metrics
    REQUEST_COUNT = Counter(
        "sanad_http_requests_total", "Total HTTP requests", ["method", "path", "status"]
    )

    REQUEST_LATENCY = Histogram(
        "sanad_http_request_duration_seconds",
        "HTTP request latency",
        ["method", "path"],
        buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0],
    )

    CHECKIN_COUNT = Counter(
        "sanad_nfc_checkins_total",
        "Total NFC check-ins",
        ["status"],  # success, unknown_card, auth_failed
    )

    QUEUE_LENGTH = Counter(
        "sanad_queue_tickets_created_total", "Total tickets created", ["queue_code"]
    )

    ERROR_COUNT = Counter(
        "sanad_errors_total", "Total application errors", ["error_type", "path"]
    )

    PUSH_NOTIFICATIONS = Counter(
        "sanad_push_notifications_total",
        "Total push notifications sent",
        ["type", "status"],  # type=ticket_called|checkin, status=success|failed
    )

    ACTIVE_TICKETS = Counter(
        "sanad_active_tickets", "Currently active (waiting) tickets", ["queue_code"]
    )

    class PrometheusMiddleware(BaseHTTPMiddleware):
        """Collect Prometheus metrics for each request."""

        SKIP_PATHS = {"/metrics", "/health"}

        async def dispatch(self, request: Request, call_next: Callable) -> Response:
            if request.url.path in self.SKIP_PATHS:
                return await call_next(request)

            start_time = time.perf_counter()
            response = await call_next(request)
            latency = time.perf_counter() - start_time

            # Normalize path (remove IDs)
            path = self._normalize_path(request.url.path)

            # Record metrics
            REQUEST_COUNT.labels(
                method=request.method, path=path, status=response.status_code
            ).inc()

            REQUEST_LATENCY.labels(method=request.method, path=path).observe(latency)

            return response

        @staticmethod
        def _normalize_path(path: str) -> str:
            """Replace UUIDs and IDs with placeholders."""
            import re

            # Replace UUIDs
            path = re.sub(
                r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
                "{id}",
                path,
                flags=re.IGNORECASE,
            )
            # Replace numeric IDs
            path = re.sub(r"/\d+", "/{id}", path)
            return path

    async def metrics_endpoint(request: Request) -> Response:
        """Prometheus metrics endpoint."""
        return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

except ImportError:
    PROMETHEUS_AVAILABLE = False
    PrometheusMiddleware = None  # type: ignore
    metrics_endpoint = None  # type: ignore


# ============================================================================
# Logging Configuration
# ============================================================================


def configure_logging(json_format: bool = True) -> None:
    """
    Configure structured JSON logging.

    Args:
        json_format: If True, use JSON format; otherwise plain text.
    """
    import json as json_lib

    class StructuredFormatter(logging.Formatter):
        """JSON log formatter with correlation ID."""

        def format(self, record: logging.LogRecord) -> str:
            log_data = {
                "timestamp": self.formatTime(record),
                "level": record.levelname,
                "message": record.getMessage(),
                "logger": record.name,
                "correlation_id": get_correlation_id(),
            }

            # Add extra fields
            if hasattr(record, "__dict__"):
                for key, value in record.__dict__.items():
                    if key not in {
                        "name",
                        "msg",
                        "args",
                        "created",
                        "filename",
                        "funcName",
                        "levelname",
                        "levelno",
                        "lineno",
                        "module",
                        "msecs",
                        "pathname",
                        "process",
                        "processName",
                        "relativeCreated",
                        "stack_info",
                        "exc_info",
                        "exc_text",
                        "thread",
                        "threadName",
                        "message",
                        "asctime",
                    }:
                        log_data[key] = value

            return json_lib.dumps(log_data)

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)

    # Remove existing handlers
    root_logger.handlers.clear()

    # Add handler
    handler = logging.StreamHandler()
    if json_format:
        handler.setFormatter(StructuredFormatter())
    else:
        handler.setFormatter(
            logging.Formatter("%(asctime)s [%(levelname)s] %(name)s: %(message)s")
        )

    root_logger.addHandler(handler)

    # Reduce noise from libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)


# ============================================================================
# Helper Functions for Business Metrics
# ============================================================================


def record_checkin_metric(status: str) -> None:
    """Record a check-in event for metrics."""
    if PROMETHEUS_AVAILABLE:
        CHECKIN_COUNT.labels(status=status).inc()


def record_ticket_created(queue_code: str) -> None:
    """Record a ticket creation for metrics."""
    if PROMETHEUS_AVAILABLE:
        QUEUE_LENGTH.labels(queue_code=queue_code).inc()


def record_error(error_type: str, path: str) -> None:
    """Record an application error for metrics."""
    if PROMETHEUS_AVAILABLE:
        ERROR_COUNT.labels(error_type=error_type, path=path).inc()


def record_push_notification(notification_type: str, success: bool) -> None:
    """Record a push notification attempt for metrics."""
    if PROMETHEUS_AVAILABLE:
        PUSH_NOTIFICATIONS.labels(
            type=notification_type, status="success" if success else "failed"
        ).inc()
