"""
Practice Forms & Document Templates
===================================
Downloadbare Formulare und Dokumente für Patienten.
"""

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone
from typing import Optional, Any
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel

router = APIRouter(prefix="/forms", tags=["Practice Forms"])


# =============================================================================
# SCHEMAS
# =============================================================================

class FormCategory(str, Enum):
    """Formular-Kategorien"""
    general = "general"             # Allgemeine Formulare
    consent = "consent"             # Einwilligungen
    medical = "medical"             # Medizinische Formulare
    insurance = "insurance"         # Krankenkasse
    referral = "referral"           # Überweisungen
    prescription = "prescription"   # Rezepte
    certificate = "certificate"     # Bescheinigungen
    travel = "travel"               # Reisemedizin


class FormFormat(str, Enum):
    """Verfügbare Formate"""
    pdf = "pdf"
    docx = "docx"
    online = "online"  # Digitales Ausfüllen


class PracticeForm(BaseModel):
    """Praxis-Formular"""
    id: str
    name: str
    description: str
    category: FormCategory
    formats: list[FormFormat]
    fillable_online: bool = False
    requires_auth: bool = False
    download_count: int = 0
    last_updated: datetime
    thumbnail_url: Optional[str] = None


class FormSubmission(BaseModel):
    """Eingereichtes Online-Formular"""
    id: str
    form_id: str
    patient_id: str
    data: dict
    submitted_at: datetime
    processed: bool = False
    processed_at: Optional[datetime] = None


# =============================================================================
# FORMULARE
# =============================================================================

PRACTICE_FORMS = [
    # Allgemein
    PracticeForm(
        id="form-001",
        name="Patientenaufnahme-Bogen",
        description="Erstaufnahme-Formular für neue Patienten mit persönlichen Daten",
        category=FormCategory.general,
        formats=[FormFormat.pdf, FormFormat.online],
        fillable_online=True,
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-002",
        name="Anamnesebogen Allgemein",
        description="Ausführlicher Fragebogen zur Krankengeschichte",
        category=FormCategory.medical,
        formats=[FormFormat.pdf, FormFormat.online],
        fillable_online=True,
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-003",
        name="Vollmacht für Angehörige",
        description="Berechtigung zur Abholung von Rezepten/Befunden",
        category=FormCategory.general,
        formats=[FormFormat.pdf],
        last_updated=datetime(2024, 1, 1),
    ),
    
    # Einwilligungen
    PracticeForm(
        id="form-010",
        name="DSGVO Einwilligung",
        description="Einwilligung zur Datenverarbeitung nach DSGVO",
        category=FormCategory.consent,
        formats=[FormFormat.pdf, FormFormat.online],
        fillable_online=True,
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-011",
        name="Einwilligung Impfung",
        description="Aufklärung und Einwilligung vor Impfung",
        category=FormCategory.consent,
        formats=[FormFormat.pdf],
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-012",
        name="Einwilligung Blutabnahme",
        description="Einwilligung zur Blutentnahme und Laboruntersuchung",
        category=FormCategory.consent,
        formats=[FormFormat.pdf],
        last_updated=datetime(2024, 1, 1),
    ),
    
    # Krankenkasse
    PracticeForm(
        id="form-020",
        name="Befreiungsausweis Zuzahlung",
        description="Antrag auf Befreiung von Zuzahlungen",
        category=FormCategory.insurance,
        formats=[FormFormat.pdf],
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-021",
        name="Kostenübernahme-Antrag",
        description="Antrag auf Kostenübernahme für Behandlung",
        category=FormCategory.insurance,
        formats=[FormFormat.pdf],
        last_updated=datetime(2024, 1, 1),
    ),
    
    # Bescheinigungen
    PracticeForm(
        id="form-030",
        name="AU-Bescheinigung digital",
        description="Elektronische Arbeitsunfähigkeitsbescheinigung",
        category=FormCategory.certificate,
        formats=[FormFormat.online],
        fillable_online=True,
        requires_auth=True,
        last_updated=datetime(2024, 1, 1),
    ),
    PracticeForm(
        id="form-031",
        name="Sportbefreiung Schule",
        description="Attest für Schulsport-Befreiung",
        category=FormCategory.certificate,
        formats=[FormFormat.pdf],
        requires_auth=True,
        last_updated=datetime(2024, 1, 1),
    ),
    
    # Reisemedizin
    PracticeForm(
        id="form-040",
        name="Reisemedizinische Beratung",
        description="Fragebogen vor Reiseimpfberatung",
        category=FormCategory.travel,
        formats=[FormFormat.pdf, FormFormat.online],
        fillable_online=True,
        last_updated=datetime(2024, 1, 1),
    ),
]


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.get("/", response_model=list[PracticeForm])
async def list_forms(
    category: Optional[FormCategory] = None,
    fillable_online: Optional[bool] = None,
):
    """
    Listet alle verfügbaren Praxis-Formulare.
    
    Args:
        category: Filter nach Kategorie
        fillable_online: Filter nach Online-Ausfüllbar
        
    Returns:
        Liste der Formulare
    """
    forms = PRACTICE_FORMS
    
    if category:
        forms = [f for f in forms if f.category == category]
    
    if fillable_online is not None:
        forms = [f for f in forms if f.fillable_online == fillable_online]
    
    return forms


@router.get("/categories")
async def list_categories():
    """Listet alle Formular-Kategorien mit Anzahl."""
    counts = {}
    for cat in FormCategory:
        counts[cat.value] = len([f for f in PRACTICE_FORMS if f.category == cat])
    
    return {
        "categories": [
            {"id": cat.value, "name": _translate_category(cat), "count": counts[cat.value]}
            for cat in FormCategory
        ]
    }


@router.get("/{form_id}", response_model=PracticeForm)
async def get_form(form_id: str):
    """Holt Details eines Formulars."""
    form = next((f for f in PRACTICE_FORMS if f.id == form_id), None)
    if not form:
        raise HTTPException(status_code=404, detail="Form not found")
    return form


@router.get("/{form_id}/download")
async def download_form(
    form_id: str,
    format: FormFormat = FormFormat.pdf,
):
    """
    Lädt ein Formular herunter.
    
    Args:
        form_id: ID des Formulars
        format: Gewünschtes Format (pdf, docx)
        
    Returns:
        Formular-Datei
    """
    form = next((f for f in PRACTICE_FORMS if f.id == form_id), None)
    if not form:
        raise HTTPException(status_code=404, detail="Form not found")
    
    if format not in form.formats:
        raise HTTPException(status_code=400, detail=f"Format {format} not available")
    
    # TODO: Echte PDF-Generierung/Auslieferung
    # Demo: Placeholder Response
    
    return {
        "form_id": form_id,
        "format": format,
        "download_url": f"/api/v1/forms/{form_id}/file.{format.value}",
        "expires_in": 3600,
    }


@router.post("/{form_id}/submit")
async def submit_online_form(
    form_id: str,
    data: dict[str, Any],
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Reicht ein Online-Formular ein.
    
    Args:
        form_id: ID des Formulars
        data: Ausgefüllte Formulardaten
        
    Returns:
        Bestätigung der Einreichung
    """
    form = next((f for f in PRACTICE_FORMS if f.id == form_id), None)
    if not form:
        raise HTTPException(status_code=404, detail="Form not found")
    
    if not form.fillable_online:
        raise HTTPException(status_code=400, detail="Form not available for online submission")
    
    submission_id = str(uuid.uuid4())
    
    # TODO: In Datenbank speichern
    
    return {
        "status": "submitted",
        "submission_id": submission_id,
        "form_name": form.name,
        "submitted_at": datetime.now(timezone.utc),
        "message": "Ihr Formular wurde erfolgreich eingereicht.",
    }


def _translate_category(cat: FormCategory) -> str:
    """Übersetzt Kategorie-Namen"""
    translations = {
        FormCategory.general: "Allgemein",
        FormCategory.consent: "Einwilligungen",
        FormCategory.medical: "Medizinisch",
        FormCategory.insurance: "Krankenkasse",
        FormCategory.referral: "Überweisungen",
        FormCategory.prescription: "Rezepte",
        FormCategory.certificate: "Bescheinigungen",
        FormCategory.travel: "Reisemedizin",
    }
    return translations.get(cat, cat.value)
