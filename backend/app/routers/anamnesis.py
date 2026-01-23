"""
Anamnesis/Medical History Router
================================
Digitale Anamnese-Bögen für Patienten zum Vorab-Ausfüllen.
Spart Zeit in der Praxis und verbessert Dokumentation.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone
from typing import Optional, Any
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/anamnesis", tags=["Anamnesis"])


# =============================================================================
# SCHEMAS
# =============================================================================

class QuestionType(str, Enum):
    """Fragetypen für Anamnese-Bögen"""
    text = "text"                 # Freitext
    textarea = "textarea"         # Längerer Freitext
    number = "number"             # Zahl
    date = "date"                 # Datum
    single_choice = "single_choice"    # Einzelauswahl
    multiple_choice = "multiple_choice" # Mehrfachauswahl
    scale = "scale"               # Skala (z.B. 1-10)
    yes_no = "yes_no"             # Ja/Nein
    body_map = "body_map"         # Körperstelle auswählen


class QuestionCondition(BaseModel):
    """Bedingung für bedingte Fragen"""
    question_id: str
    operator: str  # equals, not_equals, contains, greater_than, less_than
    value: Any


class Question(BaseModel):
    """Einzelne Frage im Anamnese-Bogen"""
    id: str
    text: str
    description: Optional[str] = None
    type: QuestionType
    required: bool = False
    options: Optional[list[str]] = None  # Für single/multiple choice
    min_value: Optional[int] = None      # Für scale/number
    max_value: Optional[int] = None
    placeholder: Optional[str] = None
    condition: Optional[QuestionCondition] = None  # Conditional logic
    order: int = 0


class QuestionSection(BaseModel):
    """Abschnitt im Anamnese-Bogen"""
    id: str
    title: str
    description: Optional[str] = None
    questions: list[Question]
    order: int = 0


class AnamnesisTemplate(BaseModel):
    """Anamnese-Bogen-Vorlage"""
    id: str
    name: str
    description: str
    appointment_types: list[str]  # Für welche Termintypen
    sections: list[QuestionSection]
    estimated_minutes: int = 10
    is_active: bool = True
    created_at: datetime
    updated_at: datetime


class Answer(BaseModel):
    """Antwort auf eine Frage"""
    question_id: str
    value: Any


class AnamnesisSubmission(BaseModel):
    """Ausgefüllter Anamnese-Bogen"""
    id: str
    template_id: str
    patient_id: str
    appointment_id: Optional[str] = None
    answers: list[Answer]
    submitted_at: datetime
    reviewed_at: Optional[datetime] = None
    reviewed_by: Optional[str] = None
    pdf_url: Optional[str] = None


class SubmitAnamnesisRequest(BaseModel):
    """Anfrage zum Einreichen eines Anamnese-Bogens"""
    template_id: str
    appointment_id: Optional[str] = None
    answers: list[Answer]


# =============================================================================
# STANDARD-VORLAGEN
# =============================================================================

def _create_general_anamnesis() -> AnamnesisTemplate:
    """Allgemeine Anamnese für Erstpatienten"""
    return AnamnesisTemplate(
        id="general-anamnesis",
        name="Allgemeine Anamnese",
        description="Erstaufnahme-Fragebogen für neue Patienten",
        appointment_types=["acute", "checkup"],
        estimated_minutes=15,
        is_active=True,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
        sections=[
            QuestionSection(
                id="personal",
                title="Persönliche Angaben",
                order=0,
                questions=[
                    Question(
                        id="birth_date",
                        text="Geburtsdatum",
                        type=QuestionType.date,
                        required=True,
                        order=0,
                    ),
                    Question(
                        id="occupation",
                        text="Beruf",
                        type=QuestionType.text,
                        required=False,
                        order=1,
                    ),
                    Question(
                        id="family_status",
                        text="Familienstand",
                        type=QuestionType.single_choice,
                        options=["Ledig", "Verheiratet", "Geschieden", "Verwitwet"],
                        required=False,
                        order=2,
                    ),
                ],
            ),
            QuestionSection(
                id="current_symptoms",
                title="Aktuelle Beschwerden",
                order=1,
                questions=[
                    Question(
                        id="main_complaint",
                        text="Was führt Sie heute zu uns?",
                        type=QuestionType.textarea,
                        required=True,
                        placeholder="Beschreiben Sie Ihre Beschwerden...",
                        order=0,
                    ),
                    Question(
                        id="symptom_duration",
                        text="Seit wann bestehen die Beschwerden?",
                        type=QuestionType.single_choice,
                        options=["Seit heute", "Seit einigen Tagen", "Seit einer Woche", "Seit mehreren Wochen", "Seit Monaten", "Seit Jahren"],
                        required=True,
                        order=1,
                    ),
                    Question(
                        id="pain_level",
                        text="Wie stark sind Ihre Beschwerden auf einer Skala von 1-10?",
                        type=QuestionType.scale,
                        min_value=1,
                        max_value=10,
                        required=False,
                        order=2,
                    ),
                    Question(
                        id="pain_location",
                        text="Wo genau haben Sie Schmerzen/Beschwerden?",
                        type=QuestionType.body_map,
                        required=False,
                        order=3,
                    ),
                ],
            ),
            QuestionSection(
                id="medical_history",
                title="Vorerkrankungen",
                order=2,
                questions=[
                    Question(
                        id="chronic_diseases",
                        text="Haben Sie chronische Erkrankungen?",
                        type=QuestionType.multiple_choice,
                        options=[
                            "Diabetes mellitus",
                            "Bluthochdruck",
                            "Herzerkrankung",
                            "Asthma/COPD",
                            "Schilddrüsenerkrankung",
                            "Rheuma",
                            "Krebs",
                            "Depression/Angststörung",
                            "Keine",
                            "Andere",
                        ],
                        required=True,
                        order=0,
                    ),
                    Question(
                        id="chronic_diseases_other",
                        text="Welche anderen Erkrankungen?",
                        type=QuestionType.text,
                        required=False,
                        condition=QuestionCondition(
                            question_id="chronic_diseases",
                            operator="contains",
                            value="Andere",
                        ),
                        order=1,
                    ),
                    Question(
                        id="surgeries",
                        text="Hatten Sie Operationen? Wenn ja, welche?",
                        type=QuestionType.textarea,
                        required=False,
                        placeholder="z.B. Blinddarm 2015, Knie-OP 2020",
                        order=2,
                    ),
                    Question(
                        id="hospitalizations",
                        text="Waren Sie in den letzten 5 Jahren im Krankenhaus?",
                        type=QuestionType.yes_no,
                        required=True,
                        order=3,
                    ),
                ],
            ),
            QuestionSection(
                id="medications",
                title="Medikamente",
                order=3,
                questions=[
                    Question(
                        id="current_medications",
                        text="Welche Medikamente nehmen Sie regelmäßig ein?",
                        type=QuestionType.textarea,
                        required=False,
                        placeholder="Name, Dosierung, Häufigkeit (z.B. Metformin 500mg, 2x täglich)",
                        order=0,
                    ),
                    Question(
                        id="supplements",
                        text="Nehmen Sie Nahrungsergänzungsmittel?",
                        type=QuestionType.textarea,
                        required=False,
                        placeholder="z.B. Vitamin D, Omega-3",
                        order=1,
                    ),
                ],
            ),
            QuestionSection(
                id="allergies",
                title="Allergien & Unverträglichkeiten",
                order=4,
                questions=[
                    Question(
                        id="has_allergies",
                        text="Haben Sie Allergien?",
                        type=QuestionType.yes_no,
                        required=True,
                        order=0,
                    ),
                    Question(
                        id="allergy_list",
                        text="Welche Allergien haben Sie?",
                        type=QuestionType.multiple_choice,
                        options=[
                            "Penicillin/Antibiotika",
                            "Schmerzmittel (z.B. Ibuprofen)",
                            "Kontrastmittel",
                            "Latex",
                            "Pollen",
                            "Hausstaubmilben",
                            "Tierhaare",
                            "Nahrungsmittel",
                            "Andere",
                        ],
                        condition=QuestionCondition(
                            question_id="has_allergies",
                            operator="equals",
                            value=True,
                        ),
                        order=1,
                    ),
                    Question(
                        id="allergy_reactions",
                        text="Welche Reaktionen treten auf?",
                        type=QuestionType.textarea,
                        condition=QuestionCondition(
                            question_id="has_allergies",
                            operator="equals",
                            value=True,
                        ),
                        order=2,
                    ),
                ],
            ),
            QuestionSection(
                id="family_history",
                title="Familienanamnese",
                order=5,
                questions=[
                    Question(
                        id="family_diseases",
                        text="Gibt es in Ihrer Familie folgende Erkrankungen?",
                        type=QuestionType.multiple_choice,
                        options=[
                            "Herzinfarkt",
                            "Schlaganfall",
                            "Diabetes",
                            "Krebs",
                            "Bluthochdruck",
                            "Keine bekannt",
                        ],
                        required=False,
                        order=0,
                    ),
                ],
            ),
            QuestionSection(
                id="lifestyle",
                title="Lebensstil",
                order=6,
                questions=[
                    Question(
                        id="smoking",
                        text="Rauchen Sie?",
                        type=QuestionType.single_choice,
                        options=["Nie geraucht", "Ex-Raucher", "Gelegentlich", "Täglich"],
                        required=True,
                        order=0,
                    ),
                    Question(
                        id="alcohol",
                        text="Wie oft trinken Sie Alkohol?",
                        type=QuestionType.single_choice,
                        options=["Nie", "Selten", "1-2x pro Woche", "Mehrmals pro Woche", "Täglich"],
                        required=True,
                        order=1,
                    ),
                    Question(
                        id="exercise",
                        text="Wie oft treiben Sie Sport?",
                        type=QuestionType.single_choice,
                        options=["Nie", "Selten", "1-2x pro Woche", "3-4x pro Woche", "Täglich"],
                        required=False,
                        order=2,
                    ),
                ],
            ),
        ],
    )


def _create_checkup_anamnesis() -> AnamnesisTemplate:
    """Vorsorge-Fragebogen"""
    return AnamnesisTemplate(
        id="checkup-anamnesis",
        name="Vorsorge-Fragebogen",
        description="Fragebogen für Check-up und Vorsorgeuntersuchungen",
        appointment_types=["checkup"],
        estimated_minutes=10,
        is_active=True,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
        sections=[
            QuestionSection(
                id="general_health",
                title="Allgemeiner Gesundheitszustand",
                order=0,
                questions=[
                    Question(
                        id="health_rating",
                        text="Wie würden Sie Ihren allgemeinen Gesundheitszustand einschätzen?",
                        type=QuestionType.single_choice,
                        options=["Sehr gut", "Gut", "Befriedigend", "Weniger gut", "Schlecht"],
                        required=True,
                        order=0,
                    ),
                    Question(
                        id="new_symptoms",
                        text="Sind seit der letzten Untersuchung neue Beschwerden aufgetreten?",
                        type=QuestionType.textarea,
                        required=False,
                        order=1,
                    ),
                    Question(
                        id="weight_change",
                        text="Hat sich Ihr Gewicht in den letzten 6 Monaten verändert?",
                        type=QuestionType.single_choice,
                        options=["Nein", "Zugenommen", "Abgenommen"],
                        required=True,
                        order=2,
                    ),
                ],
            ),
            QuestionSection(
                id="screenings",
                title="Früherkennung",
                order=1,
                questions=[
                    Question(
                        id="last_checkup",
                        text="Wann war Ihre letzte Vorsorgeuntersuchung?",
                        type=QuestionType.date,
                        required=False,
                        order=0,
                    ),
                    Question(
                        id="interest_screenings",
                        text="Welche Vorsorgeuntersuchungen interessieren Sie?",
                        type=QuestionType.multiple_choice,
                        options=[
                            "Hautkrebsscreening",
                            "Darmkrebsvorsorge",
                            "Gesundheits-Check (ab 35)",
                            "Impfstatus-Check",
                            "Sehtest",
                            "Hörtest",
                        ],
                        required=False,
                        order=1,
                    ),
                ],
            ),
        ],
    )


# In-Memory Storage (Demo)
_templates: dict[str, AnamnesisTemplate] = {
    "general-anamnesis": _create_general_anamnesis(),
    "checkup-anamnesis": _create_checkup_anamnesis(),
}
_submissions: dict[str, AnamnesisSubmission] = {}


# =============================================================================
# ENDPOINTS
# =============================================================================

@router.get("/templates", response_model=list[AnamnesisTemplate])
async def get_templates(
    appointment_type: Optional[str] = None,
):
    """
    Listet verfügbare Anamnese-Vorlagen.
    
    Args:
        appointment_type: Optional: Filter nach Termintyp
        
    Returns:
        Liste der Vorlagen
    """
    templates = list(_templates.values())
    
    if appointment_type:
        templates = [t for t in templates if appointment_type in t.appointment_types]
    
    return [t for t in templates if t.is_active]


@router.get("/templates/{template_id}", response_model=AnamnesisTemplate)
async def get_template(template_id: str):
    """Holt eine spezifische Vorlage."""
    if template_id not in _templates:
        raise HTTPException(status_code=404, detail="Template not found")
    return _templates[template_id]


@router.post("/submit", response_model=AnamnesisSubmission)
async def submit_anamnesis(
    request: SubmitAnamnesisRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Reicht einen ausgefüllten Anamnese-Bogen ein.
    
    Args:
        request: Ausgefüllte Antworten
        
    Returns:
        Gespeicherte Einreichung
    """
    if request.template_id not in _templates:
        raise HTTPException(status_code=404, detail="Template not found")
    
    template = _templates[request.template_id]
    
    # Validiere Pflichtfelder
    required_ids = set()
    for section in template.sections:
        for q in section.questions:
            if q.required:
                required_ids.add(q.id)
    
    answered_ids = {a.question_id for a in request.answers}
    missing = required_ids - answered_ids
    
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"Missing required answers: {', '.join(missing)}",
        )
    
    submission_id = str(uuid.uuid4())
    submission = AnamnesisSubmission(
        id=submission_id,
        template_id=request.template_id,
        patient_id=str(current_user.id),
        appointment_id=request.appointment_id,
        answers=request.answers,
        submitted_at=datetime.now(timezone.utc),
    )
    
    _submissions[submission_id] = submission
    return submission


@router.get("/my-submissions", response_model=list[AnamnesisSubmission])
async def get_my_submissions(
    current_user: User = Depends(get_current_user),
):
    """Holt alle eigenen Anamnese-Einreichungen."""
    patient_id = str(current_user.id)
    return [s for s in _submissions.values() if s.patient_id == patient_id]


@router.get("/submission/{submission_id}", response_model=AnamnesisSubmission)
async def get_submission(
    submission_id: str,
    current_user: User = Depends(get_current_user),
):
    """Holt eine spezifische Einreichung."""
    if submission_id not in _submissions:
        raise HTTPException(status_code=404, detail="Submission not found")
    
    submission = _submissions[submission_id]
    if submission.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return submission


@router.get("/for-appointment/{appointment_id}", response_model=Optional[AnamnesisSubmission])
async def get_anamnesis_for_appointment(
    appointment_id: str,
    current_user: User = Depends(get_current_user),
):
    """Holt Anamnese für einen Termin (falls vorhanden)."""
    patient_id = str(current_user.id)
    
    for submission in _submissions.values():
        if submission.appointment_id == appointment_id and submission.patient_id == patient_id:
            return submission
    
    return None
