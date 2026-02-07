"""
Privacy & DSGVO Compliance Router
=================================
Art. 7:  Einwilligung
Art. 17: Recht auf Löschung
Art. 20: Datenportabilität
Art. 30: Audit-Log

SECURITY: Alle Endpunkte erfordern Authentifizierung.
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timedelta, timezone
from typing import Optional, Any
from enum import Enum
import uuid

from ..database import get_db
from ..dependencies import get_current_user
from ..models.models import User
from pydantic import BaseModel, Field

router = APIRouter(prefix="/privacy", tags=["Privacy & DSGVO"])


# =============================================================================
# SCHEMAS
# =============================================================================

class ConsentCategory(str, Enum):
    essential = "essential"
    medical_data = "medical_data"
    telemedicine = "telemedicine"
    push_notifications = "push_notifications"
    analytics = "analytics"
    third_party_sharing = "third_party_sharing"
    marketing = "marketing"


class ConsentRequest(BaseModel):
    category: ConsentCategory
    granted: bool
    version: str = "1.0"


class ConsentRecord(BaseModel):
    id: str
    patient_id: str
    category: ConsentCategory
    granted: bool
    timestamp: datetime
    version: str
    ip_address: Optional[str] = None
    revoked_at: Optional[datetime] = None
    revoke_reason: Optional[str] = None


class PatientConsents(BaseModel):
    patient_id: str
    consents: list[ConsentRecord]
    last_updated: datetime


class DataExportFormat(str, Enum):
    json = "json"
    pdf = "pdf"
    xml = "xml"
    fhir = "fhir"


class DataExportStatus(str, Enum):
    pending = "pending"
    processing = "processing"
    ready = "ready"
    downloaded = "downloaded"
    expired = "expired"
    failed = "failed"


class DataExportRequest(BaseModel):
    format: DataExportFormat = DataExportFormat.json


class DataExportResponse(BaseModel):
    id: str
    patient_id: str
    format: DataExportFormat
    status: DataExportStatus
    requested_at: datetime
    completed_at: Optional[datetime] = None
    download_url: Optional[str] = None
    expires_at: Optional[datetime] = None


class DataDeletionStatus(str, Enum):
    pending = "pending"
    approved = "approved"
    scheduled = "scheduled"
    completed = "completed"
    rejected = "rejected"


class DataDeletionRequest(BaseModel):
    reason: str = Field(..., min_length=10, max_length=1000)


class DataDeletionResponse(BaseModel):
    id: str
    patient_id: str
    status: DataDeletionStatus
    requested_at: datetime
    reason: str
    scheduled_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None


class PrivacyAuditAction(str, Enum):
    consent_granted = "consent_granted"
    consent_revoked = "consent_revoked"
    data_accessed = "data_accessed"
    data_exported = "data_exported"
    data_deleted = "data_deleted"
    data_modified = "data_modified"
    login_attempt = "login_attempt"
    password_changed = "password_changed"


class PrivacyAuditLog(BaseModel):
    id: str
    patient_id: str
    action: PrivacyAuditAction
    timestamp: datetime
    actor_id: str
    actor_type: str
    details: Optional[dict[str, Any]] = None
    ip_address: Optional[str] = None


# =============================================================================
# IN-MEMORY STORAGE (für Demo - in Produktion: PostgreSQL)
# =============================================================================

# WARNUNG: Dies ist nur für Demo-Zwecke. In Produktion SQLAlchemy Models verwenden!
_consents: dict[str, list[ConsentRecord]] = {}
_exports: dict[str, DataExportResponse] = {}
_deletions: dict[str, DataDeletionResponse] = {}
_audit_logs: dict[str, list[PrivacyAuditLog]] = {}


def _log_audit(
    patient_id: str,
    action: PrivacyAuditAction,
    actor_id: str,
    actor_type: str = "patient",
    details: Optional[dict[str, Any]] = None,
    ip_address: Optional[str] = None,
) -> PrivacyAuditLog:
    """Erstellt Audit-Log-Eintrag."""
    log = PrivacyAuditLog(
        id=str(uuid.uuid4()),
        patient_id=patient_id,
        action=action,
        timestamp=datetime.now(timezone.utc),
        actor_id=actor_id,
        actor_type=actor_type,
        details=details,
        ip_address=ip_address,
    )
    if patient_id not in _audit_logs:
        _audit_logs[patient_id] = []
    _audit_logs[patient_id].append(log)
    return log


# =============================================================================
# CONSENT ENDPOINTS (Art. 7 DSGVO)
# =============================================================================

@router.get("/consents", response_model=PatientConsents)
async def get_consents(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Holt alle Einwilligungen des aktuellen Benutzers.
    
    Returns:
        PatientConsents: Alle Einwilligungen mit Zeitstempeln
    """
    patient_id = str(current_user.id)
    consents = _consents.get(patient_id, [])
    
    return PatientConsents(
        patient_id=patient_id,
        consents=consents,
        last_updated=datetime.now(timezone.utc),
    )


@router.post("/consents", response_model=ConsentRecord)
async def update_consent(
    request: ConsentRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Erteilt oder aktualisiert eine Einwilligung.
    
    Args:
        request: Einwilligungsanfrage mit Kategorie und Status
        
    Returns:
        ConsentRecord: Gespeicherte Einwilligung
    """
    patient_id = str(current_user.id)
    
    record = ConsentRecord(
        id=str(uuid.uuid4()),
        patient_id=patient_id,
        category=request.category,
        granted=request.granted,
        timestamp=datetime.now(timezone.utc),
        version=request.version,
    )
    
    if patient_id not in _consents:
        _consents[patient_id] = []
    _consents[patient_id].append(record)
    
    # Audit-Log
    _log_audit(
        patient_id=patient_id,
        action=PrivacyAuditAction.consent_granted if request.granted else PrivacyAuditAction.consent_revoked,
        actor_id=patient_id,
        details={"category": request.category.value, "granted": request.granted},
    )
    
    return record


@router.delete("/consents/{category}", response_model=ConsentRecord)
async def revoke_consent(
    category: ConsentCategory,
    reason: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Widerruft eine Einwilligung (Art. 7 Abs. 3 DSGVO).
    
    Der Widerruf muss so einfach sein wie die Erteilung.
    
    Args:
        category: Kategorie der zu widerrufenden Einwilligung
        reason: Optionaler Grund für den Widerruf
        
    Returns:
        ConsentRecord: Widerrufene Einwilligung
    """
    patient_id = str(current_user.id)
    
    # Essential consent kann nicht widerrufen werden
    if category == ConsentCategory.essential:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Essential consent cannot be revoked. Delete your account instead.",
        )
    
    record = ConsentRecord(
        id=str(uuid.uuid4()),
        patient_id=patient_id,
        category=category,
        granted=False,
        timestamp=datetime.now(timezone.utc),
        version="revoked",
        revoked_at=datetime.now(timezone.utc),
        revoke_reason=reason,
    )
    
    if patient_id not in _consents:
        _consents[patient_id] = []
    _consents[patient_id].append(record)
    
    # Audit-Log
    _log_audit(
        patient_id=patient_id,
        action=PrivacyAuditAction.consent_revoked,
        actor_id=patient_id,
        details={"category": category.value, "reason": reason},
    )
    
    return record


# =============================================================================
# DATA EXPORT ENDPOINTS (Art. 20 DSGVO - Datenportabilität)
# =============================================================================

@router.post("/export", response_model=DataExportResponse)
async def request_data_export(
    request: DataExportRequest,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Fordert Datenexport an (Art. 20 DSGVO).
    
    Der Export wird asynchron erstellt und kann später abgerufen werden.
    
    Args:
        request: Export-Format (JSON, PDF, XML, FHIR)
        
    Returns:
        DataExportResponse: Export-Anfrage mit ID zum Statusabruf
    """
    patient_id = str(current_user.id)
    export_id = str(uuid.uuid4())
    
    export = DataExportResponse(
        id=export_id,
        patient_id=patient_id,
        format=request.format,
        status=DataExportStatus.pending,
        requested_at=datetime.now(timezone.utc),
    )
    
    _exports[export_id] = export
    
    # Hintergrund-Task für Export-Erstellung
    background_tasks.add_task(_process_export, export_id, patient_id, request.format)
    
    # Audit-Log
    _log_audit(
        patient_id=patient_id,
        action=PrivacyAuditAction.data_exported,
        actor_id=patient_id,
        details={"format": request.format.value, "export_id": export_id},
    )
    
    return export


async def _process_export(export_id: str, patient_id: str, format: DataExportFormat):
    """Verarbeitet Export im Hintergrund."""
    import asyncio
    await asyncio.sleep(2)  # Simuliert Verarbeitungszeit
    
    if export_id in _exports:
        old_export = _exports[export_id]
        _exports[export_id] = DataExportResponse(
            id=old_export.id,
            patient_id=old_export.patient_id,
            format=old_export.format,
            status=DataExportStatus.ready,
            requested_at=old_export.requested_at,
            completed_at=datetime.now(timezone.utc),
            download_url=f"/api/v1/privacy/export/{export_id}/download",
            expires_at=datetime.now(timezone.utc) + timedelta(days=7),
        )


@router.get("/export/{request_id}", response_model=DataExportResponse)
async def get_export_status(
    request_id: str,
    current_user: User = Depends(get_current_user),
):
    """Prüft Status eines Datenexports."""
    if request_id not in _exports:
        raise HTTPException(status_code=404, detail="Export request not found")
    
    export = _exports[request_id]
    if export.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return export


@router.get("/export/{request_id}/download")
async def download_export(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Lädt exportierte Daten herunter.
    
    Returns:
        JSON mit allen Patientendaten
    """
    if request_id not in _exports:
        raise HTTPException(status_code=404, detail="Export request not found")
    
    export = _exports[request_id]
    if export.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    if export.status != DataExportStatus.ready:
        raise HTTPException(status_code=400, detail="Export not ready")
    
    # Markiere als heruntergeladen
    _exports[request_id] = DataExportResponse(
        id=export.id,
        patient_id=export.patient_id,
        format=export.format,
        status=DataExportStatus.downloaded,
        requested_at=export.requested_at,
        completed_at=export.completed_at,
        download_url=export.download_url,
        expires_at=export.expires_at,
    )
    
    # Sammle alle Patientendaten (in Produktion: aus DB laden)
    patient_data: dict[str, Any] = {
        "export_date": datetime.now(timezone.utc).isoformat(),
        "patient_id": export.patient_id,
        "user": {
            "id": str(current_user.id),
            "email": current_user.email,
            "full_name": current_user.full_name,
            "created_at": current_user.created_at.isoformat() if current_user.created_at else None,
        },
        "consents": [c.model_dump() for c in _consents.get(export.patient_id, [])],
        "audit_log": [a.model_dump() for a in _audit_logs.get(export.patient_id, [])],
        # TODO: In Produktion weitere Daten hinzufügen:
        # - Tickets, Termine, Befunde, Laborwerte, etc.
    }
    
    from fastapi.responses import JSONResponse
    return JSONResponse(
        content=patient_data,
        headers={
            "Content-Disposition": f'attachment; filename="daten-export-{export.patient_id}.json"'
        },
    )


# =============================================================================
# DATA DELETION ENDPOINTS (Art. 17 DSGVO - Recht auf Löschung)
# =============================================================================

@router.post("/deletion", response_model=DataDeletionResponse)
async def request_data_deletion(
    request: DataDeletionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Fordert Datenlöschung an (Art. 17 DSGVO).
    
    WARNUNG: Diese Aktion kann nicht rückgängig gemacht werden.
    
    Ausnahmen nach Art. 17 Abs. 3:
    - Gesetzliche Aufbewahrungspflichten (10 Jahre für medizinische Daten)
    - Rechtsansprüche
    
    Args:
        request: Grund für die Löschanfrage
        
    Returns:
        DataDeletionResponse: Löschanfrage mit Status
    """
    patient_id = str(current_user.id)
    deletion_id = str(uuid.uuid4())
    
    # Löschung wird nach 30 Tagen ausgeführt (Widerrufsfrist)
    scheduled_at = datetime.now(timezone.utc) + timedelta(days=30)
    
    deletion = DataDeletionResponse(
        id=deletion_id,
        patient_id=patient_id,
        status=DataDeletionStatus.scheduled,
        requested_at=datetime.now(timezone.utc),
        reason=request.reason,
        scheduled_at=scheduled_at,
    )
    
    _deletions[deletion_id] = deletion
    
    # Audit-Log
    _log_audit(
        patient_id=patient_id,
        action=PrivacyAuditAction.data_deleted,
        actor_id=patient_id,
        details={"deletion_id": deletion_id, "reason": request.reason, "scheduled_at": scheduled_at.isoformat()},
    )
    
    return deletion


@router.get("/deletion/{request_id}", response_model=DataDeletionResponse)
async def get_deletion_status(
    request_id: str,
    current_user: User = Depends(get_current_user),
):
    """Prüft Status einer Löschanfrage."""
    if request_id not in _deletions:
        raise HTTPException(status_code=404, detail="Deletion request not found")
    
    deletion = _deletions[request_id]
    if deletion.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    return deletion


@router.delete("/deletion/{request_id}")
async def cancel_deletion_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
):
    """
    Bricht eine Löschanfrage ab.
    
    Nur möglich, solange Löschung noch nicht ausgeführt wurde.
    """
    if request_id not in _deletions:
        raise HTTPException(status_code=404, detail="Deletion request not found")
    
    deletion = _deletions[request_id]
    if deletion.patient_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Access denied")
    
    if deletion.status == DataDeletionStatus.completed:
        raise HTTPException(status_code=400, detail="Deletion already completed")
    
    del _deletions[request_id]
    return {"message": "Deletion request cancelled"}


# =============================================================================
# AUDIT LOG ENDPOINTS (Art. 30 DSGVO)
# =============================================================================

@router.get("/audit-log", response_model=list[PrivacyAuditLog])
async def get_audit_log(
    from_date: Optional[datetime] = None,
    to_date: Optional[datetime] = None,
    action: Optional[PrivacyAuditAction] = None,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
):
    """
    Holt Audit-Log für den aktuellen Benutzer.
    
    Der Audit-Log dokumentiert alle datenschutzrelevanten Aktionen.
    
    Args:
        from_date: Startdatum Filter
        to_date: Enddatum Filter
        action: Aktionstyp Filter
        limit: Maximale Anzahl Einträge
        
    Returns:
        Liste von Audit-Log-Einträgen
    """
    patient_id = str(current_user.id)
    logs = _audit_logs.get(patient_id, [])
    
    # Filter anwenden
    if from_date:
        logs = [l for l in logs if l.timestamp >= from_date]
    if to_date:
        logs = [l for l in logs if l.timestamp <= to_date]
    if action:
        logs = [l for l in logs if l.action == action]
    
    # Sortieren und limitieren
    logs = sorted(logs, key=lambda l: l.timestamp, reverse=True)[:limit]
    
    return logs
