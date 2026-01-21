"""
Sanad Backend API - Main Application Entry Point.

A medical practice management system API built with FastAPI.
"""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.database import engine, Base
from app.routers import auth, users, queue, tickets, chat, practice, nfc, led, websocket, push, analytics
from app.middleware import (
    CorrelationIdMiddleware,
    RequestLoggingMiddleware,
    PrometheusMiddleware,
    PROMETHEUS_AVAILABLE,
    configure_logging,
    metrics_endpoint,
)


settings = get_settings()


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

# CORS Middleware - includes Netlify domains
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.all_cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)

# Observability Middleware (order matters: first added = outermost)
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

# Zero-Touch Reception Routers
app.include_router(nfc.router, prefix="/api/v1", tags=["NFC"])
app.include_router(led.router, prefix="/api/v1", tags=["LED & Wayfinding"])
app.include_router(websocket.router, prefix="/api/v1", tags=["WebSocket"])

# Push Notifications
app.include_router(push.router, prefix="/api/v1", tags=["Push Notifications"])

# Analytics
app.include_router(analytics.router, prefix="/api/v1", tags=["Analytics"])


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
