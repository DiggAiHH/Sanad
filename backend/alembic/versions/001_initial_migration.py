"""Initial migration - Create all tables.

Revision ID: 001_initial
Revises: 
Create Date: 2025-01-12 10:00:00.000000

"""
from typing import Sequence, Union
import uuid

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '001_initial'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create ENUM types
    op.execute("CREATE TYPE userrole AS ENUM ('admin', 'doctor', 'mfa', 'staff', 'patient')")
    op.execute("CREATE TYPE ticketstatus AS ENUM ('waiting', 'called', 'in_progress', 'completed', 'cancelled', 'no_show')")
    op.execute("CREATE TYPE ticketpriority AS ENUM ('normal', 'high', 'emergency')")
    op.execute("CREATE TYPE taskstatus AS ENUM ('todo', 'in_progress', 'completed', 'cancelled')")
    op.execute("CREATE TYPE taskpriority AS ENUM ('low', 'medium', 'high', 'urgent')")

    # Users table
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('email', sa.String(255), unique=True, nullable=False, index=True),
        sa.Column('hashed_password', sa.String(255), nullable=False),
        sa.Column('first_name', sa.String(100), nullable=False),
        sa.Column('last_name', sa.String(100), nullable=False),
        sa.Column('role', postgresql.ENUM('admin', 'doctor', 'mfa', 'staff', 'patient', name='userrole'), nullable=False, server_default='patient'),
        sa.Column('phone', sa.String(50), nullable=True),
        sa.Column('avatar_url', sa.String(500), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('is_verified', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('last_login', sa.DateTime(), nullable=True),
    )

    # Practices table
    op.create_table(
        'practices',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('address', sa.Text(), nullable=False),
        sa.Column('phone', sa.String(50), nullable=False),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('opening_hours', sa.Text(), nullable=True),
        sa.Column('max_daily_tickets', sa.Integer(), nullable=False, server_default='100'),
        sa.Column('average_wait_time_minutes', sa.Integer(), nullable=False, server_default='15'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
    )

    # Queues table
    op.create_table(
        'queues',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('practice_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('practices.id'), nullable=False),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('current_number', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('prefix', sa.String(10), nullable=False, server_default="'A'"),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
    )

    # Tickets table
    op.create_table(
        'tickets',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('queue_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('queues.id'), nullable=False),
        sa.Column('ticket_number', sa.String(20), nullable=False, index=True),
        sa.Column('patient_name', sa.String(200), nullable=True),
        sa.Column('patient_phone', sa.String(50), nullable=True),
        sa.Column('status', postgresql.ENUM('waiting', 'called', 'in_progress', 'completed', 'cancelled', 'no_show', name='ticketstatus'), nullable=False, server_default='waiting'),
        sa.Column('priority', postgresql.ENUM('normal', 'high', 'emergency', name='ticketpriority'), nullable=False, server_default='normal'),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('assigned_to_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('created_by_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('called_at', sa.DateTime(), nullable=True),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
    )

    # Tasks table
    op.create_table(
        'tasks',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('practice_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('practices.id'), nullable=False),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('status', postgresql.ENUM('todo', 'in_progress', 'completed', 'cancelled', name='taskstatus'), nullable=False, server_default='todo'),
        sa.Column('priority', postgresql.ENUM('low', 'medium', 'high', 'urgent', name='taskpriority'), nullable=False, server_default='medium'),
        sa.Column('assignee_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('due_date', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
    )

    # Chat rooms table
    op.create_table(
        'chat_rooms',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('practice_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('practices.id'), nullable=False),
        sa.Column('name', sa.String(200), nullable=False),
        sa.Column('is_group', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
    )

    # Chat participants table
    op.create_table(
        'chat_participants',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('room_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('chat_rooms.id'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('joined_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('last_read_at', sa.DateTime(), nullable=True),
    )

    # Chat messages table
    op.create_table(
        'chat_messages',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('room_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('chat_rooms.id'), nullable=False),
        sa.Column('sender_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('message_type', sa.String(50), nullable=False, server_default="'text'"),
        sa.Column('is_read', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
    )

    # Create indexes
    op.create_index('ix_tickets_queue_status', 'tickets', ['queue_id', 'status'])
    op.create_index('ix_tasks_assignee_status', 'tasks', ['assignee_id', 'status'])
    op.create_index('ix_chat_messages_room_created', 'chat_messages', ['room_id', 'created_at'])


def downgrade() -> None:
    # Drop tables in reverse order
    op.drop_index('ix_chat_messages_room_created')
    op.drop_index('ix_tasks_assignee_status')
    op.drop_index('ix_tickets_queue_status')
    
    op.drop_table('chat_messages')
    op.drop_table('chat_participants')
    op.drop_table('chat_rooms')
    op.drop_table('tasks')
    op.drop_table('tickets')
    op.drop_table('queues')
    op.drop_table('practices')
    op.drop_table('users')
    
    # Drop ENUM types
    op.execute('DROP TYPE IF EXISTS taskpriority')
    op.execute('DROP TYPE IF EXISTS taskstatus')
    op.execute('DROP TYPE IF EXISTS ticketpriority')
    op.execute('DROP TYPE IF EXISTS ticketstatus')
    op.execute('DROP TYPE IF EXISTS userrole')
