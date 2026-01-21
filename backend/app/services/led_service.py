"""
LED Service for wayfinding and visual feedback.

Controls WLED-based LED strips via MQTT and HTTP API.

Features:
    - Wayfinding route activation (animated paths).
    - Wait time visualization (color gradient: green -> yellow -> red).
    - Zone status indicators.

WLED Integration:
    - Uses JSON API for direct HTTP control.
    - Uses MQTT for real-time event-driven updates.
"""

import asyncio
import json
import logging
from datetime import datetime
from typing import Any, Optional
from uuid import UUID

import httpx
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import (
    IoTDevice,
    DeviceStatus,
    DeviceType,
    LEDPattern,
    LEDSegment,
    WayfindingRoute,
    Zone,
)
from app.services.mqtt_service import get_mqtt_service

logger = logging.getLogger(__name__)


# WLED Effect IDs mapping
WLED_EFFECTS = {
    LEDPattern.SOLID: 0,
    LEDPattern.PULSE: 2,      # Breathe
    LEDPattern.CHASE: 28,     # Chase
    LEDPattern.RAINBOW: 9,    # Rainbow
    LEDPattern.BREATHE: 2,    # Breathe
    LEDPattern.WIPE: 24,      # Wipe
}


class LEDService:
    """
    Service for LED strip control and wayfinding.
    
    Supports both HTTP (direct) and MQTT (event-driven) communication.
    """
    
    def __init__(self, db: AsyncSession) -> None:
        """
        Initialize LED service.
        
        Args:
            db: Async database session.
        """
        self._db = db
        self._http_client = httpx.AsyncClient(timeout=5.0)
    
    async def close(self) -> None:
        """Close HTTP client."""
        await self._http_client.aclose()
    
    @staticmethod
    def hex_to_rgb(hex_color: str) -> list[int]:
        """
        Convert hex color to RGB array.
        
        Args:
            hex_color: Hex color string (e.g., "#00FF00").
        
        Returns:
            RGB array [R, G, B].
        """
        hex_color = hex_color.lstrip("#")
        return [
            int(hex_color[0:2], 16),
            int(hex_color[2:4], 16),
            int(hex_color[4:6], 16),
        ]
    
    async def get_controller(self, device_id: UUID) -> Optional[IoTDevice]:
        """
        Get LED controller device by ID.
        
        Args:
            device_id: Device UUID.
        
        Returns:
            IoTDevice or None.
        """
        result = await self._db.execute(
            select(IoTDevice)
            .where(IoTDevice.id == device_id)
            .where(IoTDevice.device_type == DeviceType.LED_CONTROLLER)
        )
        return result.scalar_one_or_none()
    
    async def get_zone_segments(self, zone_id: UUID) -> list[LEDSegment]:
        """
        Get all LED segments for a zone.
        
        Args:
            zone_id: Zone UUID.
        
        Returns:
            List of LEDSegment.
        """
        result = await self._db.execute(
            select(LEDSegment)
            .where(LEDSegment.zone_id == zone_id)
            .where(LEDSegment.is_active == True)
        )
        return list(result.scalars().all())
    
    async def send_wled_command(
        self,
        controller_ip: str,
        payload: dict[str, Any],
    ) -> bool:
        """
        Send command to WLED controller via HTTP JSON API.
        
        Args:
            controller_ip: Controller IP address.
            payload: WLED JSON payload.
        
        Returns:
            True if successful.
        """
        url = f"http://{controller_ip}/json"
        
        try:
            response = await self._http_client.post(url, json=payload)
            response.raise_for_status()
            logger.debug(
                "WLED command sent",
                extra={"ip": controller_ip, "status": response.status_code}
            )
            return True
        except httpx.HTTPError as e:
            logger.error(
                "WLED command failed",
                extra={"ip": controller_ip, "error": str(e)}
            )
            return False
    
    async def set_segment_color(
        self,
        controller_ip: str,
        segment_id: int,
        color: str,
        brightness: int = 255,
        effect: LEDPattern = LEDPattern.SOLID,
    ) -> bool:
        """
        Set color and effect for a single segment.
        
        Args:
            controller_ip: Controller IP.
            segment_id: WLED segment ID (0-15).
            color: Hex color.
            brightness: Brightness 0-255.
            effect: LED effect pattern.
        
        Returns:
            True if successful.
        """
        rgb = self.hex_to_rgb(color)
        effect_id = WLED_EFFECTS.get(effect, 0)
        
        payload = {
            "seg": [{
                "id": segment_id,
                "on": True,
                "bri": brightness,
                "col": [rgb],
                "fx": effect_id,
            }]
        }
        
        return await self.send_wled_command(controller_ip, payload)
    
    async def activate_wayfinding_route(
        self,
        route_id: UUID,
    ) -> bool:
        """
        Activate a pre-defined wayfinding route.
        
        Lights up all segments in the route with animated effect.
        
        Args:
            route_id: WayfindingRoute UUID.
        
        Returns:
            True if at least one segment activated.
        """
        # Get route
        result = await self._db.execute(
            select(WayfindingRoute).where(WayfindingRoute.id == route_id)
        )
        route = result.scalar_one_or_none()
        
        if not route or not route.is_active:
            logger.warning("Route not found or inactive", extra={"route_id": str(route_id)})
            return False
        
        # Parse segment IDs
        try:
            segment_ids = json.loads(route.led_segment_ids)
        except json.JSONDecodeError:
            logger.error("Invalid segment IDs JSON", extra={"route_id": str(route_id)})
            return False
        
        if not segment_ids:
            return False
        
        # Get segments with controller info
        success_count = 0
        rgb = self.hex_to_rgb(route.led_color)
        effect_id = WLED_EFFECTS.get(route.led_pattern, 0)
        
        for seg_id_str in segment_ids:
            seg_result = await self._db.execute(
                select(LEDSegment)
                .join(IoTDevice, LEDSegment.controller_device_id == IoTDevice.id)
                .where(LEDSegment.id == seg_id_str)
            )
            segment = seg_result.scalar_one_or_none()
            
            if not segment:
                continue
            
            # Get controller IP
            ctrl_result = await self._db.execute(
                select(IoTDevice).where(IoTDevice.id == segment.controller_device_id)
            )
            controller = ctrl_result.scalar_one_or_none()
            
            if not controller or not controller.ip_address:
                continue
            
            # Build WLED segment command
            payload = {
                "seg": [{
                    "id": segment.segment_id,
                    "on": True,
                    "bri": 255,
                    "col": [rgb],
                    "fx": effect_id,
                }]
            }
            
            if await self.send_wled_command(controller.ip_address, payload):
                success_count += 1
        
        # Also publish via MQTT for redundancy
        try:
            mqtt = get_mqtt_service()
            if mqtt.is_connected:
                await mqtt.publish_wayfinding_route(
                    practice_id=route.practice_id,
                    route_name=route.name,
                    segments=segment_ids,
                    color=route.led_color,
                    pattern=route.led_pattern.value,
                    duration_seconds=route.duration_seconds,
                )
        except Exception as e:
            logger.warning("MQTT publish failed", extra={"error": str(e)})
        
        logger.info(
            "Wayfinding route activated",
            extra={
                "route": route.name,
                "segments_activated": success_count,
                "total_segments": len(segment_ids),
            }
        )
        
        # Schedule deactivation after duration
        asyncio.create_task(
            self._deactivate_route_after(route_id, route.duration_seconds)
        )
        
        return success_count > 0
    
    async def _deactivate_route_after(self, route_id: UUID, seconds: int) -> None:
        """
        Deactivate route after specified duration.
        
        Args:
            route_id: Route UUID.
            seconds: Delay in seconds.
        """
        await asyncio.sleep(seconds)
        await self.deactivate_route(route_id)
    
    async def deactivate_route(self, route_id: UUID) -> bool:
        """
        Turn off all segments in a route.
        
        Args:
            route_id: WayfindingRoute UUID.
        
        Returns:
            True if successful.
        """
        result = await self._db.execute(
            select(WayfindingRoute).where(WayfindingRoute.id == route_id)
        )
        route = result.scalar_one_or_none()
        
        if not route:
            return False
        
        try:
            segment_ids = json.loads(route.led_segment_ids)
        except json.JSONDecodeError:
            return False
        
        for seg_id_str in segment_ids:
            seg_result = await self._db.execute(
                select(LEDSegment)
                .where(LEDSegment.id == seg_id_str)
            )
            segment = seg_result.scalar_one_or_none()
            
            if not segment:
                continue
            
            ctrl_result = await self._db.execute(
                select(IoTDevice).where(IoTDevice.id == segment.controller_device_id)
            )
            controller = ctrl_result.scalar_one_or_none()
            
            if controller and controller.ip_address:
                payload = {
                    "seg": [{
                        "id": segment.segment_id,
                        "on": False,
                    }]
                }
                await self.send_wled_command(controller.ip_address, payload)
        
        logger.info("Wayfinding route deactivated", extra={"route": route.name})
        return True
    
    async def update_wait_time_indicator(
        self,
        zone_id: UUID,
        average_wait_minutes: int,
    ) -> bool:
        """
        Update waiting area LED color based on wait time.
        
        Color mapping:
            - Green (#00FF00): < 10 minutes
            - Yellow (#FFFF00): 10-20 minutes  
            - Orange (#FF8000): 20-30 minutes
            - Red (#FF0000): > 30 minutes
        
        Args:
            zone_id: Waiting area zone UUID.
            average_wait_minutes: Current average wait time.
        
        Returns:
            True if updated.
        """
        # Determine color based on wait time
        if average_wait_minutes < 10:
            color = "#00FF00"  # Green
        elif average_wait_minutes < 20:
            color = "#FFFF00"  # Yellow
        elif average_wait_minutes < 30:
            color = "#FF8000"  # Orange
        else:
            color = "#FF0000"  # Red
        
        # Get zone segments
        segments = await self.get_zone_segments(zone_id)
        
        if not segments:
            return False
        
        success_count = 0
        
        for segment in segments:
            ctrl_result = await self._db.execute(
                select(IoTDevice).where(IoTDevice.id == segment.controller_device_id)
            )
            controller = ctrl_result.scalar_one_or_none()
            
            if controller and controller.ip_address:
                if await self.set_segment_color(
                    controller.ip_address,
                    segment.segment_id,
                    color,
                    brightness=128,  # Dimmer for ambient
                    effect=LEDPattern.BREATHE,
                ):
                    success_count += 1
        
        logger.info(
            "Wait time indicator updated",
            extra={
                "zone_id": str(zone_id),
                "wait_minutes": average_wait_minutes,
                "color": color,
            }
        )
        
        return success_count > 0
    
    async def set_all_off(self, practice_id: UUID) -> int:
        """
        Turn off all LED controllers for a practice.
        
        Args:
            practice_id: Practice UUID.
        
        Returns:
            Number of controllers turned off.
        """
        result = await self._db.execute(
            select(IoTDevice)
            .where(IoTDevice.practice_id == practice_id)
            .where(IoTDevice.device_type == DeviceType.LED_CONTROLLER)
            .where(IoTDevice.is_active == True)
        )
        controllers = result.scalars().all()
        
        count = 0
        for ctrl in controllers:
            if ctrl.ip_address:
                payload = {"on": False}
                if await self.send_wled_command(ctrl.ip_address, payload):
                    count += 1
        
        logger.info(
            "All LEDs turned off",
            extra={"practice_id": str(practice_id), "count": count}
        )
        return count
