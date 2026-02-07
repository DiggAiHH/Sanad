"""
Medication Plan Router
======================
Digitaler Medikationsplan für Patienten.
Ermöglicht Übersicht, Erinnerungen und Interaktions-Check.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, date, time, timezone
from typing import Optional
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/medications", tags=["Medications"])


# =============================================================================
# SCHEMAS
# =============================================================================

class MedicationForm(str, Enum):
    """Darreichungsformen"""
    tablet = "tablet"               # Tablette
    capsule = "capsule"             # Kapsel
    drops = "drops"                 # Tropfen
    syrup = "syrup"                 # Saft
    injection = "injection"         # Spritze
    cream = "cream"                 # Creme/Salbe
    patch = "patch"                 # Pflaster
    inhaler = "inhaler"             # Inhalator
    suppository = "suppository"     # Zäpfchen
    spray = "spray"                 # Spray
    powder = "powder"               # Pulver
    other = "other"


class DosageTime(str, Enum):
    """Einnahmezeiten"""
    morning = "morning"             # Morgens
    noon = "noon"                   # Mittags
    evening = "evening"             # Abends
    night = "night"                 # Nachts
    as_needed = "as_needed"         # Bei Bedarf


class MedicationStatus(str, Enum):
    """Status der Medikation"""
    active = "active"               # Aktiv einzunehmen
    paused = "paused"               # Pausiert
    discontinued = "discontinued"    # Abgesetzt
    completed = "completed"          # Therapie beendet


class Dosage(BaseModel):
    """Einzelne Dosierung"""
    time: DosageTime
    amount: float                   # Menge
    unit: str                       # Einheit (Stück, ml, mg, etc.)
    specific_time: Optional[str] = None  # z.B. "08:00"
    with_food: Optional[bool] = None     # Mit Mahlzeit?
    note: Optional[str] = None


class Medication(BaseModel):
    """Medikament im Plan"""
    id: str
    patient_id: str
    name: str                       # Handelsname
    active_ingredient: str          # Wirkstoff
    strength: str                   # Stärke z.B. "500mg"
    form: MedicationForm
    dosages: list[Dosage]
    indication: str                 # Grund/Diagnose
    prescriber: str                 # Verordnender Arzt
    prescribed_date: date
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: MedicationStatus = MedicationStatus.active
    pzn: Optional[str] = None       # Pharmazentralnummer
    instructions: Optional[str] = None  # Besondere Hinweise
    refill_reminder: bool = True
    last_refill: Optional[date] = None
    created_at: datetime
    updated_at: datetime


class MedicationPlan(BaseModel):
    """Vollständiger Medikationsplan"""
    id: str
    patient_id: str
    medications: list[Medication]
    last_updated: datetime
    reviewed_by: Optional[str] = None
    reviewed_at: Optional[datetime] = None
    notes: Optional[str] = None


class AddMedicationRequest(BaseModel):
    """Anfrage zum Hinzufügen eines Medikaments"""
    name: str
    active_ingredient: str
    strength: str
    form: MedicationForm
    dosages: list[Dosage]
    indication: str
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    pzn: Optional[str] = None
    instructions: Optional[str] = None


class InteractionCheck(BaseModel):
    """Ergebnis einer Interaktions-Prüfung"""
    severity: str  # mild, moderate, severe
    medication1: str
    medication2: str
    description: str
    recommendation: str


class MedicationReminder(BaseModel):
    """Einnahme-Erinnerung"""
    id: str
    medication_id: str
    medication_name: str
    dosage: Dosage
    scheduled_time: datetime
    taken: bool = False
    taken_at: Optional[datetime] = None
    skipped: bool = False
    skip_reason: Optional[str] = None


# =============================================================================
# MOCK DATA
# =============================================================================

def _create_mock_medications() -> dict[str, Medication]:
    """Erstellt Demo-Medikamente"""
    
    meds = {}
    
    med1 = Medication(
        id="med-001",
        patient_id="patient-1",
        name="Metformin",
        active_ingredient="Metformin",
        strength="500mg",
        form=MedicationForm.tablet,
        dosages=[
            Dosage(time=DosageTime.morning, amount=1, unit="Tablette", with_food=True),
            Dosage(time=DosageTime.evening, amount=1, unit="Tablette", with_food=True),
        ],
        indication="Diabetes mellitus Typ 2",
        prescriber="Dr. med. Schmidt",
        prescribed_date=date(2023, 6, 15),
        start_date=date(2023, 6, 16),
        status=MedicationStatus.active,
        pzn="01234567",
        instructions="Mit oder nach dem Essen einnehmen",
        created_at=datetime(2023, 6, 15),
        updated_at=datetime(2024, 1, 10),
    )
    meds[med1.id] = med1
    
    med2 = Medication(
        id="med-002",
        patient_id="patient-1",
        name="Ramipril",
        active_ingredient="Ramipril",
        strength="5mg",
        form=MedicationForm.tablet,
        dosages=[
            Dosage(time=DosageTime.morning, amount=1, unit="Tablette"),
        ],
        indication="Bluthochdruck",
        prescriber="Dr. med. Schmidt",
        prescribed_date=date(2023, 3, 10),
        start_date=date(2023, 3, 11),
        status=MedicationStatus.active,
        pzn="02345678",
        instructions="Morgens nüchtern einnehmen",
        created_at=datetime(2023, 3, 10),
        updated_at=datetime(2024, 1, 10),
    )
    meds[med2.id] = med2
    
    med3 = Medication(
        id="med-003",
        patient_id="patient-1",
        name="Ibuprofen",
        active_ingredient="Ibuprofen",
        strength="400mg",
        form=MedicationForm.tablet,
        dosages=[
            Dosage(time=DosageTime.as_needed, amount=1, unit="Tablette", 
                   note="Max. 3x täglich bei Schmerzen"),
        ],
        indication="Schmerzen/Fieber",
        prescriber="Dr. med. Schmidt",
        prescribed_date=date(2024, 1, 5),
        start_date=date(2024, 1, 5),
        end_date=date(2024, 1, 15),
        status=MedicationStatus.active,
        pzn="03456789",
        instructions="Nicht auf nüchternen Magen",
        created_at=datetime(2024, 1, 5),
        updated_at=datetime(2024, 1, 5),
    )
    meds[med3.id] = med3
    
    med4 = Medication(
        id="med-004",
        patient_id="patient-1",
        name="Vitamin D3",
        active_ingredient="Cholecalciferol",
        strength="1000 IE",
        form=MedicationForm.drops,
        dosages=[
            Dosage(time=DosageTime.morning, amount=20, unit="Tropfen", with_food=True),
        ],
        indication="Vitamin-D-Mangel",
        prescriber="Dr. med. Müller",
        prescribed_date=date(2023, 11, 1),
        start_date=date(2023, 11, 2),
        status=MedicationStatus.active,
        instructions="Mit fetthaltiger Mahlzeit einnehmen",
        created_at=datetime(2023, 11, 1),
        updated_at=datetime(2023, 11, 1),
    )
    meds[med4.id] = med4
    
    return meds


_medications: dict[str, Medication] = _create_mock_medications()


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.get("/my", response_model=list[Medication])
async def get_my_medications(
    status: Optional[MedicationStatus] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Holt alle Medikamente des Patienten.
    
    Args:
        status: Optional Filter nach Status
        
    Returns:
        Liste der Medikamente
    """
    patient_id = str(current_user.id)
    
    meds = [m for m in _medications.values() if m.patient_id == patient_id]
    
    if status:
        meds = [m for m in meds if m.status == status]
    
    return sorted(meds, key=lambda x: x.name)


@router.get("/my/plan", response_model=MedicationPlan)
async def get_my_medication_plan(
    current_user: User = Depends(get_current_user),
):
    """
    Holt den vollständigen Medikationsplan.
    """
    patient_id = str(current_user.id)
    
    meds = [m for m in _medications.values() 
            if m.patient_id == patient_id and m.status == MedicationStatus.active]
    
    return MedicationPlan(
        id=f"plan-{patient_id}",
        patient_id=patient_id,
        medications=sorted(meds, key=lambda x: x.name),
        last_updated=datetime.now(timezone.utc),
        reviewed_by="Dr. med. Schmidt",
        reviewed_at=datetime(2024, 1, 10, 14, 30),
    )


@router.get("/my/schedule/today")
async def get_todays_schedule(
    current_user: User = Depends(get_current_user),
):
    """
    Holt den Einnahmeplan für heute.
    Sortiert nach Tageszeit.
    """
    patient_id = str(current_user.id)
    
    schedule = {
        "morning": [],
        "noon": [],
        "evening": [],
        "night": [],
        "as_needed": [],
    }
    
    for med in _medications.values():
        if med.patient_id != patient_id or med.status != MedicationStatus.active:
            continue
        
        for dosage in med.dosages:
            entry = {
                "medication_id": med.id,
                "name": med.name,
                "strength": med.strength,
                "form": med.form,
                "amount": dosage.amount,
                "unit": dosage.unit,
                "specific_time": dosage.specific_time,
                "with_food": dosage.with_food,
                "note": dosage.note or med.instructions,
            }
            schedule[dosage.time.value].append(entry)
    
    return {
        "date": date.today().isoformat(),
        "schedule": schedule,
        "total_doses": sum(len(v) for v in schedule.values() if v != schedule["as_needed"]),
    }


@router.get("/my/{medication_id}", response_model=Medication)
async def get_medication_detail(
    medication_id: str,
    current_user: User = Depends(get_current_user),
):
    """Holt Details eines Medikaments."""
    if medication_id not in _medications:
        raise HTTPException(status_code=404, detail="Medication not found")
    
    med = _medications[medication_id]
    if med.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return med


@router.post("/my/log-intake")
async def log_medication_intake(
    medication_id: str,
    taken_at: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Protokolliert eine Medikamenten-Einnahme.
    """
    if medication_id not in _medications:
        raise HTTPException(status_code=404, detail="Medication not found")
    
    # TODO: In Datenbank speichern
    
    return {
        "status": "logged",
        "medication_id": medication_id,
        "taken_at": taken_at or datetime.now(timezone.utc),
    }


@router.post("/check-interactions", response_model=list[InteractionCheck])
async def check_interactions(
    medication_ids: list[str],
    current_user: User = Depends(get_current_user),
):
    """
    Prüft Medikamente auf Wechselwirkungen.
    
    HINWEIS: Vereinfachte Demo-Logik.
    In Produktion: Pharma-Datenbank anbinden.
    """
    
    interactions = []
    
    # Demo: Bekannte Interaktion Ibuprofen + Ramipril
    meds = [_medications.get(mid) for mid in medication_ids if mid in _medications]
    med_names = {m.active_ingredient.lower() for m in meds if m}
    
    if "ibuprofen" in med_names and "ramipril" in med_names:
        interactions.append(InteractionCheck(
            severity="moderate",
            medication1="Ibuprofen",
            medication2="Ramipril",
            description="NSAIDs wie Ibuprofen können die blutdrucksenkende Wirkung "
                       "von ACE-Hemmern wie Ramipril verringern.",
            recommendation="Bei kurzfristiger Anwendung meist unbedenklich. "
                          "Langfristig Blutdruck kontrollieren. "
                          "Alternative: Paracetamol bei Schmerzen.",
        ))
    
    return interactions


@router.get("/refill-needed", response_model=list[Medication])
async def get_medications_needing_refill(
    current_user: User = Depends(get_current_user),
):
    """
    Findet Medikamente, die bald nachbestellt werden müssen.
    """
    patient_id = str(current_user.id)
    
    # Vereinfachte Logik: Medikamente ohne letztes Refill-Datum
    # In Produktion: Berechnung basierend auf Verbrauch
    needing_refill = []
    
    for med in _medications.values():
        if med.patient_id != patient_id:
            continue
        if med.status != MedicationStatus.active:
            continue
        if not med.refill_reminder:
            continue
        
        # Demo: Alle dauerhaften Medikamente
        if med.end_date is None:
            needing_refill.append(med)
    
    return needing_refill


# =============================================================================
# EXPORT
# =============================================================================

@router.get("/my/export/pdf")
async def export_medication_plan_pdf(
    current_user: User = Depends(get_current_user),
):
    """
    Exportiert Medikationsplan als PDF.
    Format: Bundeseinheitlicher Medikationsplan (BMP)
    """
    # TODO: PDF-Generierung implementieren
    
    return {
        "status": "generating",
        "format": "Bundeseinheitlicher Medikationsplan",
        "download_url": "/api/medications/my/export/pdf/download",
    }


@router.get("/my/export/print")
async def get_printable_plan(
    current_user: User = Depends(get_current_user),
):
    """
    Holt druckfreundliche Version des Medikationsplans.
    """
    patient_id = str(current_user.id)
    
    meds = [m for m in _medications.values() 
            if m.patient_id == patient_id and m.status == MedicationStatus.active]
    
    # Formatierung für Druck
    print_data = []
    for med in sorted(meds, key=lambda x: x.name):
        dosage_str = ", ".join([
            f"{d.amount} {d.unit} {_translate_time(d.time)}"
            for d in med.dosages
        ])
        print_data.append({
            "name": f"{med.name} {med.strength}",
            "form": med.form,
            "dosage": dosage_str,
            "indication": med.indication,
            "instructions": med.instructions or "-",
        })
    
    return {
        "title": "Medikationsplan",
        "patient": f"Patient {patient_id}",
        "date": date.today().isoformat(),
        "medications": print_data,
    }


def _translate_time(t: DosageTime) -> str:
    """Übersetzt Einnahmezeit"""
    translations = {
        DosageTime.morning: "morgens",
        DosageTime.noon: "mittags",
        DosageTime.evening: "abends",
        DosageTime.night: "nachts",
        DosageTime.as_needed: "bei Bedarf",
    }
    return translations.get(t, str(t.value))
