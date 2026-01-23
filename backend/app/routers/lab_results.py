"""
Lab Results / Befunde Router
============================
Verwaltung von Laborergebnissen und Befunden.
Ermöglicht digitale Freigabe an Patienten.
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

router = APIRouter(prefix="/lab-results", tags=["Lab Results"])


# =============================================================================
# SCHEMAS
# =============================================================================

class ResultStatus(str, Enum):
    """Status eines Befunds"""
    pending = "pending"           # Labor noch ausständig
    received = "received"         # Eingegangen, noch nicht freigegeben
    reviewed = "reviewed"         # Arzt hat gesehen
    released = "released"         # Für Patient freigegeben
    discussed = "discussed"       # Mit Patient besprochen


class ValueStatus(str, Enum):
    """Bewertung eines Laborwerts"""
    normal = "normal"             # Im Normalbereich
    low = "low"                   # Zu niedrig
    high = "high"                 # Zu hoch
    critical_low = "critical_low"   # Kritisch niedrig
    critical_high = "critical_high" # Kritisch hoch


class LabCategory(str, Enum):
    """Kategorien von Laboruntersuchungen"""
    blood_count = "blood_count"         # Blutbild
    metabolic = "metabolic"             # Stoffwechsel
    liver = "liver"                     # Leberwerte
    kidney = "kidney"                   # Nierenwerte
    thyroid = "thyroid"                 # Schilddrüse
    lipids = "lipids"                   # Blutfette
    inflammation = "inflammation"       # Entzündungswerte
    coagulation = "coagulation"         # Gerinnung
    vitamins = "vitamins"               # Vitamine
    hormones = "hormones"               # Hormone
    other = "other"                     # Sonstige


class LabValue(BaseModel):
    """Einzelner Laborwert"""
    id: str
    name: str
    short_name: str
    value: float
    unit: str
    reference_min: Optional[float] = None
    reference_max: Optional[float] = None
    status: ValueStatus
    category: LabCategory
    note: Optional[str] = None  # Arzt-Kommentar


class LabResult(BaseModel):
    """Kompletter Laborbefund"""
    id: str
    patient_id: str
    order_date: date
    result_date: Optional[date] = None
    status: ResultStatus
    lab_name: str
    ordering_doctor: str
    values: list[LabValue]
    doctor_comment: Optional[str] = None
    patient_visible: bool = False
    released_at: Optional[datetime] = None
    released_by: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class LabResultSummary(BaseModel):
    """Zusammenfassung für Listen-Ansicht"""
    id: str
    order_date: date
    result_date: Optional[date]
    status: ResultStatus
    lab_name: str
    has_abnormal: bool
    abnormal_count: int
    total_values: int
    patient_visible: bool


class ReleaseResultRequest(BaseModel):
    """Anfrage zur Freigabe eines Befunds"""
    result_id: str
    doctor_comment: Optional[str] = None
    notify_patient: bool = True


class FindingType(str, Enum):
    """Arten von Befunden (nicht Labor)"""
    radiology = "radiology"       # Röntgen, CT, MRT
    ultrasound = "ultrasound"     # Ultraschall
    ecg = "ecg"                   # EKG
    spirometry = "spirometry"     # Lungenfunktion
    pathology = "pathology"       # Pathologie
    other = "other"


class MedicalFinding(BaseModel):
    """Medizinischer Befund (nicht Labor)"""
    id: str
    patient_id: str
    type: FindingType
    title: str
    date: date
    examiner: str
    findings: str  # Befundtext
    conclusion: str  # Beurteilung
    recommendations: Optional[str] = None
    status: ResultStatus
    document_url: Optional[str] = None  # PDF/Bild
    patient_visible: bool = False
    released_at: Optional[datetime] = None
    created_at: datetime


# =============================================================================
# MOCK DATA
# =============================================================================

def _create_mock_results() -> dict[str, LabResult]:
    """Erstellt Demo-Laborbefunde"""
    
    results = {}
    
    # Beispiel-Befund 1: Großes Blutbild
    result1 = LabResult(
        id="lab-001",
        patient_id="patient-1",
        order_date=date(2024, 1, 15),
        result_date=date(2024, 1, 16),
        status=ResultStatus.released,
        lab_name="Labor Dr. Müller",
        ordering_doctor="Dr. med. Schmidt",
        patient_visible=True,
        released_at=datetime(2024, 1, 17, 10, 30),
        released_by="Dr. med. Schmidt",
        doctor_comment="Alle Werte im Normbereich. Weiter so!",
        created_at=datetime(2024, 1, 15),
        updated_at=datetime(2024, 1, 17),
        values=[
            LabValue(
                id="v1", name="Hämoglobin", short_name="Hb",
                value=14.5, unit="g/dl", reference_min=12.0, reference_max=16.0,
                status=ValueStatus.normal, category=LabCategory.blood_count,
            ),
            LabValue(
                id="v2", name="Leukozyten", short_name="Leuko",
                value=7.2, unit="Tsd/µl", reference_min=4.0, reference_max=10.0,
                status=ValueStatus.normal, category=LabCategory.blood_count,
            ),
            LabValue(
                id="v3", name="Thrombozyten", short_name="Thrombo",
                value=245, unit="Tsd/µl", reference_min=150, reference_max=400,
                status=ValueStatus.normal, category=LabCategory.blood_count,
            ),
            LabValue(
                id="v4", name="Erythrozyten", short_name="Ery",
                value=4.8, unit="Mio/µl", reference_min=4.0, reference_max=5.5,
                status=ValueStatus.normal, category=LabCategory.blood_count,
            ),
        ],
    )
    results[result1.id] = result1
    
    # Beispiel-Befund 2: Stoffwechsel mit Auffälligkeiten
    result2 = LabResult(
        id="lab-002",
        patient_id="patient-1",
        order_date=date(2024, 1, 20),
        result_date=date(2024, 1, 21),
        status=ResultStatus.released,
        lab_name="Labor Dr. Müller",
        ordering_doctor="Dr. med. Schmidt",
        patient_visible=True,
        released_at=datetime(2024, 1, 22, 14, 0),
        released_by="Dr. med. Schmidt",
        doctor_comment="Cholesterin leicht erhöht. Bitte Termin zur Besprechung vereinbaren.",
        created_at=datetime(2024, 1, 20),
        updated_at=datetime(2024, 1, 22),
        values=[
            LabValue(
                id="v5", name="Blutzucker nüchtern", short_name="Glukose",
                value=95, unit="mg/dl", reference_min=70, reference_max=100,
                status=ValueStatus.normal, category=LabCategory.metabolic,
            ),
            LabValue(
                id="v6", name="HbA1c", short_name="HbA1c",
                value=5.4, unit="%", reference_min=4.0, reference_max=5.7,
                status=ValueStatus.normal, category=LabCategory.metabolic,
            ),
            LabValue(
                id="v7", name="Gesamt-Cholesterin", short_name="Chol",
                value=235, unit="mg/dl", reference_min=0, reference_max=200,
                status=ValueStatus.high, category=LabCategory.lipids,
                note="Leicht erhöht - Ernährungsberatung empfohlen",
            ),
            LabValue(
                id="v8", name="LDL-Cholesterin", short_name="LDL",
                value=155, unit="mg/dl", reference_min=0, reference_max=130,
                status=ValueStatus.high, category=LabCategory.lipids,
            ),
            LabValue(
                id="v9", name="HDL-Cholesterin", short_name="HDL",
                value=55, unit="mg/dl", reference_min=40, reference_max=200,
                status=ValueStatus.normal, category=LabCategory.lipids,
            ),
            LabValue(
                id="v10", name="Triglyceride", short_name="TG",
                value=145, unit="mg/dl", reference_min=0, reference_max=150,
                status=ValueStatus.normal, category=LabCategory.lipids,
            ),
        ],
    )
    results[result2.id] = result2
    
    # Beispiel-Befund 3: Noch nicht freigegeben
    result3 = LabResult(
        id="lab-003",
        patient_id="patient-1",
        order_date=date(2024, 1, 25),
        result_date=date(2024, 1, 26),
        status=ResultStatus.received,
        lab_name="Labor Dr. Müller",
        ordering_doctor="Dr. med. Schmidt",
        patient_visible=False,
        created_at=datetime(2024, 1, 25),
        updated_at=datetime(2024, 1, 26),
        values=[
            LabValue(
                id="v11", name="TSH", short_name="TSH",
                value=2.1, unit="mU/l", reference_min=0.4, reference_max=4.0,
                status=ValueStatus.normal, category=LabCategory.thyroid,
            ),
            LabValue(
                id="v12", name="fT4", short_name="fT4",
                value=1.2, unit="ng/dl", reference_min=0.8, reference_max=1.8,
                status=ValueStatus.normal, category=LabCategory.thyroid,
            ),
        ],
    )
    results[result3.id] = result3
    
    return results


_lab_results: dict[str, LabResult] = _create_mock_results()
_findings: dict[str, MedicalFinding] = {}


# =============================================================================
# PATIENT ENDPOINTS
# =============================================================================

@router.get("/my", response_model=list[LabResultSummary])
async def get_my_lab_results(
    current_user: User = Depends(get_current_user),
):
    """
    Holt alle freigegebenen Laborbefunde des Patienten.
    
    Returns:
        Liste der Befund-Zusammenfassungen
    """
    patient_id = str(current_user.id)
    
    summaries = []
    for result in _lab_results.values():
        if result.patient_id == patient_id and result.patient_visible:
            abnormal = [v for v in result.values if v.status != ValueStatus.normal]
            summaries.append(LabResultSummary(
                id=result.id,
                order_date=result.order_date,
                result_date=result.result_date,
                status=result.status,
                lab_name=result.lab_name,
                has_abnormal=len(abnormal) > 0,
                abnormal_count=len(abnormal),
                total_values=len(result.values),
                patient_visible=result.patient_visible,
            ))
    
    return sorted(summaries, key=lambda x: x.order_date, reverse=True)


@router.get("/my/{result_id}", response_model=LabResult)
async def get_my_lab_result_detail(
    result_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Holt Details eines spezifischen Laborbefunds.
    
    Args:
        result_id: ID des Befunds
        
    Returns:
        Vollständiger Laborbefund
    """
    if result_id not in _lab_results:
        raise HTTPException(status_code=404, detail="Result not found")
    
    result = _lab_results[result_id]
    
    if result.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    if not result.patient_visible:
        raise HTTPException(status_code=403, detail="Result not yet released")
    
    return result


@router.get("/my/pending-count")
async def get_pending_results_count(
    current_user: User = Depends(get_current_user),
):
    """
    Zählt ausstehende (noch nicht freigegebene) Befunde.
    Nützlich für Badge/Notification.
    """
    patient_id = str(current_user.id)
    
    # Zähle Befunde die eingegangen aber nicht freigegeben sind
    pending = sum(
        1 for r in _lab_results.values()
        if r.patient_id == patient_id 
        and r.status in [ResultStatus.pending, ResultStatus.received, ResultStatus.reviewed]
        and not r.patient_visible
    )
    
    return {"pending_count": pending}


# =============================================================================
# STAFF ENDPOINTS (Befunde verwalten)
# =============================================================================

@router.get("/patient/{patient_id}", response_model=list[LabResult])
async def get_patient_lab_results(
    patient_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    [STAFF] Holt alle Laborbefunde eines Patienten.
    """
    # TODO: Staff-Berechtigung prüfen
    
    results = [r for r in _lab_results.values() if r.patient_id == patient_id]
    return sorted(results, key=lambda x: x.order_date, reverse=True)


@router.post("/release")
async def release_lab_result(
    request: ReleaseResultRequest,
    current_user: User = Depends(get_current_user),
):
    """
    [STAFF] Gibt einen Laborbefund für den Patienten frei.
    
    Args:
        request: Freigabe-Details
        
    Returns:
        Status der Freigabe
    """
    if request.result_id not in _lab_results:
        raise HTTPException(status_code=404, detail="Result not found")
    
    result = _lab_results[request.result_id]
    
    # Update
    result.status = ResultStatus.released
    result.patient_visible = True
    result.released_at = datetime.now(timezone.utc)
    result.released_by = f"Dr. {current_user.name}"
    
    if request.doctor_comment:
        result.doctor_comment = request.doctor_comment
    
    result.updated_at = datetime.now(timezone.utc)
    
    # TODO: Push-Notification an Patient
    if request.notify_patient:
        pass  # await notify_patient_result_ready(result.patient_id)
    
    return {
        "status": "released",
        "result_id": result.id,
        "released_at": result.released_at,
    }


@router.put("/{result_id}/mark-discussed")
async def mark_result_discussed(
    result_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    [STAFF] Markiert einen Befund als besprochen.
    """
    if result_id not in _lab_results:
        raise HTTPException(status_code=404, detail="Result not found")
    
    result = _lab_results[result_id]
    result.status = ResultStatus.discussed
    result.updated_at = datetime.now(timezone.utc)
    
    return {"status": "marked_discussed"}


# =============================================================================
# REFERENCE VALUES
# =============================================================================

@router.get("/reference-values")
async def get_reference_values():
    """
    Liefert Standard-Referenzwerte für die Anzeige.
    Hilfreich für Patienten zum Verständnis.
    """
    return {
        "blood_count": [
            {"name": "Hämoglobin", "unit": "g/dl", "male": "13.5-17.5", "female": "12.0-16.0"},
            {"name": "Leukozyten", "unit": "Tsd/µl", "range": "4.0-10.0"},
            {"name": "Thrombozyten", "unit": "Tsd/µl", "range": "150-400"},
            {"name": "Erythrozyten", "unit": "Mio/µl", "male": "4.5-5.5", "female": "4.0-5.0"},
        ],
        "metabolic": [
            {"name": "Blutzucker nüchtern", "unit": "mg/dl", "range": "70-100"},
            {"name": "HbA1c", "unit": "%", "range": "< 5.7 (normal), 5.7-6.4 (Prädiabetes)"},
        ],
        "lipids": [
            {"name": "Gesamt-Cholesterin", "unit": "mg/dl", "range": "< 200"},
            {"name": "LDL-Cholesterin", "unit": "mg/dl", "range": "< 130"},
            {"name": "HDL-Cholesterin", "unit": "mg/dl", "range": "> 40"},
            {"name": "Triglyceride", "unit": "mg/dl", "range": "< 150"},
        ],
        "disclaimer": "Referenzwerte können je nach Labor variieren. "
                      "Bitte besprechen Sie Ihre Werte immer mit Ihrem Arzt.",
    }
