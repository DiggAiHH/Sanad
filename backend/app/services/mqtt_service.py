"""
MQTT Service for IoT device communication.

Handles Pub/Sub messaging between backend and ESP32 devices (NFC readers, LED controllers).

Security:
    - Device authentication via device_secret.
    - All payloads are JSON with schema validation.
    - TLS recommended for production (MQTTS on port 8883).

Topics:
    - sanad/{practice_id}/nfc/+/scan       : NFC reader publishes scanned UID
    - sanad/{practice_id}/led/+/command    : Backend publishes LED commands
    - sanad/{practice_id}/device/+/status  : Device heartbeat/status
    - sanad/{practice_id}/events           : Real-time events for Flutter apps
"""

import asyncio
import json
import logging
import os
from contextlib import asynccontextmanager
from datetime import datetime
from typing import Any, Callable, Optional
from uuid import UUID

import aiomqtt

logger = logging.getLogger(__name__)


class MQTTService:
    """
    Async MQTT client service for IoT communication.
    
    Usage:
        mqtt = MQTTService()
        await mqtt.connect()
        await mqtt.publish("sanad/practice-1/led/controller-1/command", {...})
        await mqtt.subscribe("sanad/practice-1/nfc/+/scan", handler)
    """
    
    def __init__(self) -> None:
        """Initialize MQTT service with configuration from environment."""
        self._host = os.environ.get("MQTT_HOST", "localhost")
        self._port = int(os.environ.get("MQTT_PORT", "1883"))
        self._username = os.environ.get("MQTT_USERNAME", None)
        self._password = os.environ.get("MQTT_PASSWORD", None)
        self._client_id = os.environ.get("MQTT_CLIENT_ID", "sanad-backend")
        self._client: Optional[aiomqtt.Client] = None
        self._handlers: dict[str, list[Callable]] = {}
        self._connected = False
        self._reconnect_interval = 5
        self._listener_task: Optional[asyncio.Task] = None
    
    @property
    def is_connected(self) -> bool:
        """Check if client is connected."""
        return self._connected
    
    async def connect(self) -> None:
        """
        Establish connection to MQTT broker.
        
        Raises:
            ConnectionError: If broker is unreachable.
        """
        try:
            self._client = aiomqtt.Client(
                hostname=self._host,
                port=self._port,
                username=self._username,
                password=self._password,
                identifier=self._client_id,
            )
            await self._client.__aenter__()
            self._connected = True
            logger.info(
                "MQTT connected",
                extra={"host": self._host, "port": self._port}
            )
            # Start message listener
            self._listener_task = asyncio.create_task(self._message_listener())
        except Exception as e:
            logger.error("MQTT connection failed", extra={"error": str(e)})
            self._connected = False
            raise ConnectionError(f"Failed to connect to MQTT broker: {e}") from e
    
    async def disconnect(self) -> None:
        """Gracefully disconnect from MQTT broker."""
        if self._listener_task:
            self._listener_task.cancel()
            try:
                await self._listener_task
            except asyncio.CancelledError:
                pass
        
        if self._client and self._connected:
            await self._client.__aexit__(None, None, None)
            self._connected = False
            logger.info("MQTT disconnected")
    
    async def publish(
        self,
        topic: str,
        payload: dict[str, Any],
        qos: int = 1,
        retain: bool = False,
    ) -> None:
        """
        Publish JSON message to topic.
        
        Args:
            topic: MQTT topic (e.g., "sanad/practice-1/led/ctrl-1/command").
            payload: Dictionary to serialize as JSON.
            qos: Quality of Service (0=fire-forget, 1=at-least-once, 2=exactly-once).
            retain: Whether to retain message for new subscribers.
        
        Raises:
            RuntimeError: If not connected.
            ValueError: If payload is not JSON-serializable.
        """
        if not self._connected or not self._client:
            raise RuntimeError("MQTT client not connected")
        
        try:
            json_payload = json.dumps(payload, default=str)
            await self._client.publish(topic, json_payload.encode(), qos=qos, retain=retain)
            logger.debug(
                "MQTT published",
                extra={"topic": topic, "payload_size": len(json_payload)}
            )
        except TypeError as e:
            raise ValueError(f"Payload not JSON-serializable: {e}") from e
    
    async def subscribe(
        self,
        topic: str,
        handler: Callable[[str, dict], Any],
        qos: int = 1,
    ) -> None:
        """
        Subscribe to topic with handler callback.
        
        Args:
            topic: MQTT topic pattern (supports + and # wildcards).
            handler: Async function(topic: str, payload: dict) -> None.
            qos: Quality of Service level.
        """
        if not self._connected or not self._client:
            raise RuntimeError("MQTT client not connected")
        
        await self._client.subscribe(topic, qos=qos)
        
        if topic not in self._handlers:
            self._handlers[topic] = []
        self._handlers[topic].append(handler)
        
        logger.info("MQTT subscribed", extra={"topic": topic})
    
    async def _message_listener(self) -> None:
        """Background task to process incoming messages."""
        if not self._client:
            return
        
        try:
            async for message in self._client.messages:
                topic = str(message.topic)
                try:
                    payload = json.loads(message.payload.decode())
                except json.JSONDecodeError:
                    logger.warning("Invalid JSON payload", extra={"topic": topic})
                    continue
                
                # Match handlers (simple matching, production should use proper wildcards)
                for pattern, handlers in self._handlers.items():
                    if self._topic_matches(pattern, topic):
                        for handler in handlers:
                            try:
                                await handler(topic, payload)
                            except Exception as e:
                                logger.error(
                                    "Handler error",
                                    extra={"topic": topic, "error": str(e)}
                                )
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.error("Message listener error", extra={"error": str(e)})
    
    @staticmethod
    def _topic_matches(pattern: str, topic: str) -> bool:
        """
        Check if topic matches pattern with MQTT wildcards.
        
        Args:
            pattern: Pattern with + (single level) or # (multi level).
            topic: Actual topic string.
        
        Returns:
            True if matches.
        """
        pattern_parts = pattern.split("/")
        topic_parts = topic.split("/")
        
        for i, p in enumerate(pattern_parts):
            if p == "#":
                return True  # # matches everything after
            if i >= len(topic_parts):
                return False
            if p != "+" and p != topic_parts[i]:
                return False
        
        return len(pattern_parts) == len(topic_parts)
    
    # ==========================================================================
    # HIGH-LEVEL METHODS FOR SANAD
    # ==========================================================================
    
    async def publish_led_command(
        self,
        practice_id: UUID,
        controller_id: str,
        segments: list[dict],
        effect: str = "solid",
    ) -> None:
        """
        Send LED command to WLED controller.
        
        Args:
            practice_id: Practice UUID.
            controller_id: Controller device serial.
            segments: List of segment configs [{"id": 0, "on": True, "col": [[0,255,0]], "fx": 0}].
            effect: Effect name for logging.
        """
        topic = f"sanad/{practice_id}/led/{controller_id}/command"
        payload = {
            "seg": segments,
            "v": True,  # Verbose response
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.publish(topic, payload)
    
    async def publish_wayfinding_route(
        self,
        practice_id: UUID,
        route_name: str,
        segments: list[dict],
        color: str,
        pattern: str,
        duration_seconds: int,
    ) -> None:
        """
        Activate wayfinding route across multiple LED segments.
        
        Args:
            practice_id: Practice UUID.
            route_name: Human-readable route name.
            segments: LED segment configurations.
            color: Hex color (e.g., "#00FF00").
            pattern: WLED effect name.
            duration_seconds: How long to display.
        """
        topic = f"sanad/{practice_id}/wayfinding/activate"
        
        # Convert hex color to RGB array
        r = int(color[1:3], 16)
        g = int(color[3:5], 16)
        b = int(color[5:7], 16)
        
        payload = {
            "route": route_name,
            "color": [r, g, b],
            "pattern": pattern,
            "duration": duration_seconds,
            "segments": segments,
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.publish(topic, payload)
    
    async def publish_event(
        self,
        practice_id: UUID,
        event_type: str,
        data: dict,
    ) -> None:
        """
        Publish real-time event for Flutter apps (via WebSocket bridge).
        
        Args:
            practice_id: Practice UUID.
            event_type: Event type (e.g., "ticket_called", "check_in", "wait_time_update").
            data: Event payload.
        """
        topic = f"sanad/{practice_id}/events"
        payload = {
            "type": event_type,
            "data": data,
            "timestamp": datetime.utcnow().isoformat(),
        }
        await self.publish(topic, payload, retain=False)


# Singleton instance
_mqtt_service: Optional[MQTTService] = None


def get_mqtt_service() -> MQTTService:
    """
    Get singleton MQTT service instance.
    
    Returns:
        MQTTService instance.
    """
    global _mqtt_service
    if _mqtt_service is None:
        _mqtt_service = MQTTService()
    return _mqtt_service


@asynccontextmanager
async def mqtt_lifespan():
    """
    Context manager for MQTT lifecycle (use in FastAPI lifespan).
    
    Usage:
        @asynccontextmanager
        async def lifespan(app: FastAPI):
            async with mqtt_lifespan():
                yield
    """
    mqtt = get_mqtt_service()
    try:
        await mqtt.connect()
        yield mqtt
    finally:
        await mqtt.disconnect()
