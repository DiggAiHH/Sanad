"""
Analytics Router for Sanad Zero-Touch Reception.

Provides endpoints for:
    - Daily/weekly/monthly statistics
    - Queue performance metrics
    - Wait time trends
    - Check-in patterns

All endpoints require authenticated admin access.
"""

import logging
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import func, select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.models import (
    CheckInEvent,
    CheckInMethod,
    Queue,
    Ticket,
    TicketStatus,
    User,
    UserRole,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/analytics", tags=["Analytics"])


# =============================================================================
# Schemas
# =============================================================================


class TimeRange(BaseModel):
    """Time range for analytics queries."""

    start: datetime = Field(..., description="Start of time range (UTC)")
    end: datetime = Field(..., description="End of time range (UTC)")


class DailyStats(BaseModel):
    """Daily statistics summary."""

    date: str = Field(..., description="Date in YYYY-MM-DD format")
    total_tickets: int = Field(..., description="Total tickets created")
    completed_tickets: int = Field(..., description="Tickets marked complete")
    no_show_tickets: int = Field(..., description="Tickets marked no-show")
    average_wait_minutes: float = Field(..., description="Average wait time in minutes")
    peak_hour: Optional[int] = Field(
        None, description="Hour with most check-ins (0-23)"
    )
    nfc_checkins: int = Field(0, description="Check-ins via NFC")
    manual_checkins: int = Field(0, description="Manual check-ins")


class QueuePerformance(BaseModel):
    """Queue performance metrics."""

    queue_id: UUID
    queue_name: str
    total_tickets: int
    completed_tickets: int
    average_wait_minutes: float
    max_wait_minutes: int
    completion_rate: float = Field(..., description="Percentage of completed tickets")


class AnalyticsSummary(BaseModel):
    """Overall analytics summary."""

    period: str = Field(..., description="Period description")
    total_tickets: int
    total_completed: int
    average_wait_minutes: float
    busiest_day: Optional[str] = None
    busiest_hour: Optional[int] = None
    daily_breakdown: list[DailyStats] = []
    queue_performance: list[QueuePerformance] = []


# =============================================================================
# Helper functions
# =============================================================================


def _require_admin(user: User) -> None:
    """Raise 403 if user is not admin."""
    if user.role not in (UserRole.ADMIN, UserRole.SUPER_ADMIN):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required for analytics",
        )


# =============================================================================
# Endpoints
# =============================================================================


@router.get(
    "/summary",
    response_model=AnalyticsSummary,
    summary="Get analytics summary",
    description="Get overall analytics summary for a time period.",
)
async def get_analytics_summary(
    days: int = Query(7, ge=1, le=90, description="Number of days to analyze"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> AnalyticsSummary:
    """
    Get analytics summary for the specified period.

    Args:
        days: Number of days to analyze (1-90).
        current_user: Authenticated user (must be admin).
        db: Database session.

    Returns:
        AnalyticsSummary with daily breakdown and queue metrics.

    Raises:
        HTTPException: If user is not admin.
    """
    _require_admin(current_user)

    end_date = datetime.now(timezone.utc)
    start_date = end_date - timedelta(days=days)

    # Pre-aggregate check-in events to avoid per-day DB scans
    checkin_rows = await db.execute(
        select(
            func.date_trunc("day", CheckInEvent.checked_in_at).label("day"),
            func.extract("hour", CheckInEvent.checked_in_at).label("hour"),
            CheckInEvent.check_in_method,
            func.count(CheckInEvent.id).label("count"),
        )
        .where(
            and_(
                CheckInEvent.checked_in_at >= start_date,
                CheckInEvent.checked_in_at <= end_date,
            )
        )
        .group_by(
            func.date_trunc("day", CheckInEvent.checked_in_at),
            func.extract("hour", CheckInEvent.checked_in_at),
            CheckInEvent.check_in_method,
        )
    )

    daily_method_counts: dict[str, dict[str, int]] = {}
    daily_hour_counts: dict[str, dict[int, int]] = {}
    overall_hour_counts: dict[int, int] = {h: 0 for h in range(24)}

    for row in checkin_rows:
        day_key = row.day.date().isoformat()
        hour_key = int(row.hour)
        count = int(row.count)
        method = row.check_in_method

        method_bucket = "nfc" if method == CheckInMethod.NFC else "other"
        daily_method_counts.setdefault(day_key, {"nfc": 0, "other": 0})[
            method_bucket
        ] += count
        daily_hour_counts.setdefault(day_key, {}).setdefault(hour_key, 0)
        daily_hour_counts[day_key][hour_key] += count
        overall_hour_counts[hour_key] += count

    # Get total tickets in period
    total_result = await db.execute(
        select(func.count(Ticket.id)).where(
            and_(
                Ticket.created_at >= start_date,
                Ticket.created_at <= end_date,
            )
        )
    )
    total_tickets = total_result.scalar() or 0

    # Get completed tickets
    completed_result = await db.execute(
        select(func.count(Ticket.id)).where(
            and_(
                Ticket.created_at >= start_date,
                Ticket.created_at <= end_date,
                Ticket.status == TicketStatus.COMPLETED,
            )
        )
    )
    total_completed = completed_result.scalar() or 0

    # Get average wait time (for completed tickets)
    avg_wait_result = await db.execute(
        select(
            func.avg(func.extract("epoch", Ticket.called_at - Ticket.created_at) / 60)
        ).where(
            and_(
                Ticket.created_at >= start_date,
                Ticket.created_at <= end_date,
                Ticket.status == TicketStatus.COMPLETED,
                Ticket.called_at.isnot(None),
            )
        )
    )
    avg_wait = avg_wait_result.scalar() or 0.0

    # Daily breakdown
    daily_stats: list[DailyStats] = []
    for day_offset in range(days):
        day_start = (start_date + timedelta(days=day_offset)).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        day_end = day_start + timedelta(days=1)

        day_tickets_result = await db.execute(
            select(func.count(Ticket.id)).where(
                and_(
                    Ticket.created_at >= day_start,
                    Ticket.created_at < day_end,
                )
            )
        )
        day_total = day_tickets_result.scalar() or 0

        day_completed_result = await db.execute(
            select(func.count(Ticket.id)).where(
                and_(
                    Ticket.created_at >= day_start,
                    Ticket.created_at < day_end,
                    Ticket.status == TicketStatus.COMPLETED,
                )
            )
        )
        day_completed = day_completed_result.scalar() or 0

        day_noshow_result = await db.execute(
            select(func.count(Ticket.id)).where(
                and_(
                    Ticket.created_at >= day_start,
                    Ticket.created_at < day_end,
                    Ticket.status == TicketStatus.NO_SHOW,
                )
            )
        )
        day_noshow = day_noshow_result.scalar() or 0

        # Daily average wait time
        day_avg_result = await db.execute(
            select(
                func.avg(
                    func.extract("epoch", Ticket.called_at - Ticket.created_at) / 60
                )
            ).where(
                and_(
                    Ticket.created_at >= day_start,
                    Ticket.created_at < day_end,
                    Ticket.status == TicketStatus.COMPLETED,
                    Ticket.called_at.isnot(None),
                )
            )
        )
        day_avg_wait = day_avg_result.scalar() or 0.0

        day_key = day_start.date().isoformat()
        day_nfc = daily_method_counts.get(day_key, {}).get("nfc", 0)
        day_manual = daily_method_counts.get(day_key, {}).get("other", 0)
        peak_hour = None

        if day_key in daily_hour_counts and daily_hour_counts[day_key]:
            peak_hour = max(
                daily_hour_counts[day_key], key=daily_hour_counts[day_key].get
            )

        # If no check-in events recorded, assume manual check-ins equal total tickets
        if day_nfc == 0 and day_manual == 0:
            day_manual = day_total

        daily_stats.append(
            DailyStats(
                date=day_start.strftime("%Y-%m-%d"),
                total_tickets=day_total,
                completed_tickets=day_completed,
                no_show_tickets=day_noshow,
                average_wait_minutes=round(day_avg_wait, 1),
                peak_hour=peak_hour,
                nfc_checkins=day_nfc,
                manual_checkins=day_manual,
            )
        )

    # Queue performance
    queue_performance: list[QueuePerformance] = []
    queues_result = await db.execute(select(Queue).where(Queue.is_active.is_(True)))
    queues = list(queues_result.scalars().all())

    for queue in queues:
        q_total_result = await db.execute(
            select(func.count(Ticket.id)).where(
                and_(
                    Ticket.queue_id == queue.id,
                    Ticket.created_at >= start_date,
                    Ticket.created_at <= end_date,
                )
            )
        )
        q_total = q_total_result.scalar() or 0

        q_completed_result = await db.execute(
            select(func.count(Ticket.id)).where(
                and_(
                    Ticket.queue_id == queue.id,
                    Ticket.created_at >= start_date,
                    Ticket.created_at <= end_date,
                    Ticket.status == TicketStatus.COMPLETED,
                )
            )
        )
        q_completed = q_completed_result.scalar() or 0

        q_avg_result = await db.execute(
            select(
                func.avg(
                    func.extract("epoch", Ticket.called_at - Ticket.created_at) / 60
                )
            ).where(
                and_(
                    Ticket.queue_id == queue.id,
                    Ticket.created_at >= start_date,
                    Ticket.created_at <= end_date,
                    Ticket.status == TicketStatus.COMPLETED,
                    Ticket.called_at.isnot(None),
                )
            )
        )
        q_avg_wait = q_avg_result.scalar() or 0.0

        q_max_result = await db.execute(
            select(
                func.max(
                    func.extract("epoch", Ticket.called_at - Ticket.created_at) / 60
                )
            ).where(
                and_(
                    Ticket.queue_id == queue.id,
                    Ticket.created_at >= start_date,
                    Ticket.created_at <= end_date,
                    Ticket.status == TicketStatus.COMPLETED,
                    Ticket.called_at.isnot(None),
                )
            )
        )
        q_max_wait = int(q_max_result.scalar() or 0)

        completion_rate = (q_completed / q_total * 100) if q_total > 0 else 0.0

        queue_performance.append(
            QueuePerformance(
                queue_id=queue.id,
                queue_name=queue.name,
                total_tickets=q_total,
                completed_tickets=q_completed,
                average_wait_minutes=round(q_avg_wait, 1),
                max_wait_minutes=q_max_wait,
                completion_rate=round(completion_rate, 1),
            )
        )

    # Find busiest day
    busiest_day = None
    max_tickets = 0
    for ds in daily_stats:
        if ds.total_tickets > max_tickets:
            max_tickets = ds.total_tickets
            busiest_day = ds.date

    busiest_hour = None
    if any(overall_hour_counts.values()):
        busiest_hour = max(overall_hour_counts, key=overall_hour_counts.get)

    return AnalyticsSummary(
        period=f"Last {days} days",
        total_tickets=total_tickets,
        total_completed=total_completed,
        average_wait_minutes=round(avg_wait, 1),
        busiest_day=busiest_day,
        busiest_hour=busiest_hour,
        daily_breakdown=daily_stats,
        queue_performance=queue_performance,
    )


@router.get(
    "/wait-times",
    summary="Get wait time distribution",
    description="Get distribution of wait times for analysis.",
)
async def get_wait_time_distribution(
    days: int = Query(7, ge=1, le=30, description="Number of days to analyze"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get wait time distribution for the specified period.

    Returns buckets: 0-5min, 5-15min, 15-30min, 30+min.
    """
    _require_admin(current_user)

    end_date = datetime.now(timezone.utc)
    start_date = end_date - timedelta(days=days)

    # Get all completed tickets with wait times
    result = await db.execute(
        select(func.extract("epoch", Ticket.called_at - Ticket.created_at) / 60).where(
            and_(
                Ticket.created_at >= start_date,
                Ticket.created_at <= end_date,
                Ticket.status == TicketStatus.COMPLETED,
                Ticket.called_at.isnot(None),
            )
        )
    )
    wait_times = [row for row in result.scalars().all()]

    # Calculate distribution
    buckets = {
        "0-5": 0,
        "5-15": 0,
        "15-30": 0,
        "30+": 0,
    }

    for wt in wait_times:
        if wt is None:
            continue
        if wt < 5:
            buckets["0-5"] += 1
        elif wt < 15:
            buckets["5-15"] += 1
        elif wt < 30:
            buckets["15-30"] += 1
        else:
            buckets["30+"] += 1

    total = len([w for w in wait_times if w is not None])

    return {
        "period_days": days,
        "total_completed": total,
        "distribution": buckets,
        "percentages": {
            k: round(v / total * 100, 1) if total > 0 else 0 for k, v in buckets.items()
        },
    }


@router.get(
    "/hourly",
    summary="Get hourly check-in pattern",
    description="Get check-in count by hour of day.",
)
async def get_hourly_pattern(
    days: int = Query(7, ge=1, le=30, description="Number of days to analyze"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Get hourly check-in pattern for the specified period.

    Returns count per hour (0-23).
    """
    _require_admin(current_user)

    end_date = datetime.now(timezone.utc)
    start_date = end_date - timedelta(days=days)

    # Initialize all hours to 0
    hourly_counts = {str(h): 0 for h in range(24)}

    # Get tickets with their creation hours
    result = await db.execute(
        select(
            func.extract("hour", Ticket.created_at).label("hour"),
            func.count(Ticket.id).label("count"),
        )
        .where(
            and_(
                Ticket.created_at >= start_date,
                Ticket.created_at <= end_date,
            )
        )
        .group_by(func.extract("hour", Ticket.created_at))
    )

    for row in result.all():
        hour = int(row.hour)
        hourly_counts[str(hour)] = row.count

    # Find peak hour
    peak_hour = max(hourly_counts, key=hourly_counts.get)

    return {
        "period_days": days,
        "hourly_counts": hourly_counts,
        "peak_hour": int(peak_hour),
        "peak_count": hourly_counts[peak_hour],
    }
