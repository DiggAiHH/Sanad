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
from app.routers import auth, users, queue, tickets, chat, practice


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
        print("🌱 Demo-Daten geladen")
    except Exception as e:
        print(f"⚠️  Seed übersprungen (Daten existieren evtl. schon): {e}")


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Application lifespan handler for startup/shutdown events.
    
    Args:
        app: FastAPI application instance.
        
    Yields:
        None: Application is running.
    """
    # Startup
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    await init_db()
    await seed_demo_data()
    yield
    # Shutdown
    print(f"👋 Shutting down {settings.APP_NAME}")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Sanad - Deutsches Praxismanagement-System API",
    lifespan=lifespan,
    # Always show docs for testing phase
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(queue.router, prefix="/api/v1/queue", tags=["Queue"])
app.include_router(tickets.router, prefix="/api/v1/tickets", tags=["Tickets"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
app.include_router(practice.router, prefix="/api/v1/practice", tags=["Practice"])


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    """
    Health check endpoint for container orchestration.
    
    Returns:
        dict: Health status.
    """
    return {"status": "healthy", "version": settings.APP_VERSION}


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
