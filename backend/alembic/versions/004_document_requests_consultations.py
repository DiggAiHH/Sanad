"""Add document requests and patient consultations

Revision ID: 004_document_requests_consultations
Revises: 003_add_practice_website
Create Date: 2026-01-23

DSGVO-compliant: Auto-deletion columns included.
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers
revision = "004_document_requests_consultations"
down_revision = "003_add_practice_website"
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Create document_requests and patient_consultations tables."""
    
    # Document Types Enum
    document_type_enum = postgresql.ENUM(
        'rezept', 'ueberweisung', 'au_bescheinigung', 
        'bescheinigung', 'befund', 'attest', 'sonstige',
        name='documenttype',
        create_type=True
    )
    
    document_status_enum = postgresql.ENUM(
        'pending', 'in_review', 'approved', 'ready', 
        'delivered', 'rejected', 'cancelled',
        name='documentrequeststatus',
        create_type=True
    )
    
    document_priority_enum = postgresql.ENUM(
        'normal', 'urgent', 'express',
        name='documentrequestpriority',
        create_type=True
    )
    
    delivery_method_enum = postgresql.ENUM(
        'pickup', 'email', 'post', 'digital_health',
        name='deliverymethod',
        create_type=True
    )
    
    # Consultation Enums
    consultation_type_enum = postgresql.ENUM(
        'video_call', 'voice_call', 'chat', 'callback_request',
        name='consultationtype',
        create_type=True
    )
    
    consultation_status_enum = postgresql.ENUM(
        'requested', 'scheduled', 'waiting', 'in_progress',
        'completed', 'cancelled', 'no_show', 'technical_error',
        name='consultationstatus',
        create_type=True
    )
    
    consultation_priority_enum = postgresql.ENUM(
        'routine', 'same_day', 'urgent', 'emergency',
        name='consultationpriority',
        create_type=True
    )
    
    # Create enums
    document_type_enum.create(op.get_bind(), checkfirst=True)
    document_status_enum.create(op.get_bind(), checkfirst=True)
    document_priority_enum.create(op.get_bind(), checkfirst=True)
    delivery_method_enum.create(op.get_bind(), checkfirst=True)
    consultation_type_enum.create(op.get_bind(), checkfirst=True)
    consultation_status_enum.create(op.get_bind(), checkfirst=True)
    consultation_priority_enum.create(op.get_bind(), checkfirst=True)
    
    # Document Requests Table
    op.create_table(
        'document_requests',
        sa.Column('id', sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column('practice_id', sa.Uuid(as_uuid=True), 
                  sa.ForeignKey('practices.id'), nullable=False),
        sa.Column('patient_id', sa.Uuid(as_uuid=True), 
                  sa.ForeignKey('users.id'), nullable=False, index=True),
        
        # Document details
        sa.Column('document_type', document_type_enum, nullable=False),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text, nullable=True),
        
        # Rezept fields
        sa.Column('medication_name', sa.String(255), nullable=True),
        sa.Column('medication_dosage', sa.String(100), nullable=True),
        sa.Column('medication_quantity', sa.Integer, nullable=True),
        
        # Überweisung fields
        sa.Column('referral_specialty', sa.String(100), nullable=True),
        sa.Column('referral_reason', sa.Text, nullable=True),
        
        # AU fields
        sa.Column('au_start_date', sa.DateTime, nullable=True),
        sa.Column('au_end_date', sa.DateTime, nullable=True),
        sa.Column('au_reason', sa.Text, nullable=True),
        
        # Status
        sa.Column('status', document_status_enum, 
                  nullable=False, default='pending'),
        sa.Column('priority', document_priority_enum,
                  nullable=False, default='normal'),
        sa.Column('delivery_method', delivery_method_enum,
                  nullable=False, default='pickup'),
        
        # Assignment
        sa.Column('assigned_to_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('users.id'), nullable=True),
        
        # Rejection/Notes
        sa.Column('rejection_reason', sa.Text, nullable=True),
        sa.Column('internal_notes', sa.Text, nullable=True),
        sa.Column('document_file_url', sa.String(500), nullable=True),
        
        # Timestamps
        sa.Column('created_at', sa.DateTime, 
                  nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime,
                  nullable=False, server_default=sa.func.now(),
                  onupdate=sa.func.now()),
        sa.Column('processed_at', sa.DateTime, nullable=True),
        sa.Column('ready_at', sa.DateTime, nullable=True),
        sa.Column('delivered_at', sa.DateTime, nullable=True),
        
        # DSGVO
        sa.Column('deletion_scheduled_at', sa.DateTime, nullable=True),
    )
    
    # Patient Consultations Table
    op.create_table(
        'patient_consultations',
        sa.Column('id', sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column('practice_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('practices.id'), nullable=False),
        sa.Column('patient_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('users.id'), nullable=False, index=True),
        sa.Column('doctor_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('users.id'), nullable=True),
        
        # Consultation details
        sa.Column('consultation_type', consultation_type_enum, nullable=False),
        sa.Column('priority', consultation_priority_enum,
                  nullable=False, default='routine'),
        sa.Column('status', consultation_status_enum,
                  nullable=False, default='requested'),
        
        # Topic
        sa.Column('subject', sa.String(255), nullable=False),
        sa.Column('description', sa.Text, nullable=True),
        sa.Column('symptoms', sa.Text, nullable=True),
        
        # Scheduling
        sa.Column('scheduled_at', sa.DateTime, nullable=True),
        sa.Column('scheduled_duration_minutes', sa.Integer, 
                  nullable=False, default=15),
        
        # Call session
        sa.Column('room_id', sa.String(100), nullable=True),
        sa.Column('call_started_at', sa.DateTime, nullable=True),
        sa.Column('call_ended_at', sa.DateTime, nullable=True),
        sa.Column('actual_duration_seconds', sa.Integer, nullable=True),
        
        # Recording consent (DSGVO)
        sa.Column('recording_consent', sa.Boolean, 
                  nullable=False, default=False),
        sa.Column('recording_url', sa.String(500), nullable=True),
        
        # Quality
        sa.Column('connection_quality', sa.String(20), nullable=True),
        sa.Column('patient_rating', sa.Integer, nullable=True),
        
        # Follow-up
        sa.Column('follow_up_required', sa.Boolean,
                  nullable=False, default=False),
        sa.Column('follow_up_notes', sa.Text, nullable=True),
        
        # Linked ticket
        sa.Column('ticket_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('tickets.id'), nullable=True),
        
        # Timestamps
        sa.Column('created_at', sa.DateTime,
                  nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime,
                  nullable=False, server_default=sa.func.now(),
                  onupdate=sa.func.now()),
        
        # DSGVO
        sa.Column('deletion_scheduled_at', sa.DateTime, nullable=True),
    )
    
    # Patient Consultation Messages Table
    op.create_table(
        'patient_consultation_messages',
        sa.Column('id', sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column('consultation_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('patient_consultations.id'), 
                  nullable=False, index=True),
        sa.Column('sender_id', sa.Uuid(as_uuid=True),
                  sa.ForeignKey('users.id'), nullable=False),
        
        # Content
        sa.Column('content', sa.Text, nullable=False),
        sa.Column('is_read', sa.Boolean, nullable=False, default=False),
        
        # Attachments
        sa.Column('attachment_url', sa.String(500), nullable=True),
        sa.Column('attachment_type', sa.String(50), nullable=True),
        
        # Timestamps
        sa.Column('created_at', sa.DateTime,
                  nullable=False, server_default=sa.func.now()),
        sa.Column('read_at', sa.DateTime, nullable=True),
    )
    
    # Create indexes for performance
    op.create_index(
        'ix_document_requests_status',
        'document_requests',
        ['status']
    )
    op.create_index(
        'ix_document_requests_document_type',
        'document_requests',
        ['document_type']
    )
    op.create_index(
        'ix_patient_consultations_status',
        'patient_consultations',
        ['status']
    )
    op.create_index(
        'ix_patient_consultations_scheduled_at',
        'patient_consultations',
        ['scheduled_at']
    )


def downgrade() -> None:
    """Drop document_requests and patient_consultations tables."""
    
    # Drop indexes
    op.drop_index('ix_patient_consultations_scheduled_at')
    op.drop_index('ix_patient_consultations_status')
    op.drop_index('ix_document_requests_document_type')
    op.drop_index('ix_document_requests_status')
    
    # Drop tables
    op.drop_table('patient_consultation_messages')
    op.drop_table('patient_consultations')
    op.drop_table('document_requests')
    
    # Drop enums
    op.execute("DROP TYPE IF EXISTS consultationpriority")
    op.execute("DROP TYPE IF EXISTS consultationstatus")
    op.execute("DROP TYPE IF EXISTS consultationtype")
    op.execute("DROP TYPE IF EXISTS deliverymethod")
    op.execute("DROP TYPE IF EXISTS documentrequestpriority")
    op.execute("DROP TYPE IF EXISTS documentrequeststatus")
    op.execute("DROP TYPE IF EXISTS documenttype")
