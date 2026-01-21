"""
LED & Wayfinding API Router for Zero-Touch Reception.

Endpoints for:
    - LED controller management.
    - Zone configuration.
    - Wayfinding route activation.
    - Wait time visualization.

WLED Integration:
    - Segments are configured per zone.
    - Routes connect multiple segments.
    - Colors/patterns are triggered via HTTP JSON API.
"""

import logging
import secrets
from datetime import datetime, timedelta
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from passlib.context import CryptContext
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import (
    DeviceStatus,
    DeviceType,
    IoTDevice,
    LEDPattern,
    LEDSegment,
    Queue,
    Ticket,
    TicketStatus,
    User,
    UserRole,
    WayfindingRoute,
    WayfindingRouteSegment,
    Zone,
)
_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")

from app.schemas.schemas import (
    ErrorResponse,
    IoTDeviceCreate,
    IoTDeviceListResponse,
    IoTDeviceResponse,
    IoTDeviceUpdate,
    LEDCommandRequest,
    LEDCommandResponse,
    LEDSegmentCreate,
    LEDSegmentResponse,
    MessageResponse,
    TriggerRouteRequest,
    TriggerRouteResponse,
    WaitTimeOverviewResponse,
    WaitTimeStatus,
    WaitTimeVisualization,
    WayfindingRouteCreate,
    WayfindingRouteListResponse,
    WayfindingRouteResponse,
    ZoneCreate,
    ZoneListResponse,
    ZoneResponse,
)
from app.services.led_service import LEDService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/led", tags=["LED & Wayfinding"])


# ============================================================================
# IoT Device Management
# ============================================================================

@router.get(
    "/devices",
    response_model=IoTDeviceListResponse,
    summary="IoT-Geräte abrufen",
)
async def list_devices(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    device_type: Optional[DeviceType] = Query(None, description="Filter by device type"),
    status_filter: Optional[DeviceStatus] = Query(None, alias="status"),
) -> IoTDeviceListResponse:
    """
    List all IoT devices for the practice.
    
    Args:
        db: Database session.
        current_user: Authenticated user.
        device_type: Optional filter.
        status_filter: Optional filter.
    
    Returns:
        List of devices.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Zugriff verweigert"
        )
    
    query = select(IoTDevice).order_by(IoTDevice.device_name)
    
    if device_type:
        query = query.where(IoTDevice.device_type == device_type)
    
    if status_filter:
        query = query.where(IoTDevice.status == status_filter)
    
    result = await db.execute(query)
    devices = list(result.scalars().all())
    
    return IoTDeviceListResponse(
        items=[IoTDeviceResponse.model_validate(d) for d in devices],
        total=len(devices)
    )


@router.post(
    "/devices",
    response_model=IoTDeviceResponse,
    status_code=status.HTTP_201_CREATED,
    summary="IoT-Gerät registrieren",
)
async def register_device(
    request: IoTDeviceCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> IoTDeviceResponse:
    """
    Register a new IoT device.
    
    Args:
        request: Device registration data.
        db: Database session.
        current_user: Authenticated user (admin only).
    
    Returns:
        Created device info.
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur Admins können Geräte registrieren"
        )
    
    # Check for duplicate serial
    existing = await db.execute(
        select(IoTDevice).where(IoTDevice.device_serial == request.device_serial)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Geräte-Seriennummer bereits registriert"
        )
    
    # Get practice ID from first practice (single-tenant for MVP)
    from app.models.models import Practice
    practice_result = await db.execute(select(Practice).limit(1))
    practice = practice_result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Keine Praxis konfiguriert"
        )
    
    # Generate secure device secret (32 bytes = 64 hex chars)
    plain_secret = secrets.token_hex(32)
    
    device = IoTDevice(
        practice_id=practice.id,
        device_type=request.device_type,
        device_name=request.device_name,
        device_serial=request.device_serial,
        device_secret_hash=_pwd_ctx.hash(plain_secret),
        location=request.location,
        ip_address=request.ip_address,
        firmware_version=request.firmware_version,
        status=DeviceStatus.OFFLINE,
    )
    
    db.add(device)
    await db.commit()
    await db.refresh(device)
    
    logger.info(
        "IoT device registered",
        extra={"device_id": str(device.id), "type": request.device_type.value}
    )
    
    # Return response with plain secret (only time it's visible)
    response = IoTDeviceResponse.model_validate(device)
    response.device_secret = plain_secret  # One-time display
    return response


@router.patch(
    "/devices/{device_id}",
    response_model=IoTDeviceResponse,
    summary="IoT-Gerät aktualisieren",
)
async def update_device(
    device_id: UUID,
    request: IoTDeviceUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> IoTDeviceResponse:
    """
    Update IoT device configuration.
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur Admins können Geräte bearbeiten"
        )
    
    result = await db.execute(
        select(IoTDevice).where(IoTDevice.id == device_id)
    )
    device = result.scalar_one_or_none()
    
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Gerät nicht gefunden"
        )
    
    update_data = request.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(device, field, value)
    
    await db.commit()
    await db.refresh(device)
    
    return IoTDeviceResponse.model_validate(device)


# ============================================================================
# Zone Management
# ============================================================================

@router.get(
    "/zones",
    response_model=ZoneListResponse,
    summary="Zonen abrufen",
)
async def list_zones(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ZoneListResponse:
    """
    List all configured zones.
    """
    result = await db.execute(
        select(Zone).where(Zone.is_active == True).order_by(Zone.zone_name)
    )
    zones = list(result.scalars().all())
    
    return ZoneListResponse(
        items=[ZoneResponse.model_validate(z) for z in zones],
        total=len(zones)
    )


@router.post(
    "/zones",
    response_model=ZoneResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Zone erstellen",
)
async def create_zone(
    request: ZoneCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ZoneResponse:
    """
    Create a new zone.
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur Admins können Zonen erstellen"
        )
    
    # Get practice ID
    from app.models.models import Practice
    practice_result = await db.execute(select(Practice).limit(1))
    practice = practice_result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Keine Praxis konfiguriert"
        )
    
    zone = Zone(
        practice_id=practice.id,
        zone_name=request.zone_name,
        zone_code=request.zone_code.upper(),
        zone_type=request.zone_type,
        default_color=request.default_color,
    )
    
    db.add(zone)
    await db.commit()
    await db.refresh(zone)
    
    logger.info("Zone created", extra={"zone_id": str(zone.id), "code": zone.zone_code})
    
    return ZoneResponse.model_validate(zone)


# ============================================================================
# Wayfinding Routes
# ============================================================================

@router.get(
    "/routes",
    response_model=WayfindingRouteListResponse,
    summary="Wegführungs-Routen abrufen",
)
async def list_routes(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> WayfindingRouteListResponse:
    """
    List all wayfinding routes.
    """
    result = await db.execute(
        select(WayfindingRoute)
        .where(WayfindingRoute.is_active == True)
        .order_by(WayfindingRoute.route_name)
    )
    routes = list(result.scalars().all())
    
    return WayfindingRouteListResponse(
        items=[WayfindingRouteResponse.model_validate(r) for r in routes],
        total=len(routes)
    )


@router.post(
    "/routes",
    response_model=WayfindingRouteResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Wegführungs-Route erstellen",
)
async def create_route(
    request: WayfindingRouteCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> WayfindingRouteResponse:
    """
    Create a new wayfinding route.
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nur Admins können Routen erstellen"
        )
    
    # Get practice ID
    from app.models.models import Practice
    practice_result = await db.execute(select(Practice).limit(1))
    practice = practice_result.scalar_one_or_none()
    
    if not practice:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Keine Praxis konfiguriert"
        )
    
    route = WayfindingRoute(
        practice_id=practice.id,
        route_name=request.route_name,
        from_zone_id=request.from_zone_id,
        to_zone_id=request.to_zone_id,
        led_pattern=request.led_pattern,
        route_color=request.route_color,
        animation_speed=request.animation_speed,
    )
    
    db.add(route)
    await db.flush()  # Get route ID
    
    # Create segment associations
    for order, segment_id in enumerate(request.segment_ids):
        assoc = WayfindingRouteSegment(
            route_id=route.id,
            segment_id=segment_id,
            segment_order=order,
        )
        db.add(assoc)
    
    await db.commit()
    await db.refresh(route)
    
    logger.info("Route created", extra={"route_id": str(route.id)})
    
    return WayfindingRouteResponse.model_validate(route)


@router.post(
    "/routes/trigger",
    response_model=TriggerRouteResponse,
    summary="Wegführungs-Route aktivieren",
)
async def trigger_route(
    request: TriggerRouteRequest,
    db: AsyncSession = Depends(get_db),
) -> TriggerRouteResponse:
    """
    Trigger a wayfinding route to light up.
    
    Called automatically after NFC check-in or manually by staff.
    
    Args:
        request: Route trigger data.
        db: Database session.
    
    Returns:
        Trigger confirmation with expiration time.
    """
    result = await db.execute(
        select(WayfindingRoute).where(WayfindingRoute.id == request.route_id)
    )
    route = result.scalar_one_or_none()
    
    if not route:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Route nicht gefunden"
        )
    
    # Initialize LED service
    led_service = LEDService(db)
    
    try:
        success = await led_service.activate_wayfinding_route(route.id)
        
        if not success:
            logger.warning("Route activation failed", extra={"route_id": str(route.id)})
            return TriggerRouteResponse(
                success=False,
                message="LED-Controller nicht erreichbar",
                route_id=route.id,
                expires_at=datetime.utcnow(),
            )
        
        expires_at = datetime.utcnow() + timedelta(seconds=request.duration_seconds)
        
        logger.info(
            "Route triggered",
            extra={
                "route_id": str(route.id),
                "duration": request.duration_seconds,
            }
        )
        
        return TriggerRouteResponse(
            success=True,
            message=f"Route '{route.route_name}' aktiviert",
            route_id=route.id,
            expires_at=expires_at,
        )
    
    finally:
        await led_service.close()


# ============================================================================
# Direct LED Control
# ============================================================================

@router.post(
    "/command",
    response_model=LEDCommandResponse,
    summary="LED-Direktsteuerung",
)
async def send_led_command(
    request: LEDCommandRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> LEDCommandResponse:
    """
    Send direct command to LED controller.
    
    For testing and manual override.
    """
    if current_user.role not in [UserRole.ADMIN, UserRole.MFA]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Zugriff verweigert"
        )
    
    # Get controller
    result = await db.execute(
        select(IoTDevice)
        .where(IoTDevice.id == request.controller_id)
        .where(IoTDevice.device_type == DeviceType.LED_CONTROLLER)
    )
    controller = result.scalar_one_or_none()
    
    if not controller:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="LED-Controller nicht gefunden"
        )
    
    if not controller.ip_address:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Controller hat keine IP-Adresse konfiguriert"
        )
    
    led_service = LEDService(db)
    
    try:
        success = await led_service.set_segment_color(
            controller_ip=controller.ip_address,
            segment_id=request.segment_id,
            color=request.color,
            brightness=request.brightness,
            effect=request.pattern,
        )
        
        return LEDCommandResponse(
            success=success,
            controller_id=request.controller_id,
            segment_id=request.segment_id,
        )
    
    finally:
        await led_service.close()


# ============================================================================
# Wait Time Visualization
# ============================================================================

@router.get(
    "/wait-times",
    response_model=WaitTimeOverviewResponse,
    summary="Wartezeit-Übersicht",
)
async def get_wait_time_overview(
    db: AsyncSession = Depends(get_db),
) -> WaitTimeOverviewResponse:
    """
    Get current wait time visualization data for all zones.
    
    Used by LED controllers to show wait time colors.
    """
    # Get all waiting zones
    result = await db.execute(
        select(Zone)
        .where(Zone.is_active == True)
        .where(Zone.zone_type == "waiting")
    )
    zones = list(result.scalars().all())
    
    visualizations = []
    total_waiting = 0
    total_wait_time = 0
    
    for zone in zones:
        # Get waiting tickets for queues assigned to this zone
        ticket_result = await db.execute(
            select(Ticket)
            .join(Queue, Ticket.queue_id == Queue.id)
            .where(Queue.zone_id == zone.id)
            .where(Ticket.status == TicketStatus.WAITING)
        )
        tickets = list(ticket_result.scalars().all())
        
        patient_count = len(tickets)
        total_waiting += patient_count
        
        # Calculate average wait time
        if tickets:
            wait_times = []
            for ticket in tickets:
                wait_minutes = int((datetime.utcnow() - ticket.created_at).total_seconds() / 60)
                wait_times.append(wait_minutes)
            
            avg_wait = sum(wait_times) / len(wait_times)
            max_wait = max(wait_times)
            total_wait_time += sum(wait_times)
        else:
            avg_wait = 0
            max_wait = 0
        
        # Determine status and color
        if max_wait < 10:
            wait_status = WaitTimeStatus.OK
            color = "#00FF00"  # Green
        elif max_wait < 20:
            wait_status = WaitTimeStatus.WARNING
            color = "#FFFF00"  # Yellow
        else:
            wait_status = WaitTimeStatus.CRITICAL
            color = "#FF0000"  # Red
        
        visualizations.append(WaitTimeVisualization(
            zone_id=zone.id,
            zone_name=zone.name,
            current_wait_minutes=int(max_wait),
            status=wait_status,
            color=color,
            patient_count=patient_count,
        ))
    
    avg_overall = total_wait_time / total_waiting if total_waiting > 0 else 0
    
    return WaitTimeOverviewResponse(
        zones=visualizations,
        total_waiting=total_waiting,
        average_wait_minutes=round(avg_overall, 1),
        updated_at=datetime.utcnow(),
    )
