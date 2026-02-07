"""
Appointment Booking Router - Online-Terminbuchung
=================================================
Komplette Terminbuchung von zuhause aus:
- Slot-Verfügbarkeit
- Termintypen (Akut, Vorsorge, Impfung, etc.)
- Buchung, Absage, Umbuchung
- Erinnerungen
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, date, time, timedelta, timezone
from typing import Optional
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/appointments", tags=["Appointments"])


# =============================================================================
# ENUMS & SCHEMAS
# =============================================================================

class AppointmentType(str, Enum):
    """Termintypen einer Hausarztpraxis"""
    acute = "acute"                    # Akutsprechstunde
    checkup = "checkup"                # Vorsorge/Check-up
    vaccination = "vaccination"        # Impfung
    followup = "followup"              # Nachkontrolle
    lab_results = "lab_results"        # Befundbesprechung
    prescription = "prescription"      # Rezept-Sprechstunde
    referral = "referral"              # Überweisungs-Gespräch
    telemedicine = "telemedicine"      # Video-Sprechstunde
    emergency = "emergency"            # Notfall (Walk-in)


class AppointmentStatus(str, Enum):
    pending = "pending"           # Anfrage gestellt
    confirmed = "confirmed"       # Bestätigt
    cancelled = "cancelled"       # Abgesagt
    completed = "completed"       # Durchgeführt
    no_show = "no_show"           # Nicht erschienen
    rescheduled = "rescheduled"   # Verschoben


class SlotDuration(int, Enum):
    """Termin-Dauern in Minuten"""
    short = 10      # Rezept, kurze Kontrolle
    standard = 15   # Standard-Termin
    medium = 20     # Vorsorge-Start
    long = 30       # Check-up, ausführlich
    extended = 45   # Erstgespräch


# Mapping: Termintyp -> Dauer
APPOINTMENT_DURATION = {
    AppointmentType.acute: SlotDuration.standard,
    AppointmentType.checkup: SlotDuration.long,
    AppointmentType.vaccination: SlotDuration.short,
    AppointmentType.followup: SlotDuration.standard,
    AppointmentType.lab_results: SlotDuration.short,
    AppointmentType.prescription: SlotDuration.short,
    AppointmentType.referral: SlotDuration.standard,
    AppointmentType.telemedicine: SlotDuration.medium,
    AppointmentType.emergency: SlotDuration.standard,
}


class TimeSlot(BaseModel):
    """Verfügbarer Zeitslot"""
    start_time: datetime
    end_time: datetime
    is_available: bool = True
    doctor_id: Optional[str] = None
    doctor_name: Optional[str] = None


class DayAvailability(BaseModel):
    """Verfügbarkeit für einen Tag"""
    date: date
    slots: list[TimeSlot]
    is_holiday: bool = False
    is_closed: bool = False


class AppointmentTypeInfo(BaseModel):
    """Info zu einem Termintyp"""
    type: AppointmentType
    name: str
    description: str
    duration_minutes: int
    requires_referral: bool = False
    online_bookable: bool = True
    preparation_notes: Optional[str] = None


class BookingRequest(BaseModel):
    """Termin-Buchungsanfrage"""
    appointment_type: AppointmentType
    preferred_date: date
    preferred_time: time
    doctor_id: Optional[str] = None
    reason: str = Field(..., min_length=3, max_length=500)
    notes: Optional[str] = None
    is_first_visit: bool = False


class Appointment(BaseModel):
    """Gebuchter Termin"""
    id: str
    patient_id: str
    patient_name: str
    appointment_type: AppointmentType
    status: AppointmentStatus
    scheduled_at: datetime
    duration_minutes: int
    doctor_id: Optional[str] = None
    doctor_name: Optional[str] = None
    reason: str
    notes: Optional[str] = None
    created_at: datetime
    confirmed_at: Optional[datetime] = None
    cancelled_at: Optional[datetime] = None
    cancellation_reason: Optional[str] = None
    reminder_sent: bool = False


class RescheduleRequest(BaseModel):
    """Umbuchungsanfrage"""
    new_date: date
    new_time: time
    reason: Optional[str] = None


class CancellationRequest(BaseModel):
    """Absage-Anfrage"""
    reason: str = Field(..., min_length=3, max_length=500)


class ReminderSettings(BaseModel):
    """Erinnerungs-Einstellungen"""
    email_24h: bool = True
    email_1h: bool = False
    push_24h: bool = True
    push_1h: bool = True
    sms_24h: bool = False


# =============================================================================
# IN-MEMORY STORAGE (Demo)
# =============================================================================

_appointments: dict[str, Appointment] = {}
_blocked_slots: list[tuple[datetime, datetime]] = []


def _get_practice_hours(weekday: int) -> tuple[time, time] | None:
    """Öffnungszeiten der Praxis nach Wochentag."""
    # 0=Mo, 1=Di, 2=Mi, 3=Do, 4=Fr, 5=Sa, 6=So
    hours: dict[int, tuple[time, time] | None] = {
        0: (time(8, 0), time(18, 0)),   # Mo
        1: (time(8, 0), time(18, 0)),   # Di
        2: (time(8, 0), time(13, 0)),   # Mi (Nachmittag frei)
        3: (time(8, 0), time(18, 0)),   # Do
        4: (time(8, 0), time(14, 0)),   # Fr
        5: None,  # Sa geschlossen
        6: None,  # So geschlossen
    }
    return hours.get(weekday)


def _generate_slots(
    target_date: date,
    duration: SlotDuration,
) -> list[TimeSlot]:
    """Generiert verfügbare Slots für einen Tag."""
    hours = _get_practice_hours(target_date.weekday())
    if not hours:
        return []
    
    open_time, close_time = hours
    slots: list[TimeSlot] = []
    
    current = datetime.combine(target_date, open_time)
    end = datetime.combine(target_date, close_time)
    
    while current + timedelta(minutes=duration.value) <= end:
        slot_end = current + timedelta(minutes=duration.value)
        
        # Prüfe ob Slot schon gebucht
        is_booked = any(
            apt.scheduled_at <= current < apt.scheduled_at + timedelta(minutes=apt.duration_minutes)
            or apt.scheduled_at < slot_end <= apt.scheduled_at + timedelta(minutes=apt.duration_minutes)
            for apt in _appointments.values()
            if apt.status in [AppointmentStatus.confirmed, AppointmentStatus.pending]
            and apt.scheduled_at.date() == target_date
        )
        
        slots.append(TimeSlot(
            start_time=current,
            end_time=slot_end,
            is_available=not is_booked,
            doctor_id="dr-mueller",
            doctor_name="Dr. med. Müller",
        ))
        
        current = slot_end
    
    return slots


# =============================================================================
# APPOINTMENT TYPE INFO
# =============================================================================

@router.get("/types", response_model=list[AppointmentTypeInfo])
async def get_appointment_types():
    """
    Listet alle verfügbaren Termintypen.
    
    Returns:
        Liste aller Termintypen mit Beschreibung und Dauer
    """
    return [
        AppointmentTypeInfo(
            type=AppointmentType.acute,
            name="Akutsprechstunde",
            description="Bei akuten Beschwerden, die zeitnah behandelt werden müssen",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.acute].value,
            preparation_notes="Bitte Versichertenkarte mitbringen",
        ),
        AppointmentTypeInfo(
            type=AppointmentType.checkup,
            name="Vorsorgeuntersuchung",
            description="Gesundheitscheck (Check-up 35, Hautkrebsscreening, etc.)",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.checkup].value,
            preparation_notes="Bitte nüchtern erscheinen (kein Frühstück)",
        ),
        AppointmentTypeInfo(
            type=AppointmentType.vaccination,
            name="Impfung",
            description="Schutzimpfungen und Auffrischungen",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.vaccination].value,
            preparation_notes="Impfpass mitbringen falls vorhanden",
        ),
        AppointmentTypeInfo(
            type=AppointmentType.followup,
            name="Kontrolltermin",
            description="Nachkontrolle nach Behandlung oder Erkrankung",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.followup].value,
        ),
        AppointmentTypeInfo(
            type=AppointmentType.lab_results,
            name="Befundbesprechung",
            description="Besprechung von Laborergebnissen oder Befunden",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.lab_results].value,
        ),
        AppointmentTypeInfo(
            type=AppointmentType.prescription,
            name="Rezept-Sprechstunde",
            description="Für Folgerezepte bei bekannter Medikation",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.prescription].value,
        ),
        AppointmentTypeInfo(
            type=AppointmentType.referral,
            name="Überweisung",
            description="Besprechung und Ausstellung von Überweisungen",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.referral].value,
        ),
        AppointmentTypeInfo(
            type=AppointmentType.telemedicine,
            name="Videosprechstunde",
            description="Online-Konsultation per Video",
            duration_minutes=APPOINTMENT_DURATION[AppointmentType.telemedicine].value,
            online_bookable=True,
            preparation_notes="Stabile Internetverbindung und Kamera erforderlich",
        ),
    ]


# =============================================================================
# AVAILABILITY
# =============================================================================

@router.get("/availability", response_model=list[DayAvailability])
async def get_availability(
    appointment_type: AppointmentType,
    from_date: Optional[date] = None,
    to_date: Optional[date] = None,
    doctor_id: Optional[str] = None,
) -> list[DayAvailability]:
    """
    Holt verfügbare Termine für einen Zeitraum.
    
    Args:
        appointment_type: Art des Termins (bestimmt Dauer)
        from_date: Startdatum (default: heute)
        to_date: Enddatum (default: +14 Tage)
        doctor_id: Optional: bestimmter Arzt
        
    Returns:
        Liste der Tage mit verfügbaren Slots
    """
    if not from_date:
        from_date = date.today()
    if not to_date:
        to_date = from_date + timedelta(days=14)
    
    # Maximal 30 Tage
    if (to_date - from_date).days > 30:
        to_date = from_date + timedelta(days=30)
    
    duration = APPOINTMENT_DURATION.get(appointment_type, SlotDuration.standard)
    
    availability: list[DayAvailability] = []
    current_date = from_date
    
    while current_date <= to_date:
        slots = _generate_slots(current_date, duration)
        
        availability.append(DayAvailability(
            date=current_date,
            slots=slots,
            is_holiday=False,  # TODO: Feiertags-Logik
            is_closed=len(slots) == 0,
        ))
        
        current_date += timedelta(days=1)
    
    return availability


@router.get("/next-available", response_model=TimeSlot)
async def get_next_available_slot(
    appointment_type: AppointmentType,
    doctor_id: Optional[str] = None,
):
    """
    Findet den nächsten verfügbaren Termin.
    
    Args:
        appointment_type: Art des Termins
        doctor_id: Optional: bestimmter Arzt
        
    Returns:
        Nächster verfügbarer Slot
    """
    duration = APPOINTMENT_DURATION.get(appointment_type, SlotDuration.standard)
    
    current_date = date.today()
    for _ in range(30):  # Maximal 30 Tage suchen
        slots = _generate_slots(current_date, duration)
        available = [s for s in slots if s.is_available and s.start_time > datetime.now()]
        
        if available:
            return available[0]
        
        current_date += timedelta(days=1)
    
    raise HTTPException(
        status_code=404,
        detail="No available slots in the next 30 days",
    )


# =============================================================================
# BOOKING
# =============================================================================

@router.post("/book", response_model=Appointment)
async def book_appointment(
    request: BookingRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Bucht einen Termin.
    
    Args:
        request: Buchungsdetails (Typ, Datum, Zeit, Grund)
        
    Returns:
        Gebuchter Termin
    """
    patient_id = str(current_user.id)
    
    # Prüfe ob Slot verfügbar
    scheduled_at = datetime.combine(request.preferred_date, request.preferred_time)
    duration = APPOINTMENT_DURATION.get(request.appointment_type, SlotDuration.standard)
    
    # Prüfe Konflikte
    for apt in _appointments.values():
        if apt.status not in [AppointmentStatus.confirmed, AppointmentStatus.pending]:
            continue
        if apt.scheduled_at.date() != request.preferred_date:
            continue
        
        apt_end = apt.scheduled_at + timedelta(minutes=apt.duration_minutes)
        new_end = scheduled_at + timedelta(minutes=duration.value)
        
        if not (new_end <= apt.scheduled_at or scheduled_at >= apt_end):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Selected time slot is no longer available",
            )
    
    # Termin erstellen
    appointment_id = str(uuid.uuid4())
    appointment = Appointment(
        id=appointment_id,
        patient_id=patient_id,
        patient_name=current_user.full_name or current_user.email,
        appointment_type=request.appointment_type,
        status=AppointmentStatus.confirmed,  # Auto-Bestätigung
        scheduled_at=scheduled_at,
        duration_minutes=duration.value,
        doctor_id=request.doctor_id or "dr-mueller",
        doctor_name="Dr. med. Müller",
        reason=request.reason,
        notes=request.notes,
        created_at=datetime.now(timezone.utc),
        confirmed_at=datetime.now(timezone.utc),
    )
    
    _appointments[appointment_id] = appointment
    
    # Erinnerungen planen
    background_tasks.add_task(_schedule_reminders, appointment_id)
    
    return appointment


@router.get("/my", response_model=list[Appointment])
async def get_my_appointments(
    status_filter: Optional[AppointmentStatus] = None,
    upcoming_only: bool = True,
    current_user: User = Depends(get_current_user),
):
    """
    Holt alle Termine des aktuellen Benutzers.
    
    Args:
        status_filter: Optional: nur bestimmter Status
        upcoming_only: Nur zukünftige Termine (default: True)
        
    Returns:
        Liste der Termine
    """
    patient_id = str(current_user.id)
    
    appointments = [
        apt for apt in _appointments.values()
        if apt.patient_id == patient_id
    ]
    
    if status_filter:
        appointments = [apt for apt in appointments if apt.status == status_filter]
    
    if upcoming_only:
        now = datetime.now(timezone.utc)
        appointments = [apt for apt in appointments if apt.scheduled_at > now]
    
    return sorted(appointments, key=lambda a: a.scheduled_at)


@router.get("/{appointment_id}", response_model=Appointment)
async def get_appointment(
    appointment_id: str,
    current_user: User = Depends(get_current_user),
):
    """Holt Details eines Termins."""
    if appointment_id not in _appointments:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    appointment = _appointments[appointment_id]
    if appointment.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return appointment


@router.put("/{appointment_id}/reschedule", response_model=Appointment)
async def reschedule_appointment(
    appointment_id: str,
    request: RescheduleRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Verschiebt einen Termin.
    
    Args:
        appointment_id: ID des zu verschiebenden Termins
        request: Neues Datum und Zeit
        
    Returns:
        Aktualisierter Termin
    """
    if appointment_id not in _appointments:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    appointment = _appointments[appointment_id]
    if appointment.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    if appointment.status in [AppointmentStatus.completed, AppointmentStatus.cancelled]:
        raise HTTPException(status_code=400, detail="Cannot reschedule completed or cancelled appointment")
    
    # Neuen Termin setzen
    new_scheduled_at = datetime.combine(request.new_date, request.new_time)
    
    updated_appointment = Appointment(
        id=appointment.id,
        patient_id=appointment.patient_id,
        patient_name=appointment.patient_name,
        appointment_type=appointment.appointment_type,
        status=AppointmentStatus.confirmed,
        scheduled_at=new_scheduled_at,
        duration_minutes=appointment.duration_minutes,
        doctor_id=appointment.doctor_id,
        doctor_name=appointment.doctor_name,
        reason=appointment.reason,
        notes=f"Verschoben: {request.reason}" if request.reason else appointment.notes,
        created_at=appointment.created_at,
        confirmed_at=appointment.confirmed_at,
        cancelled_at=appointment.cancelled_at,
        cancellation_reason=appointment.cancellation_reason,
        reminder_sent=appointment.reminder_sent,
    )
    
    _appointments[appointment_id] = updated_appointment
    return updated_appointment


@router.delete("/{appointment_id}", response_model=Appointment)
async def cancel_appointment(
    appointment_id: str,
    request: CancellationRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Sagt einen Termin ab.
    
    HINWEIS: Absagen unter 24h vor Termin können kostenpflichtig sein.
    
    Args:
        appointment_id: ID des abzusagenden Termins
        request: Absagegrund
        
    Returns:
        Abgesagter Termin
    """
    if appointment_id not in _appointments:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    appointment = _appointments[appointment_id]
    if appointment.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    if appointment.status in [AppointmentStatus.completed, AppointmentStatus.cancelled]:
        raise HTTPException(status_code=400, detail="Cannot cancel completed or already cancelled appointment")
    
    # Warnung bei kurzfristiger Absage
    hours_until = (appointment.scheduled_at - datetime.now(timezone.utc)).total_seconds() / 3600
    late_cancellation_warning: str | None = None
    if hours_until < 24:
        late_cancellation_warning = "Absage unter 24h vor Termin. Bitte beachten Sie mögliche Ausfallgebühren."
    
    cancelled_appointment = Appointment(
        id=appointment.id,
        patient_id=appointment.patient_id,
        patient_name=appointment.patient_name,
        appointment_type=appointment.appointment_type,
        status=AppointmentStatus.cancelled,
        scheduled_at=appointment.scheduled_at,
        duration_minutes=appointment.duration_minutes,
        doctor_id=appointment.doctor_id,
        doctor_name=appointment.doctor_name,
        reason=appointment.reason,
        notes=late_cancellation_warning or appointment.notes,
        created_at=appointment.created_at,
        confirmed_at=appointment.confirmed_at,
        cancelled_at=datetime.now(timezone.utc),
        cancellation_reason=request.reason,
        reminder_sent=appointment.reminder_sent,
    )
    
    _appointments[appointment_id] = cancelled_appointment
    return cancelled_appointment


# =============================================================================
# REMINDERS
# =============================================================================

async def _schedule_reminders(appointment_id: str):
    """Plant Erinnerungen für einen Termin."""
    # In Produktion: Celery/RQ Task oder Cron-Job
    # Hier nur Logging für Demo
    if appointment_id in _appointments:
        apt = _appointments[appointment_id]
        print(f"[REMINDER] Scheduled for {apt.scheduled_at}: 24h and 1h before")


@router.put("/{appointment_id}/reminder-settings", response_model=ReminderSettings)
async def update_reminder_settings(
    appointment_id: str,
    settings: ReminderSettings,
    current_user: User = Depends(get_current_user),
):
    """Aktualisiert Erinnerungs-Einstellungen für einen Termin."""
    if appointment_id not in _appointments:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    appointment = _appointments[appointment_id]
    if appointment.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    # In Produktion: Einstellungen in DB speichern
    return settings
