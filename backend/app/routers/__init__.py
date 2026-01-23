"""Routers package."""

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

__all__ = [
    "auth",
    "users",
    "queue",
    "tickets",
    "chat",
    "practice",
    "nfc",
    "led",
    "websocket",
    "push",
    "analytics",
    "document_requests",
    "consultations",
]
