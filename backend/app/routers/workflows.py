"""
Workflow Automation / Automatisierte Praxis-Abläufe
===================================================
Automatisiert wiederkehrende Aufgaben und Benachrichtigungen.
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, date, timedelta, timezone
from typing import Optional, Any
from enum import Enum
import uuid
import logging

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel

router = APIRouter(prefix="/workflows", tags=["Workflow Automation"])
logger = logging.getLogger(__name__)


# =============================================================================
# SCHEMAS
# =============================================================================

class TriggerType(str, Enum):
    """Auslöser für Workflows"""
    appointment_booked = "appointment_booked"
    appointment_reminder = "appointment_reminder"
    appointment_missed = "appointment_missed"
    lab_result_ready = "lab_result_ready"
    prescription_due = "prescription_due"
    vaccination_due = "vaccination_due"
    checkup_reminder = "checkup_reminder"
    document_ready = "document_ready"
    birthday = "birthday"
    manual = "manual"


class ActionType(str, Enum):
    """Aktionen die ausgeführt werden können"""
    send_email = "send_email"
    send_sms = "send_sms"
    send_push = "send_push"
    create_task = "create_task"
    update_record = "update_record"
    generate_document = "generate_document"
    webhook = "webhook"


class WorkflowStatus(str, Enum):
    """Status eines Workflows"""
    active = "active"
    paused = "paused"
    disabled = "disabled"


class WorkflowAction(BaseModel):
    """Einzelne Aktion in einem Workflow"""
    id: str
    type: ActionType
    config: dict
    delay_minutes: int = 0
    condition: Optional[str] = None


class Workflow(BaseModel):
    """Workflow-Definition"""
    id: str
    name: str
    description: str
    trigger: TriggerType
    trigger_config: dict[str, Any] = {}
    actions: list[WorkflowAction]
    status: WorkflowStatus = WorkflowStatus.active
    created_at: datetime
    updated_at: datetime
    run_count: int = 0
    last_run: Optional[datetime] = None


class WorkflowRun(BaseModel):
    """Einzelne Workflow-Ausführung"""
    id: str
    workflow_id: str
    trigger_data: dict
    started_at: datetime
    completed_at: Optional[datetime] = None
    status: str  # running, completed, failed
    actions_completed: int = 0
    error: Optional[str] = None


class TaskPriority(str, Enum):
    """Aufgaben-Priorität"""
    low = "low"
    medium = "medium"
    high = "high"
    urgent = "urgent"


class PracticeTask(BaseModel):
    """Praxis-Aufgabe (automatisch oder manuell erstellt)"""
    id: str
    title: str
    description: Optional[str] = None
    patient_id: Optional[str] = None
    assigned_to: Optional[str] = None
    priority: TaskPriority = TaskPriority.medium
    due_date: Optional[date] = None
    completed: bool = False
    completed_at: Optional[datetime] = None
    created_by: str
    created_at: datetime
    workflow_run_id: Optional[str] = None  # Falls durch Workflow erstellt


# =============================================================================
# VORDEFINIERTE WORKFLOWS
# =============================================================================

PREDEFINED_WORKFLOWS = [
    Workflow(
        id="wf-appointment-reminder-24h",
        name="Termin-Erinnerung (24h vorher)",
        description="Sendet automatisch Push/E-Mail 24 Stunden vor dem Termin",
        trigger=TriggerType.appointment_reminder,
        trigger_config={"hours_before": 24},
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_push,
                config={
                    "title": "Termin-Erinnerung",
                    "body": "Ihr Termin morgen um {time} Uhr",
                },
            ),
            WorkflowAction(
                id="a2",
                type=ActionType.send_email,
                config={
                    "template": "appointment_reminder",
                },
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=156,
    ),
    Workflow(
        id="wf-appointment-reminder-2h",
        name="Termin-Erinnerung (2h vorher)",
        description="Kurze Push-Erinnerung 2 Stunden vor dem Termin",
        trigger=TriggerType.appointment_reminder,
        trigger_config={"hours_before": 2},
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_push,
                config={
                    "title": "Bald Termin!",
                    "body": "Ihr Termin beginnt in 2 Stunden",
                },
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=142,
    ),
    Workflow(
        id="wf-lab-result-notification",
        name="Befund-Benachrichtigung",
        description="Informiert Patienten wenn Laborbefunde freigegeben werden",
        trigger=TriggerType.lab_result_ready,
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_push,
                config={
                    "title": "Neue Laborergebnisse",
                    "body": "Ihre Laborergebnisse sind jetzt verfügbar",
                },
            ),
            WorkflowAction(
                id="a2",
                type=ActionType.send_email,
                config={
                    "template": "lab_result_ready",
                },
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=45,
    ),
    Workflow(
        id="wf-vaccination-recall",
        name="Impf-Recall",
        description="Erinnert an fällige Impfungen (STIKO-Empfehlungen)",
        trigger=TriggerType.vaccination_due,
        trigger_config={"days_before": 14},
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_push,
                config={
                    "title": "Impf-Erinnerung",
                    "body": "Ihre {vaccine_name}-Impfung ist bald fällig",
                },
            ),
            WorkflowAction(
                id="a2",
                type=ActionType.create_task,
                config={
                    "title": "Impf-Recall: {patient_name}",
                    "priority": "medium",
                },
                delay_minutes=1440,  # 24h später Task für MFA
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=28,
    ),
    Workflow(
        id="wf-checkup-reminder",
        name="Vorsorge-Erinnerung (jährlich)",
        description="Erinnert an jährliche Vorsorgeuntersuchung",
        trigger=TriggerType.checkup_reminder,
        trigger_config={"months_since_last": 12},
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_email,
                config={
                    "template": "checkup_reminder",
                },
            ),
            WorkflowAction(
                id="a2",
                type=ActionType.send_push,
                config={
                    "title": "Zeit für Vorsorge",
                    "body": "Ihre letzte Vorsorge ist über ein Jahr her",
                },
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=89,
    ),
    Workflow(
        id="wf-no-show-followup",
        name="Nicht-Erschienen Nachverfolgung",
        description="Erstellt Aufgabe wenn Patient nicht zum Termin erscheint",
        trigger=TriggerType.appointment_missed,
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.create_task,
                config={
                    "title": "Anruf: Patient nicht erschienen",
                    "description": "Patient {patient_name} nicht zum Termin am {date} erschienen. Bitte nachfassen.",
                    "priority": "high",
                },
            ),
            WorkflowAction(
                id="a2",
                type=ActionType.send_sms,
                config={
                    "template": "missed_appointment",
                },
                delay_minutes=60,  # 1h später SMS
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=12,
    ),
    Workflow(
        id="wf-prescription-refill",
        name="Rezept-Nachbestellung",
        description="Erinnert wenn Dauermedikation bald aufgebraucht",
        trigger=TriggerType.prescription_due,
        trigger_config={"days_before": 7},
        actions=[
            WorkflowAction(
                id="a1",
                type=ActionType.send_push,
                config={
                    "title": "Rezept bald nötig",
                    "body": "Ihr Medikament {medication_name} ist bald aufgebraucht",
                },
            ),
        ],
        status=WorkflowStatus.active,
        created_at=datetime(2024, 1, 1),
        updated_at=datetime(2024, 1, 1),
        run_count=67,
    ),
]

_workflows: dict[str, Workflow] = {w.id: w for w in PREDEFINED_WORKFLOWS}
_tasks: dict[str, PracticeTask] = {}
_runs: dict[str, WorkflowRun] = {}


# =============================================================================
# WORKFLOW ENDPOINTS
# =============================================================================

@router.get("/", response_model=list[Workflow])
async def list_workflows(
    status: Optional[WorkflowStatus] = None,
    trigger: Optional[TriggerType] = None,
):
    """
    Listet alle konfigurierten Workflows.
    """
    workflows = list(_workflows.values())
    
    if status:
        workflows = [w for w in workflows if w.status == status]
    if trigger:
        workflows = [w for w in workflows if w.trigger == trigger]
    
    return workflows


@router.get("/{workflow_id}", response_model=Workflow)
async def get_workflow(workflow_id: str):
    """Holt Details eines Workflows."""
    if workflow_id not in _workflows:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return _workflows[workflow_id]


@router.put("/{workflow_id}/status")
async def update_workflow_status(
    workflow_id: str,
    status: WorkflowStatus,
    current_user: User = Depends(get_current_user),
):
    """Aktiviert/Deaktiviert einen Workflow."""
    if workflow_id not in _workflows:
        raise HTTPException(status_code=404, detail="Workflow not found")
    
    workflow = _workflows[workflow_id]
    workflow.status = status
    workflow.updated_at = datetime.now(timezone.utc)
    
    return {"status": "updated", "new_status": status}


@router.post("/{workflow_id}/trigger")
async def manual_trigger_workflow(
    workflow_id: str,
    trigger_data: dict[str, Any],
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
):
    """
    Löst einen Workflow manuell aus (für Tests).
    """
    if workflow_id not in _workflows:
        raise HTTPException(status_code=404, detail="Workflow not found")
    
    workflow = _workflows[workflow_id]
    
    run_id = str(uuid.uuid4())
    run = WorkflowRun(
        id=run_id,
        workflow_id=workflow_id,
        trigger_data=trigger_data,
        started_at=datetime.now(timezone.utc),
        status="running",
    )
    _runs[run_id] = run
    
    # Execute in background
    background_tasks.add_task(_execute_workflow, workflow, run, trigger_data)
    
    return {"run_id": run_id, "status": "triggered"}


async def _execute_workflow(workflow: Workflow, run: WorkflowRun, data: dict[str, Any]):
    """Führt Workflow-Aktionen aus."""
    try:
        for action in workflow.actions:
            logger.info(f"Executing action {action.id}: {action.type}")
            
            # TODO: Echte Aktionen implementieren
            # await _execute_action(action, data)
            
            run.actions_completed += 1
        
        run.status = "completed"
        run.completed_at = datetime.now(timezone.utc)
        
        workflow.run_count += 1
        workflow.last_run = datetime.now(timezone.utc)
        
    except Exception as e:
        logger.error(f"Workflow {workflow.id} failed: {e}")
        run.status = "failed"
        run.error = str(e)


# =============================================================================
# TASK ENDPOINTS
# =============================================================================

@router.get("/tasks/", response_model=list[PracticeTask])
async def list_tasks(
    assigned_to: Optional[str] = None,
    completed: Optional[bool] = None,
    priority: Optional[TaskPriority] = None,
    current_user: User = Depends(get_current_user),
):
    """
    Listet Praxis-Aufgaben.
    """
    tasks = list(_tasks.values())
    
    if assigned_to:
        tasks = [t for t in tasks if t.assigned_to == assigned_to]
    if completed is not None:
        tasks = [t for t in tasks if t.completed == completed]
    if priority:
        tasks = [t for t in tasks if t.priority == priority]
    
    return sorted(tasks, key=lambda x: (x.completed, x.due_date or date.max))


@router.post("/tasks/", response_model=PracticeTask)
async def create_task(
    title: str,
    description: Optional[str] = None,
    patient_id: Optional[str] = None,
    assigned_to: Optional[str] = None,
    priority: TaskPriority = TaskPriority.medium,
    due_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
):
    """Erstellt eine neue Aufgabe."""
    task_id = str(uuid.uuid4())
    
    task = PracticeTask(
        id=task_id,
        title=title,
        description=description,
        patient_id=patient_id,
        assigned_to=assigned_to,
        priority=priority,
        due_date=due_date,
        created_by=str(current_user.id),
        created_at=datetime.now(timezone.utc),
    )
    
    _tasks[task_id] = task
    return task


@router.put("/tasks/{task_id}/complete")
async def complete_task(
    task_id: str,
    current_user: User = Depends(get_current_user),
):
    """Markiert eine Aufgabe als erledigt."""
    if task_id not in _tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    
    task = _tasks[task_id]
    task.completed = True
    task.completed_at = datetime.now(timezone.utc)
    
    return {"status": "completed"}


# =============================================================================
# SCHEDULER ENDPOINTS (für Cron-Jobs)
# =============================================================================

@router.post("/scheduler/run-due")
async def run_due_workflows(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
):
    """
    [INTERNAL] Führt alle fälligen automatischen Workflows aus.
    Sollte von einem Scheduler (Cron) aufgerufen werden.
    """
    triggered = []
    
    # Beispiel: Termin-Erinnerungen prüfen
    # TODO: Echte Termin-Daten aus DB holen
    
    return {
        "checked_at": datetime.now(timezone.utc),
        "workflows_triggered": len(triggered),
        "details": triggered,
    }
