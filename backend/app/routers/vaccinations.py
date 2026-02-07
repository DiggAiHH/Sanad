"""
Vaccination Pass / Impfpass Router
==================================
Digitaler Impfpass mit Impfhistorie, Erinnerungen und Empfehlungen.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, date, timezone
from typing import Optional
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/vaccinations", tags=["Vaccinations"])


# =============================================================================
# SCHEMAS
# =============================================================================

class VaccineType(str, Enum):
    """Impfstoff-Typen"""
    covid19 = "covid19"
    influenza = "influenza"
    tetanus = "tetanus"
    diphtheria = "diphtheria"
    pertussis = "pertussis"
    polio = "polio"
    hepatitis_a = "hepatitis_a"
    hepatitis_b = "hepatitis_b"
    measles = "measles"
    mumps = "mumps"
    rubella = "rubella"
    varicella = "varicella"
    pneumococcal = "pneumococcal"
    meningococcal = "meningococcal"
    hpv = "hpv"
    rotavirus = "rotavirus"
    tick_borne = "tick_borne"  # FSME
    rabies = "rabies"
    typhoid = "typhoid"
    yellow_fever = "yellow_fever"
    other = "other"


class VaccinationRecord(BaseModel):
    """Einzelne Impfung"""
    id: str
    patient_id: str
    vaccine_type: VaccineType
    vaccine_name: str           # Handelsname z.B. "Comirnaty"
    manufacturer: str           # Hersteller
    batch_number: str           # Chargennummer
    dose_number: int            # Welche Dosis (1, 2, 3, Auffrischung)
    date: date
    administering_doctor: str
    location: str               # Praxis/Impfzentrum
    next_dose_due: Optional[date] = None
    notes: Optional[str] = None
    documented_at: datetime
    documented_by: str


class VaccinationRecommendation(BaseModel):
    """Impfempfehlung"""
    vaccine_type: VaccineType
    vaccine_name: str
    reason: str
    priority: str               # high, medium, low
    due_date: Optional[date] = None
    notes: Optional[str] = None


class VaccinationStatus(BaseModel):
    """Status einer Impfung"""
    vaccine_type: VaccineType
    name: str
    status: str                 # complete, incomplete, overdue, not_started
    last_dose: Optional[date] = None
    next_dose_due: Optional[date] = None
    doses_received: int = 0
    doses_required: Optional[int] = None


class VaccinationPass(BaseModel):
    """Vollständiger Impfpass"""
    patient_id: str
    vaccinations: list[VaccinationRecord]
    status_summary: list[VaccinationStatus]
    recommendations: list[VaccinationRecommendation]
    last_updated: datetime


class RecallNotification(BaseModel):
    """Recall/Erinnerung für Impfung oder Vorsorge"""
    id: str
    patient_id: str
    type: str                   # vaccination, checkup, screening
    title: str
    description: str
    due_date: date
    priority: str
    sent_at: Optional[datetime] = None
    acknowledged_at: Optional[datetime] = None
    scheduled_appointment_id: Optional[str] = None


# =============================================================================
# STIKO EMPFEHLUNGEN (vereinfacht)
# =============================================================================

STIKO_RECOMMENDATIONS = {
    VaccineType.tetanus: {"interval_years": 10, "name": "Tetanus"},
    VaccineType.diphtheria: {"interval_years": 10, "name": "Diphtherie"},
    VaccineType.pertussis: {"interval_years": 10, "name": "Keuchhusten"},
    VaccineType.influenza: {"interval_years": 1, "name": "Grippe", "seasonal": True},
    VaccineType.covid19: {"interval_months": 12, "name": "COVID-19"},
    VaccineType.pneumococcal: {"interval_years": 6, "name": "Pneumokokken", "age_60_plus": True},
    VaccineType.tick_borne: {"interval_years": 5, "name": "FSME", "risk_area": True},
}


# =============================================================================
# MOCK DATA
# =============================================================================

def _create_mock_vaccinations() -> dict[str, VaccinationRecord]:
    """Erstellt Demo-Impfungen"""
    
    vaccinations = {}
    
    # COVID-19 Impfungen
    v1 = VaccinationRecord(
        id="vax-001",
        patient_id="patient-1",
        vaccine_type=VaccineType.covid19,
        vaccine_name="Comirnaty",
        manufacturer="BioNTech/Pfizer",
        batch_number="EL0142",
        dose_number=1,
        date=date(2021, 4, 15),
        administering_doctor="Dr. med. Schmidt",
        location="Impfzentrum München",
        next_dose_due=date(2021, 5, 6),
        documented_at=datetime(2021, 4, 15),
        documented_by="Dr. Schmidt",
    )
    vaccinations[v1.id] = v1
    
    v2 = VaccinationRecord(
        id="vax-002",
        patient_id="patient-1",
        vaccine_type=VaccineType.covid19,
        vaccine_name="Comirnaty",
        manufacturer="BioNTech/Pfizer",
        batch_number="EL2354",
        dose_number=2,
        date=date(2021, 5, 6),
        administering_doctor="Dr. med. Schmidt",
        location="Impfzentrum München",
        documented_at=datetime(2021, 5, 6),
        documented_by="Dr. Schmidt",
    )
    vaccinations[v2.id] = v2
    
    v3 = VaccinationRecord(
        id="vax-003",
        patient_id="patient-1",
        vaccine_type=VaccineType.covid19,
        vaccine_name="Comirnaty",
        manufacturer="BioNTech/Pfizer",
        batch_number="FF3421",
        dose_number=3,
        date=date(2021, 11, 20),
        administering_doctor="Dr. med. Müller",
        location="Hausarztpraxis Dr. Müller",
        documented_at=datetime(2021, 11, 20),
        documented_by="Dr. Müller",
    )
    vaccinations[v3.id] = v3
    
    # Tetanus/Diphtherie/Pertussis
    v4 = VaccinationRecord(
        id="vax-004",
        patient_id="patient-1",
        vaccine_type=VaccineType.tetanus,
        vaccine_name="Boostrix",
        manufacturer="GlaxoSmithKline",
        batch_number="ABJK123",
        dose_number=1,
        date=date(2019, 8, 10),
        administering_doctor="Dr. med. Schmidt",
        location="Hausarztpraxis Dr. Schmidt",
        next_dose_due=date(2029, 8, 10),
        notes="Kombinationsimpfstoff Td-aP",
        documented_at=datetime(2019, 8, 10),
        documented_by="Dr. Schmidt",
    )
    vaccinations[v4.id] = v4
    
    # Grippe 2023
    v5 = VaccinationRecord(
        id="vax-005",
        patient_id="patient-1",
        vaccine_type=VaccineType.influenza,
        vaccine_name="Vaxigrip Tetra",
        manufacturer="Sanofi Pasteur",
        batch_number="N2E431A",
        dose_number=1,
        date=date(2023, 10, 15),
        administering_doctor="Dr. med. Schmidt",
        location="Hausarztpraxis Dr. Schmidt",
        documented_at=datetime(2023, 10, 15),
        documented_by="Dr. Schmidt",
    )
    vaccinations[v5.id] = v5
    
    return vaccinations


_vaccinations: dict[str, VaccinationRecord] = _create_mock_vaccinations()
_recalls: dict[str, RecallNotification] = {}


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.get("/my", response_model=list[VaccinationRecord])
async def get_my_vaccinations(
    vaccine_type: Optional[VaccineType] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Holt alle Impfungen des Patienten.
    
    Args:
        vaccine_type: Optional Filter nach Impfstoff-Typ
        
    Returns:
        Liste der Impfungen, sortiert nach Datum (neueste zuerst)
    """
    patient_id = str(current_user.id)
    
    vaccinations = [v for v in _vaccinations.values() if v.patient_id == patient_id]
    
    if vaccine_type:
        vaccinations = [v for v in vaccinations if v.vaccine_type == vaccine_type]
    
    return sorted(vaccinations, key=lambda x: x.date, reverse=True)


@router.get("/my/pass", response_model=VaccinationPass)
async def get_my_vaccination_pass(
    current_user: User = Depends(get_current_user),
):
    """
    Holt den vollständigen Impfpass mit Status und Empfehlungen.
    """
    patient_id = str(current_user.id)
    
    vaccinations = [v for v in _vaccinations.values() if v.patient_id == patient_id]
    
    # Status berechnen
    status_summary = _calculate_vaccination_status(vaccinations)
    
    # Empfehlungen generieren
    recommendations = _generate_recommendations(vaccinations, patient_age=45)
    
    return VaccinationPass(
        patient_id=patient_id,
        vaccinations=sorted(vaccinations, key=lambda x: x.date, reverse=True),
        status_summary=status_summary,
        recommendations=recommendations,
        last_updated=datetime.now(timezone.utc),
    )


@router.get("/my/recommendations", response_model=list[VaccinationRecommendation])
async def get_my_recommendations(
    current_user: User = Depends(get_current_user),
):
    """
    Holt personalisierte Impfempfehlungen basierend auf Impfhistorie.
    """
    patient_id = str(current_user.id)
    vaccinations = [v for v in _vaccinations.values() if v.patient_id == patient_id]
    
    # TODO: Alter aus Patientendaten holen
    return _generate_recommendations(vaccinations, patient_age=45)


@router.get("/my/upcoming")
async def get_upcoming_vaccinations(
    current_user: User = Depends(get_current_user),
):
    """
    Holt anstehende Impfungen (fällig in den nächsten 3 Monaten).
    """
    patient_id = str(current_user.id)
    vaccinations = [v for v in _vaccinations.values() if v.patient_id == patient_id]
    
    upcoming = []
    today = date.today()
    three_months = date(today.year, today.month + 3 if today.month <= 9 else today.month - 9, today.day)
    
    for v in vaccinations:
        if v.next_dose_due and v.next_dose_due <= three_months:
            upcoming.append({
                "vaccine_type": v.vaccine_type,
                "vaccine_name": v.vaccine_name,
                "due_date": v.next_dose_due,
                "days_until": (v.next_dose_due - today).days,
                "overdue": v.next_dose_due < today,
            })
    
    return sorted(upcoming, key=lambda x: x["due_date"])


@router.get("/my/{vaccination_id}", response_model=VaccinationRecord)
async def get_vaccination_detail(
    vaccination_id: str,
    current_user: User = Depends(get_current_user),
):
    """Holt Details einer einzelnen Impfung."""
    if vaccination_id not in _vaccinations:
        raise HTTPException(status_code=404, detail="Vaccination not found")
    
    vaccination = _vaccinations[vaccination_id]
    if vaccination.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return vaccination


# =============================================================================
# RECALL SYSTEM
# =============================================================================

@router.get("/recalls/my", response_model=list[RecallNotification])
async def get_my_recalls(
    current_user: User = Depends(get_current_user),
):
    """
    Holt alle Recall-Erinnerungen des Patienten.
    """
    patient_id = str(current_user.id)
    
    recalls = [r for r in _recalls.values() if r.patient_id == patient_id]
    return sorted(recalls, key=lambda x: x.due_date)


@router.post("/recalls/{recall_id}/acknowledge")
async def acknowledge_recall(
    recall_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Bestätigt Erhalt einer Recall-Erinnerung.
    """
    if recall_id not in _recalls:
        raise HTTPException(status_code=404, detail="Recall not found")
    
    recall = _recalls[recall_id]
    if recall.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    recall.acknowledged_at = datetime.now(timezone.utc)
    
    return {"status": "acknowledged"}


@router.post("/recalls/{recall_id}/schedule")
async def schedule_from_recall(
    recall_id: str,
    appointment_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Verknüpft Recall mit gebuchtem Termin.
    """
    if recall_id not in _recalls:
        raise HTTPException(status_code=404, detail="Recall not found")
    
    recall = _recalls[recall_id]
    recall.scheduled_appointment_id = appointment_id
    
    return {"status": "scheduled", "appointment_id": appointment_id}


# =============================================================================
# EXPORT
# =============================================================================

@router.get("/my/export/who-card")
async def export_who_vaccination_card(
    current_user: User = Depends(get_current_user),
):
    """
    Exportiert Impfpass im WHO-Format (International Certificate of Vaccination).
    """
    # TODO: PDF-Generierung
    return {
        "status": "generating",
        "format": "WHO International Certificate",
        "download_url": "/api/vaccinations/my/export/who-card/download",
    }


@router.get("/my/export/eu-dcc")
async def export_eu_digital_certificate(
    vaccine_type: VaccineType,
    current_user: User = Depends(get_current_user),
):
    """
    Exportiert EU Digital COVID Certificate (falls verfügbar).
    """
    if vaccine_type != VaccineType.covid19:
        raise HTTPException(status_code=400, detail="EU DCC only available for COVID-19")
    
    # TODO: QR-Code Generierung
    return {
        "status": "generating",
        "format": "EU Digital COVID Certificate",
    }


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def _calculate_vaccination_status(vaccinations: list[VaccinationRecord]) -> list[VaccinationStatus]:
    """Berechnet Status für jeden Impfstoff-Typ"""
    
    status_list = []
    today = date.today()
    
    # Gruppiere nach Typ
    by_type: dict[VaccineType, list[VaccinationRecord]] = {}
    for v in vaccinations:
        if v.vaccine_type not in by_type:
            by_type[v.vaccine_type] = []
        by_type[v.vaccine_type].append(v)
    
    # Standard-Impfungen prüfen
    for vtype, rec in STIKO_RECOMMENDATIONS.items():
        vax_list = by_type.get(vtype, [])
        
        if not vax_list:
            status_list.append(VaccinationStatus(
                vaccine_type=vtype,
                name=rec["name"],
                status="not_started",
                doses_received=0,
            ))
            continue
        
        last = max(vax_list, key=lambda x: x.date)
        
        # Nächste Dosis berechnen
        if "interval_years" in rec:
            next_due = date(last.date.year + rec["interval_years"], last.date.month, last.date.day)
        elif "interval_months" in rec:
            months = rec["interval_months"]
            next_due = date(last.date.year + months // 12, 
                          last.date.month + months % 12, last.date.day)
        else:
            next_due = None
        
        if next_due and next_due < today:
            status = "overdue"
        elif next_due:
            status = "complete"
        else:
            status = "complete"
        
        status_list.append(VaccinationStatus(
            vaccine_type=vtype,
            name=rec["name"],
            status=status,
            last_dose=last.date,
            next_dose_due=next_due,
            doses_received=len(vax_list),
        ))
    
    return status_list


def _generate_recommendations(
    vaccinations: list[VaccinationRecord],
    patient_age: int,
) -> list[VaccinationRecommendation]:
    """Generiert personalisierte Impfempfehlungen"""
    
    recommendations = []
    today = date.today()
    
    # Gruppiere nach Typ
    by_type: dict[VaccineType, list[VaccinationRecord]] = {}
    for v in vaccinations:
        if v.vaccine_type not in by_type:
            by_type[v.vaccine_type] = []
        by_type[v.vaccine_type].append(v)
    
    # Grippe (jährlich, ab Herbst)
    flu_list = by_type.get(VaccineType.influenza, [])
    current_year_flu = [v for v in flu_list if v.date.year == today.year]
    if not current_year_flu and today.month >= 9:
        recommendations.append(VaccinationRecommendation(
            vaccine_type=VaccineType.influenza,
            vaccine_name="Grippe-Impfung",
            reason="Jährliche Grippeimpfung empfohlen (Saison 2024/25)",
            priority="high" if patient_age >= 60 else "medium",
            due_date=date(today.year, 11, 30),
        ))
    
    # Tetanus/Diphtherie Auffrischung
    tdap = by_type.get(VaccineType.tetanus, [])
    if tdap:
        last_tdap = max(tdap, key=lambda x: x.date)
        years_since = (today - last_tdap.date).days // 365
        if years_since >= 10:
            recommendations.append(VaccinationRecommendation(
                vaccine_type=VaccineType.tetanus,
                vaccine_name="Tetanus/Diphtherie/Pertussis",
                reason=f"Auffrischung fällig (letzte Impfung vor {years_since} Jahren)",
                priority="medium",
            ))
    else:
        recommendations.append(VaccinationRecommendation(
            vaccine_type=VaccineType.tetanus,
            vaccine_name="Tetanus/Diphtherie/Pertussis",
            reason="Keine Impfung dokumentiert",
            priority="high",
        ))
    
    # Pneumokokken ab 60
    if patient_age >= 60:
        pneumo = by_type.get(VaccineType.pneumococcal, [])
        if not pneumo:
            recommendations.append(VaccinationRecommendation(
                vaccine_type=VaccineType.pneumococcal,
                vaccine_name="Pneumokokken",
                reason="Empfohlen für Personen ab 60 Jahren (STIKO)",
                priority="medium",
            ))
    
    return recommendations
