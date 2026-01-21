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
]
