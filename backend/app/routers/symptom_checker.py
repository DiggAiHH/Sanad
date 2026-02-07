"""
AI Symptom Checker / Triage System
==================================
Intelligente Symptom-Erfassung mit Triage-Empfehlung.
KEIN Ersatz für ärztliche Diagnose - nur Orientierung.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone
from typing import Optional
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/symptom-checker", tags=["Symptom Checker"])


# =============================================================================
# SCHEMAS
# =============================================================================

class TriageLevel(str, Enum):
    """Dringlichkeitsstufen"""
    emergency = "emergency"         # 🔴 Sofort Notarzt (112)
    urgent = "urgent"               # 🟠 Heute noch zum Arzt
    soon = "soon"                   # 🟡 Termin in 1-2 Tagen
    routine = "routine"             # 🟢 Routinetermin möglich
    self_care = "self_care"         # ⚪ Selbstbehandlung möglich


class SymptomCategory(str, Enum):
    """Symptom-Kategorien"""
    pain = "pain"
    respiratory = "respiratory"
    digestive = "digestive"
    skin = "skin"
    neurological = "neurological"
    cardiovascular = "cardiovascular"
    musculoskeletal = "musculoskeletal"
    psychological = "psychological"
    general = "general"
    urogenital = "urogenital"


class Symptom(BaseModel):
    """Einzelnes Symptom"""
    id: str
    name: str
    category: SymptomCategory
    severity: int = Field(ge=1, le=10)  # 1-10
    duration_hours: Optional[int] = None
    location: Optional[str] = None
    description: Optional[str] = None


class RedFlag(BaseModel):
    """Warnzeichen für Notfall"""
    id: str
    text: str
    urgency: TriageLevel


class FollowUpQuestion(BaseModel):
    """Nachfrage zur Symptomklärung"""
    id: str
    text: str
    type: str  # yes_no, single_choice, multiple_choice, scale
    options: Optional[list[str]] = None


class TriageResult(BaseModel):
    """Ergebnis der Triage"""
    level: TriageLevel
    recommendation: str
    reason: str
    suggested_appointment_type: Optional[str] = None
    red_flags_detected: list[str] = []
    self_care_tips: list[str] = []
    when_to_seek_help: list[str] = []


class SymptomCheckRequest(BaseModel):
    """Anfrage für Symptom-Check"""
    symptoms: list[Symptom]
    red_flag_answers: dict[str, bool] = {}  # Antworten auf Red-Flag-Fragen
    follow_up_answers: dict[str, str] = {}
    patient_age: Optional[int] = None
    patient_gender: Optional[str] = None
    is_pregnant: Optional[bool] = None
    chronic_conditions: list[str] = []


class SymptomCheckResponse(BaseModel):
    """Antwort des Symptom-Checkers"""
    session_id: str
    triage: TriageResult
    follow_up_questions: list[FollowUpQuestion] = []
    disclaimer: str
    created_at: datetime


# =============================================================================
# RED FLAGS - Notfall-Warnzeichen
# =============================================================================

RED_FLAGS = [
    RedFlag(id="rf_chest_pain", text="Brustschmerzen mit Ausstrahlung in Arm/Kiefer", urgency=TriageLevel.emergency),
    RedFlag(id="rf_breathing_severe", text="Schwere Atemnot, kann kaum sprechen", urgency=TriageLevel.emergency),
    RedFlag(id="rf_stroke_signs", text="Plötzliche Lähmung, Sprachstörung, hängender Mundwinkel", urgency=TriageLevel.emergency),
    RedFlag(id="rf_unconscious", text="Bewusstlosigkeit oder starke Verwirrtheit", urgency=TriageLevel.emergency),
    RedFlag(id="rf_severe_bleeding", text="Starke, nicht stillbare Blutung", urgency=TriageLevel.emergency),
    RedFlag(id="rf_anaphylaxis", text="Schwellung im Hals/Gesicht, Atemnot nach Allergen-Kontakt", urgency=TriageLevel.emergency),
    RedFlag(id="rf_fever_high", text="Fieber über 40°C mit Nackensteifigkeit", urgency=TriageLevel.emergency),
    RedFlag(id="rf_suicidal", text="Suizidgedanken oder Selbstverletzungsabsichten", urgency=TriageLevel.emergency),
    
    RedFlag(id="rf_fever_prolonged", text="Fieber über 38.5°C seit mehr als 3 Tagen", urgency=TriageLevel.urgent),
    RedFlag(id="rf_vomiting_blood", text="Blut im Erbrochenen oder schwarzer Stuhl", urgency=TriageLevel.urgent),
    RedFlag(id="rf_severe_headache", text="Schlimmster Kopfschmerz des Lebens (plötzlich)", urgency=TriageLevel.urgent),
    RedFlag(id="rf_vision_sudden", text="Plötzlicher Sehverlust oder Doppelbilder", urgency=TriageLevel.urgent),
]


# =============================================================================
# SYMPTOM-KATALOG
# =============================================================================

COMMON_SYMPTOMS = [
    {"id": "headache", "name": "Kopfschmerzen", "category": "neurological"},
    {"id": "fever", "name": "Fieber", "category": "general"},
    {"id": "cough", "name": "Husten", "category": "respiratory"},
    {"id": "sore_throat", "name": "Halsschmerzen", "category": "respiratory"},
    {"id": "runny_nose", "name": "Schnupfen", "category": "respiratory"},
    {"id": "fatigue", "name": "Müdigkeit/Erschöpfung", "category": "general"},
    {"id": "nausea", "name": "Übelkeit", "category": "digestive"},
    {"id": "diarrhea", "name": "Durchfall", "category": "digestive"},
    {"id": "stomach_pain", "name": "Bauchschmerzen", "category": "digestive"},
    {"id": "back_pain", "name": "Rückenschmerzen", "category": "musculoskeletal"},
    {"id": "joint_pain", "name": "Gelenkschmerzen", "category": "musculoskeletal"},
    {"id": "rash", "name": "Hautausschlag", "category": "skin"},
    {"id": "dizziness", "name": "Schwindel", "category": "neurological"},
    {"id": "chest_pain", "name": "Brustschmerzen", "category": "cardiovascular"},
    {"id": "shortness_breath", "name": "Kurzatmigkeit", "category": "respiratory"},
    {"id": "anxiety", "name": "Angst/Unruhe", "category": "psychological"},
    {"id": "sleep_problems", "name": "Schlafstörungen", "category": "psychological"},
]


# =============================================================================
# TRIAGE-LOGIK
# =============================================================================

def _calculate_triage(request: SymptomCheckRequest) -> TriageResult:
    """
    Berechnet Triage basierend auf Symptomen und Red Flags.
    
    WICHTIG: Dies ist KEINE medizinische Diagnose!
    Nur zur groben Einschätzung der Dringlichkeit.
    """
    
    red_flags_detected = []
    highest_urgency = TriageLevel.self_care
    
    # 1. Red Flags prüfen
    for rf_id, answered_yes in request.red_flag_answers.items():
        if answered_yes:
            for rf in RED_FLAGS:
                if rf.id == rf_id:
                    red_flags_detected.append(rf.text)
                    if _urgency_higher(rf.urgency, highest_urgency):
                        highest_urgency = rf.urgency
    
    # 2. Symptom-Schweregrade prüfen
    if request.symptoms:
        max_severity = max(s.severity for s in request.symptoms)
        
        # Hohe Schweregrade erhöhen Dringlichkeit
        if max_severity >= 9 and highest_urgency not in [TriageLevel.emergency]:
            highest_urgency = TriageLevel.urgent
        elif max_severity >= 7 and highest_urgency == TriageLevel.self_care:
            highest_urgency = TriageLevel.soon
        elif max_severity >= 5 and highest_urgency == TriageLevel.self_care:
            highest_urgency = TriageLevel.routine
    
    # 3. Kombinationen prüfen (vereinfacht)
    symptom_ids = {s.id for s in request.symptoms}
    
    # Brustschmerz + Atemnot = Notfall
    if "chest_pain" in symptom_ids and "shortness_breath" in symptom_ids:
        if highest_urgency != TriageLevel.emergency:
            highest_urgency = TriageLevel.urgent
            red_flags_detected.append("Kombination Brustschmerzen + Atemnot")
    
    # Fieber + starke Kopfschmerzen
    if "fever" in symptom_ids and "headache" in symptom_ids:
        fever_symptom = next((s for s in request.symptoms if s.id == "fever"), None)
        if fever_symptom and fever_symptom.severity >= 8:
            if highest_urgency not in [TriageLevel.emergency, TriageLevel.urgent]:
                highest_urgency = TriageLevel.urgent
    
    # 4. Empfehlungen generieren
    recommendation, reason, tips, when_help = _generate_recommendations(
        highest_urgency, request.symptoms, red_flags_detected
    )
    
    # 5. Termintyp vorschlagen
    appointment_type = _suggest_appointment_type(highest_urgency, request.symptoms)
    
    return TriageResult(
        level=highest_urgency,
        recommendation=recommendation,
        reason=reason,
        suggested_appointment_type=appointment_type,
        red_flags_detected=red_flags_detected,
        self_care_tips=tips,
        when_to_seek_help=when_help,
    )


def _urgency_higher(a: TriageLevel, b: TriageLevel) -> bool:
    """Vergleicht Dringlichkeitsstufen"""
    order = [
        TriageLevel.self_care,
        TriageLevel.routine,
        TriageLevel.soon,
        TriageLevel.urgent,
        TriageLevel.emergency,
    ]
    return order.index(a) > order.index(b)


def _generate_recommendations(
    level: TriageLevel,
    symptoms: list[Symptom],
    red_flags: list[str],
) -> tuple[str, str, list[str], list[str]]:
    """Generiert Empfehlungen basierend auf Triage-Level"""
    
    if level == TriageLevel.emergency:
        return (
            "Rufen Sie sofort den Notruf (112) oder lassen Sie sich in die Notaufnahme bringen!",
            "Ihre Symptome könnten auf eine akut lebensbedrohliche Situation hindeuten.",
            [],
            [],
        )
    
    if level == TriageLevel.urgent:
        return (
            "Suchen Sie heute noch einen Arzt auf oder gehen Sie in die Notfallpraxis.",
            "Ihre Symptome erfordern eine zeitnahe ärztliche Abklärung.",
            [],
            [
                "Bei Verschlechterung sofort Notruf wählen",
                "Lassen Sie sich begleiten",
            ],
        )
    
    if level == TriageLevel.soon:
        return (
            "Vereinbaren Sie einen Termin innerhalb der nächsten 1-2 Tage.",
            "Ihre Symptome sollten zeitnah ärztlich untersucht werden.",
            [
                "Ruhen Sie sich aus",
                "Trinken Sie ausreichend",
                "Notieren Sie Veränderungen der Symptome",
            ],
            [
                "Bei Fieber über 39°C",
                "Bei deutlicher Verschlechterung",
                "Bei neuen Symptomen",
            ],
        )
    
    if level == TriageLevel.routine:
        return (
            "Ein regulärer Arzttermin in den nächsten Tagen ist empfehlenswert.",
            "Ihre Symptome sind nicht akut bedrohlich, sollten aber abgeklärt werden.",
            [
                "Schonen Sie sich",
                "Ausreichend Flüssigkeit",
                "Bei Schmerzen: Ibuprofen oder Paracetamol nach Packungsbeilage",
            ],
            [
                "Bei Verschlechterung",
                "Wenn Symptome länger als eine Woche anhalten",
            ],
        )
    
    # self_care
    return (
        "Eine Selbstbehandlung zu Hause scheint möglich.",
        "Ihre Symptome sind mild und können wahrscheinlich selbst behandelt werden.",
        [
            "Ausreichend Ruhe",
            "Viel trinken (Wasser, Tee)",
            "Bei Erkältung: Inhalieren, Nasenspray",
            "Bei leichten Schmerzen: Ibuprofen oder Paracetamol",
        ],
        [
            "Wenn keine Besserung nach 3-5 Tagen",
            "Bei Verschlechterung der Symptome",
            "Bei Fieber über 38.5°C",
        ],
    )


def _suggest_appointment_type(level: TriageLevel, symptoms: list[Symptom]) -> Optional[str]:
    """Schlägt passenden Termintyp vor"""
    
    if level == TriageLevel.emergency:
        return "emergency"
    if level == TriageLevel.urgent:
        return "acute"
    if level == TriageLevel.soon:
        return "acute"
    if level == TriageLevel.routine:
        return "followup"
    return None


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.get("/symptoms")
async def get_symptom_catalog():
    """
    Liefert den Symptom-Katalog für die Auswahl.
    
    Returns:
        Liste häufiger Symptome mit Kategorien
    """
    return {
        "symptoms": COMMON_SYMPTOMS,
        "categories": [c.value for c in SymptomCategory],
    }


@router.get("/red-flags")
async def get_red_flags():
    """
    Liefert Red-Flag-Fragen für Notfall-Screening.
    
    Returns:
        Liste der Red-Flag-Fragen
    """
    return {"red_flags": [rf.model_dump() for rf in RED_FLAGS]}


@router.post("/check", response_model=SymptomCheckResponse)
async def check_symptoms(
    request: SymptomCheckRequest,
    current_user: Optional[User] = Depends(get_current_user),
):
    """
    Führt Symptom-Check und Triage durch.
    
    Args:
        request: Symptome und Antworten
        
    Returns:
        Triage-Ergebnis mit Empfehlungen
        
    DISCLAIMER: Kein Ersatz für ärztliche Diagnose!
    """
    
    session_id = str(uuid.uuid4())
    
    # Triage berechnen
    triage = _calculate_triage(request)
    
    # Follow-up-Fragen generieren (wenn nötig)
    follow_ups = []
    
    # Bei bestimmten Symptomen Nachfragen
    symptom_ids = {s.id for s in request.symptoms}
    
    if "headache" in symptom_ids and "headache_type" not in request.follow_up_answers:
        follow_ups.append(FollowUpQuestion(
            id="headache_type",
            text="Wie würden Sie den Kopfschmerz beschreiben?",
            type="single_choice",
            options=["Drückend/dumpf", "Pulsierend/pochend", "Stechend", "Brennend"],
        ))
    
    if "chest_pain" in symptom_ids and "chest_pain_trigger" not in request.follow_up_answers:
        follow_ups.append(FollowUpQuestion(
            id="chest_pain_trigger",
            text="Wann treten die Brustschmerzen auf?",
            type="single_choice",
            options=["In Ruhe", "Bei Belastung", "Beim Atmen", "Nach dem Essen"],
        ))
    
    return SymptomCheckResponse(
        session_id=session_id,
        triage=triage,
        follow_up_questions=follow_ups,
        disclaimer=(
            "WICHTIGER HINWEIS: Diese Einschätzung ersetzt KEINE ärztliche Diagnose. "
            "Bei Unsicherheit oder Verschlechterung suchen Sie bitte immer einen Arzt auf. "
            "Im Notfall rufen Sie 112 an."
        ),
        created_at=datetime.now(timezone.utc),
    )


@router.post("/save-session")
async def save_symptom_session(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Speichert Symptom-Check-Session für spätere Referenz.
    Nützlich für den Arzt bei der Besprechung.
    """
    # TODO: In Datenbank speichern
    return {"status": "saved", "session_id": session_id}
