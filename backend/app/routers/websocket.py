"""
WebSocket API Router for Real-Time Events.

Provides real-time updates to Flutter apps and web clients:
    - Ticket status changes.
    - Queue updates.
    - Check-in events.
    - LED status changes.
    - System notifications.

Protocol:
    - JSON messages with type field.
    - Heartbeat every 30 seconds.
    - Reconnection with exponential backoff.
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query, WebSocket, WebSocketDisconnect, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_async_session
from app.models.models import Queue, Ticket, TicketStatus, User

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ws", tags=["WebSocket"])


class ConnectionManager:
    """
    WebSocket connection manager.
    
    Manages active connections and broadcasts messages to clients.
    """
    
    def __init__(self) -> None:
        """Initialize connection manager."""
        # Connections by practice_id
        self._active_connections: dict[str, list[WebSocket]] = {}
        # Connections by specific topic (e.g., "ticket:123", "queue:abc")
        self._topic_subscriptions: dict[str, list[WebSocket]] = {}
    
    async def connect(
        self,
        websocket: WebSocket,
        practice_id: str,
        topics: list[str] | None = None,
    ) -> None:
        """
        Accept and register a WebSocket connection.
        
        Args:
            websocket: WebSocket connection.
            practice_id: Practice ID for broadcast filtering.
            topics: Optional specific topics to subscribe to.
        """
        await websocket.accept()
        
        # Add to practice connections
        if practice_id not in self._active_connections:
            self._active_connections[practice_id] = []
        self._active_connections[practice_id].append(websocket)
        
        # Add to topic subscriptions
        if topics:
            for topic in topics:
                if topic not in self._topic_subscriptions:
                    self._topic_subscriptions[topic] = []
                self._topic_subscriptions[topic].append(websocket)
        
        logger.info(
            "WebSocket connected",
            extra={"practice_id": practice_id, "topics": topics}
        )
    
    def disconnect(self, websocket: WebSocket, practice_id: str) -> None:
        """
        Remove a WebSocket connection.
        
        Args:
            websocket: WebSocket to remove.
            practice_id: Practice ID.
        """
        # Remove from practice connections
        if practice_id in self._active_connections:
            if websocket in self._active_connections[practice_id]:
                self._active_connections[practice_id].remove(websocket)
        
        # Remove from all topic subscriptions
        for topic in list(self._topic_subscriptions.keys()):
            if websocket in self._topic_subscriptions[topic]:
                self._topic_subscriptions[topic].remove(websocket)
            if not self._topic_subscriptions[topic]:
                del self._topic_subscriptions[topic]
        
        logger.info("WebSocket disconnected", extra={"practice_id": practice_id})
    
    async def broadcast_to_practice(
        self,
        practice_id: str,
        message: dict[str, Any],
    ) -> None:
        """
        Broadcast message to all connections in a practice.
        
        Args:
            practice_id: Target practice.
            message: Message payload.
        """
        if practice_id not in self._active_connections:
            return
        
        message_json = json.dumps(message, default=str)
        
        for connection in self._active_connections[practice_id]:
            try:
                await connection.send_text(message_json)
            except Exception as e:
                logger.warning("Failed to send message", extra={"error": str(e)})
    
    async def broadcast_to_topic(
        self,
        topic: str,
        message: dict[str, Any],
    ) -> None:
        """
        Broadcast message to all connections subscribed to a topic.
        
        Args:
            topic: Topic name (e.g., "ticket:123").
            message: Message payload.
        """
        if topic not in self._topic_subscriptions:
            return
        
        message_json = json.dumps(message, default=str)
        
        for connection in self._topic_subscriptions[topic]:
            try:
                await connection.send_text(message_json)
            except Exception as e:
                logger.warning("Failed to send topic message", extra={"error": str(e)})
    
    async def send_personal_message(
        self,
        websocket: WebSocket,
        message: dict[str, Any],
    ) -> None:
        """
        Send message to a specific connection.
        
        Args:
            websocket: Target connection.
            message: Message payload.
        """
        message_json = json.dumps(message, default=str)
        await websocket.send_text(message_json)
    
    def get_connection_count(self, practice_id: Optional[str] = None) -> int:
        """
        Get number of active connections.
        
        Args:
            practice_id: Optional filter by practice.
        
        Returns:
            Connection count.
        """
        if practice_id:
            return len(self._active_connections.get(practice_id, []))
        return sum(len(conns) for conns in self._active_connections.values())


# Global connection manager instance
manager = ConnectionManager()


def get_connection_manager() -> ConnectionManager:
    """Get the global connection manager."""
    return manager


# ============================================================================
# Message Types
# ============================================================================

class MessageType:
    """WebSocket message types."""
    # Server -> Client
    TICKET_CREATED = "ticket.created"
    TICKET_CALLED = "ticket.called"
    TICKET_COMPLETED = "ticket.completed"
    TICKET_CANCELLED = "ticket.cancelled"
    QUEUE_UPDATED = "queue.updated"
    CHECK_IN = "check_in"
    LED_STATUS = "led.status"
    WAIT_TIME_UPDATE = "wait_time.update"
    SYSTEM_NOTIFICATION = "system.notification"
    HEARTBEAT = "heartbeat"
    
    # Client -> Server
    SUBSCRIBE = "subscribe"
    UNSUBSCRIBE = "unsubscribe"
    PING = "ping"


# ============================================================================
# WebSocket Endpoints
# ============================================================================

@router.websocket("/events/{practice_id}")
async def websocket_events(
    websocket: WebSocket,
    practice_id: str,
    topics: Optional[str] = Query(None, description="Comma-separated topics"),
) -> None:
    """
    WebSocket endpoint for real-time events.
    
    Clients can subscribe to specific topics:
        - `queue:{queue_id}` - Updates for a specific queue.
        - `ticket:{ticket_number}` - Updates for a specific ticket.
        - `led` - LED status changes.
        - `wait_times` - Wait time updates.
    
    Example connection:
        ws://localhost:8000/api/v1/ws/events/practice-123?topics=queue:abc,led
    
    Message format:
        {
            "type": "ticket.called",
            "data": {...},
            "timestamp": "2026-01-13T10:30:00Z"
        }
    """
    # Parse topics
    topic_list = topics.split(",") if topics else None
    
    await manager.connect(websocket, practice_id, topic_list)
    
    try:
        # Send welcome message
        await manager.send_personal_message(websocket, {
            "type": "connected",
            "data": {
                "practice_id": practice_id,
                "subscribed_topics": topic_list,
                "server_time": datetime.utcnow().isoformat(),
            },
            "timestamp": datetime.utcnow().isoformat(),
        })
        
        # Start heartbeat task
        heartbeat_task = asyncio.create_task(
            _send_heartbeat(websocket, practice_id)
        )
        
        try:
            while True:
                # Wait for messages from client
                data = await websocket.receive_text()
                
                try:
                    message = json.loads(data)
                    await _handle_client_message(websocket, practice_id, message)
                except json.JSONDecodeError:
                    await manager.send_personal_message(websocket, {
                        "type": "error",
                        "data": {"message": "Invalid JSON"},
                        "timestamp": datetime.utcnow().isoformat(),
                    })
        
        finally:
            heartbeat_task.cancel()
            try:
                await heartbeat_task
            except asyncio.CancelledError:
                pass
    
    except WebSocketDisconnect:
        manager.disconnect(websocket, practice_id)
    except Exception as e:
        logger.error("WebSocket error", extra={"error": str(e)})
        manager.disconnect(websocket, practice_id)


async def _send_heartbeat(websocket: WebSocket, practice_id: str) -> None:
    """
    Send periodic heartbeat to keep connection alive.
    
    Args:
        websocket: WebSocket connection.
        practice_id: Practice ID.
    """
    while True:
        await asyncio.sleep(30)
        try:
            await manager.send_personal_message(websocket, {
                "type": MessageType.HEARTBEAT,
                "data": {
                    "server_time": datetime.utcnow().isoformat(),
                    "connections": manager.get_connection_count(practice_id),
                },
                "timestamp": datetime.utcnow().isoformat(),
            })
        except Exception:
            break


async def _handle_client_message(
    websocket: WebSocket,
    practice_id: str,
    message: dict[str, Any],
) -> None:
    """
    Handle incoming message from client.
    
    Args:
        websocket: WebSocket connection.
        practice_id: Practice ID.
        message: Parsed message.
    """
    msg_type = message.get("type", "")
    
    if msg_type == MessageType.PING:
        await manager.send_personal_message(websocket, {
            "type": "pong",
            "data": {},
            "timestamp": datetime.utcnow().isoformat(),
        })
    
    elif msg_type == MessageType.SUBSCRIBE:
        # Subscribe to additional topics
        topics = message.get("data", {}).get("topics", [])
        for topic in topics:
            if topic not in manager._topic_subscriptions:
                manager._topic_subscriptions[topic] = []
            if websocket not in manager._topic_subscriptions[topic]:
                manager._topic_subscriptions[topic].append(websocket)
        
        await manager.send_personal_message(websocket, {
            "type": "subscribed",
            "data": {"topics": topics},
            "timestamp": datetime.utcnow().isoformat(),
        })
    
    elif msg_type == MessageType.UNSUBSCRIBE:
        # Unsubscribe from topics
        topics = message.get("data", {}).get("topics", [])
        for topic in topics:
            if topic in manager._topic_subscriptions:
                if websocket in manager._topic_subscriptions[topic]:
                    manager._topic_subscriptions[topic].remove(websocket)
        
        await manager.send_personal_message(websocket, {
            "type": "unsubscribed",
            "data": {"topics": topics},
            "timestamp": datetime.utcnow().isoformat(),
        })
    
    else:
        await manager.send_personal_message(websocket, {
            "type": "error",
            "data": {"message": f"Unknown message type: {msg_type}"},
            "timestamp": datetime.utcnow().isoformat(),
        })


# ============================================================================
# Event Broadcasting Functions (called from other services)
# ============================================================================

async def broadcast_ticket_created(
    practice_id: str,
    ticket_data: dict[str, Any],
) -> None:
    """Broadcast ticket created event."""
    await manager.broadcast_to_practice(practice_id, {
        "type": MessageType.TICKET_CREATED,
        "data": ticket_data,
        "timestamp": datetime.utcnow().isoformat(),
    })
    
    # Also broadcast to queue topic
    queue_id = ticket_data.get("queue_id")
    if queue_id:
        await manager.broadcast_to_topic(f"queue:{queue_id}", {
            "type": MessageType.TICKET_CREATED,
            "data": ticket_data,
            "timestamp": datetime.utcnow().isoformat(),
        })


async def broadcast_ticket_called(
    practice_id: str,
    ticket_data: dict[str, Any],
) -> None:
    """Broadcast ticket called event."""
    await manager.broadcast_to_practice(practice_id, {
        "type": MessageType.TICKET_CALLED,
        "data": ticket_data,
        "timestamp": datetime.utcnow().isoformat(),
    })
    
    # Broadcast to specific ticket topic
    ticket_number = ticket_data.get("ticket_number")
    if ticket_number:
        await manager.broadcast_to_topic(f"ticket:{ticket_number}", {
            "type": MessageType.TICKET_CALLED,
            "data": ticket_data,
            "timestamp": datetime.utcnow().isoformat(),
        })


async def broadcast_check_in(
    practice_id: str,
    check_in_data: dict[str, Any],
) -> None:
    """Broadcast check-in event."""
    await manager.broadcast_to_practice(practice_id, {
        "type": MessageType.CHECK_IN,
        "data": check_in_data,
        "timestamp": datetime.utcnow().isoformat(),
    })


async def broadcast_wait_time_update(
    practice_id: str,
    wait_time_data: dict[str, Any],
) -> None:
    """Broadcast wait time update."""
    await manager.broadcast_to_topic("wait_times", {
        "type": MessageType.WAIT_TIME_UPDATE,
        "data": wait_time_data,
        "timestamp": datetime.utcnow().isoformat(),
    })


async def broadcast_led_status(
    practice_id: str,
    led_data: dict[str, Any],
) -> None:
    """Broadcast LED status change."""
    await manager.broadcast_to_topic("led", {
        "type": MessageType.LED_STATUS,
        "data": led_data,
        "timestamp": datetime.utcnow().isoformat(),
    })


# ============================================================================
# HTTP Endpoints for Testing
# ============================================================================

@router.get("/connections")
async def get_connections(
    practice_id: Optional[str] = Query(None),
) -> dict[str, int]:
    """
    Get active WebSocket connection count.
    
    Args:
        practice_id: Optional filter.
    
    Returns:
        Connection count.
    """
    return {"connections": manager.get_connection_count(practice_id)}
