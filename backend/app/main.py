"""
Sanad Backend API - Main Application Entry Point.

A medical practice management system API built with FastAPI.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator
import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.config import get_settings
from app.database import engine, Base
from app.routers import (
    auth,
    users,
    queue,
    tickets,
    chat,
    practice,
    nfc,
    led,
    websocket,
    push,
    analytics,
    document_requests,
    consultations,
)
# Online-Rezeption Module
from app.routers import (
    privacy,
    appointments,
    anamnesis,
    symptom_checker,
    lab_results,
    medications,
    vaccinations,
    forms,
    workflows,
)
from app.middleware import (
    CorrelationIdMiddleware,
    RequestLoggingMiddleware,
    PrometheusMiddleware,
    RateLimitMiddleware,
    SecurityHeadersMiddleware,
    RequestSizeLimitMiddleware,
    PROMETHEUS_AVAILABLE,
    configure_logging,
    get_correlation_id,
    record_error,
    metrics_endpoint,
)


settings = get_settings()
logger = logging.getLogger(__name__)


async def init_db() -> None:
    """Create database tables."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def seed_demo_data() -> None:
    """Seed demo data for testing if enabled."""
    if not settings.SEED_ON_STARTUP:
        return

    try:
        from app.seed_data import seed_database

        await seed_database()
        logger.info("Demo-Daten geladen")
    except Exception as e:
        logger.warning(f"Seed übersprungen (Daten existieren evtl. schon): {e}")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan handler for startup/shutdown events.

    Args:
        app: FastAPI application instance.

    Yields:
        None: Application is running.
    """
    # Configure structured logging
    configure_logging(json_format=not settings.DEBUG)

    # Startup
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    if not settings.TESTING:
        await init_db()
        await seed_demo_data()
    yield
    # Shutdown
    logger.info(f"Shutting down {settings.APP_NAME}")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Sanad - Deutsches Praxismanagement-System API",
    lifespan=lifespan,
    # Always show docs for testing phase
    docs_url="/docs",
    redoc_url="/redoc",
)


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """
    Return JSON error responses for HTTP exceptions.

    Args:
        request: Incoming request.
        exc: Raised HTTPException.

    Returns:
        JSONResponse: Structured error payload.
    """
    correlation_id = get_correlation_id()
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "error_code": "http_exception",
            "correlation_id": correlation_id,
        },
        headers={"X-Correlation-ID": correlation_id} if correlation_id else None,
    )


@app.exception_handler(StarletteHTTPException)
async def starlette_http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    """
    Return JSON error responses for Starlette HTTP exceptions (e.g. 404).

    Args:
        request: Incoming request.
        exc: Raised Starlette HTTPException.

    Returns:
        JSONResponse: Structured error payload.
    """
    correlation_id = get_correlation_id()
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "error_code": "http_exception",
            "correlation_id": correlation_id,
        },
        headers={"X-Correlation-ID": correlation_id} if correlation_id else None,
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """
    Return JSON error responses for validation errors.

    Args:
        request: Incoming request.
        exc: Validation error details.

    Returns:
        JSONResponse: Structured error payload.
    """
    correlation_id = get_correlation_id()
    return JSONResponse(
        status_code=422,
        content={
            "detail": exc.errors(),
            "error_code": "validation_error",
            "correlation_id": correlation_id,
        },
        headers={"X-Correlation-ID": correlation_id} if correlation_id else None,
    )


@app.exception_handler(Exception)
async def internal_exception_handler(
    request: Request, exc: Exception
) -> JSONResponse:
    """
    Return sanitized JSON error responses for unhandled exceptions.

    Args:
        request: Incoming request.
        exc: Unhandled exception.

    Returns:
        JSONResponse: Structured error payload.
    """
    record_error("internal_error", request.url.path)
    correlation_id = get_correlation_id()
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "error_code": "internal_error",
            "correlation_id": correlation_id,
        },
        headers={"X-Correlation-ID": correlation_id} if correlation_id else None,
    )

# CORS Middleware - includes Netlify domains
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.all_cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "authorization",
        "content-type",
        "accept",
        "origin",
        "x-correlation-id",
        "x-request-id",
        "x-device-id",
        "x-device-secret",
    ],
)

# Observability Middleware (order matters: first added = outermost)
app.add_middleware(SecurityHeadersMiddleware, enable_hsts=settings.ENABLE_HSTS)
app.add_middleware(
    RequestSizeLimitMiddleware, max_request_size_mb=settings.MAX_REQUEST_SIZE_MB
)
app.add_middleware(
    RateLimitMiddleware, requests_per_minute=settings.RATE_LIMIT_PER_MINUTE
)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(CorrelationIdMiddleware)
if PROMETHEUS_AVAILABLE:
    app.add_middleware(PrometheusMiddleware)

# Include Routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(queue.router, prefix="/api/v1/queue", tags=["Queue"])
app.include_router(tickets.router, prefix="/api/v1/tickets", tags=["Tickets"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
app.include_router(practice.router, prefix="/api/v1/practice", tags=["Practice"])

# Patient Features
app.include_router(
    document_requests.router,
    prefix="/api/v1/document-requests",
    tags=["Document Requests"]
)
app.include_router(
    consultations.router,
    prefix="/api/v1/consultations",
    tags=["Consultations (Video/Voice/Chat)"]
)

# Zero-Touch Reception Routers
app.include_router(nfc.router, prefix="/api/v1", tags=["NFC"])
app.include_router(led.router, prefix="/api/v1", tags=["LED & Wayfinding"])
app.include_router(websocket.router, prefix="/api/v1", tags=["WebSocket"])

# Push Notifications
app.include_router(push.router, prefix="/api/v1", tags=["Push Notifications"])

# Analytics
app.include_router(analytics.router, prefix="/api/v1", tags=["Analytics"])

# =====================================================================
# Online-Rezeption / Hausarzt-Automatisierung
# =====================================================================

# DSGVO / Privacy
app.include_router(
    privacy.router,
    prefix="/api/v1",
    tags=["Privacy & DSGVO"]
)

# Online-Terminbuchung
app.include_router(
    appointments.router,
    prefix="/api/v1",
    tags=["Online Appointments"]
)

# Digitale Anamnese
app.include_router(
    anamnesis.router,
    prefix="/api/v1",
    tags=["Digital Anamnesis"]
)

# Symptom-Checker & Triage
app.include_router(
    symptom_checker.router,
    prefix="/api/v1",
    tags=["Symptom Checker"]
)

# Laborbefunde
app.include_router(
    lab_results.router,
    prefix="/api/v1",
    tags=["Lab Results"]
)

# Medikationsplan
app.include_router(
    medications.router,
    prefix="/api/v1",
    tags=["Medications"]
)

# Impfpass & Recall
app.include_router(
    vaccinations.router,
    prefix="/api/v1",
    tags=["Vaccinations & Recall"]
)

# Praxis-Formulare
app.include_router(
    forms.router,
    prefix="/api/v1",
    tags=["Practice Forms"]
)

# Workflow-Automatisierung
app.include_router(
    workflows.router,
    prefix="/api/v1",
    tags=["Workflow Automation"]
)


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    """
    Health check endpoint for container orchestration.

    Returns:
        dict: Health status.
    """
    return {"status": "healthy", "version": settings.APP_VERSION}


# Prometheus metrics endpoint (if available)
if PROMETHEUS_AVAILABLE and metrics_endpoint:
    app.add_api_route("/metrics", metrics_endpoint, methods=["GET"], tags=["Metrics"])


@app.get("/", tags=["Root"])
async def root() -> dict[str, str]:
    """
    Root endpoint with API information.

    Returns:
        dict: API welcome message.
    """
    return {
        "name": settings.APP_NAME,
        "message": "Willkommen bei Sanad API",
        "docs": "/docs" if settings.DEBUG else "Disabled in production",
        "health": "/health",
    }
