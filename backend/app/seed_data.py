"""
Seed script for development data.

Run with: python -m app.seed_data
"""

import asyncio
import uuid
from datetime import datetime, timedelta, timezone

from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.models import (
    User, UserRole, Practice, Queue, Ticket, TicketStatus, TicketPriority,
    Task, TaskStatus, TaskPriority, ChatRoom, ChatParticipant, ChatMessage
)
from app.database import async_session_maker, engine, Base


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
settings = get_settings()


async def seed_database() -> None:
    """Create seed data for development."""
    async with async_session_maker() as db:
        # Check if data already exists
        existing_user = await db.execute(
            select(User).where(User.email == "admin@sanad.de")
        )
        if existing_user.scalar_one_or_none():
            print("✅ Seed-Daten existieren bereits, überspringe...")
            return
        
        print("🌱 Seeding database...")
        
        # Create Practice
        practice = Practice(
            id=uuid.uuid4(),
            name="Praxis Dr. Müller",
            address="Hauptstraße 42, 80331 München",
            phone="+49 89 123456",
            email="praxis@dr-mueller.de",
            opening_hours="Mo-Fr: 08:00-18:00, Sa: 09:00-12:00",
            max_daily_tickets=50,
            average_wait_time_minutes=15,
        )
        db.add(practice)
        
        # Create Users
        admin = User(
            id=uuid.uuid4(),
            email="admin@sanad.de",
            hashed_password=pwd_context.hash("Admin123!"),
            first_name="Admin",
            last_name="User",
            role=UserRole.ADMIN,
            is_verified=True,
        )
        
        doctor = User(
            id=uuid.uuid4(),
            email="arzt@sanad.de",
            hashed_password=pwd_context.hash("Arzt123!"),
            first_name="Dr. Hans",
            last_name="Müller",
            role=UserRole.DOCTOR,
            is_verified=True,
        )
        
        mfa = User(
            id=uuid.uuid4(),
            email="mfa@sanad.de",
            hashed_password=pwd_context.hash("Mfa123!"),
            first_name="Anna",
            last_name="Schmidt",
            role=UserRole.MFA,
            is_verified=True,
        )
        
        staff = User(
            id=uuid.uuid4(),
            email="staff@sanad.de",
            hashed_password=pwd_context.hash("Staff123!"),
            first_name="Peter",
            last_name="Meyer",
            role=UserRole.STAFF,
            is_verified=True,
        )
        
        patient = User(
            id=uuid.uuid4(),
            email="patient@example.de",
            hashed_password=pwd_context.hash("Patient123!"),
            first_name="Max",
            last_name="Mustermann",
            role=UserRole.PATIENT,
            is_verified=True,
        )
        
        db.add_all([admin, doctor, mfa, staff, patient])
        
        # Create Queue
        queue = Queue(
            id=uuid.uuid4(),
            practice_id=practice.id,
            name="Allgemeine Sprechstunde",
            description="Warteschlange für allgemeine Termine",
            prefix="A",
            current_number=0,
        )
        db.add(queue)
        
        # Create Tickets
        now = datetime.now(timezone.utc)
        tickets = [
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A001",
                patient_name="Erika Muster",
                status=TicketStatus.IN_PROGRESS,
                priority=TicketPriority.NORMAL,
                created_by_id=mfa.id,
                assigned_to_id=doctor.id,
                created_at=now - timedelta(minutes=30),
                called_at=now - timedelta(minutes=5),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A002",
                patient_name="Klaus Bauer",
                status=TicketStatus.WAITING,
                priority=TicketPriority.HIGH,
                notes="Diabetes-Patient",
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=20),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A003",
                patient_name="Helga Fischer",
                status=TicketStatus.WAITING,
                priority=TicketPriority.NORMAL,
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=10),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A004",
                status=TicketStatus.WAITING,
                priority=TicketPriority.NORMAL,
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=5),
            ),
        ]
        db.add_all(tickets)
        
        # Create Tasks
        tasks = [
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Patientenakten digitalisieren",
                description="Akten aus Ordner 2023-A scannen und ablegen",
                status=TaskStatus.TODO,
                priority=TaskPriority.MEDIUM,
                assignee_id=staff.id,
                due_date=now + timedelta(days=3),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Bestellung Praxisbedarf",
                description="Handschuhe, Desinfektionsmittel, Verbandsmaterial",
                status=TaskStatus.IN_PROGRESS,
                priority=TaskPriority.HIGH,
                assignee_id=mfa.id,
                due_date=now + timedelta(days=1),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Wartezimmer aufräumen",
                status=TaskStatus.COMPLETED,
                priority=TaskPriority.LOW,
                assignee_id=staff.id,
                completed_at=now - timedelta(hours=2),
            ),
        ]
        db.add_all(tasks)
        
        # Create Chat Room
        team_chat = ChatRoom(
            id=uuid.uuid4(),
            practice_id=practice.id,
            name="Team Praxis",
            is_group=True,
        )
        db.add(team_chat)
        
        # Add Participants
        participants = [
            ChatParticipant(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                user_id=doctor.id,
            ),
            ChatParticipant(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                user_id=mfa.id,
            ),
            ChatParticipant(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                user_id=staff.id,
            ),
        ]
        db.add_all(participants)
        
        # Create Messages
        messages = [
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=doctor.id,
                content="Guten Morgen zusammen! Wie sieht es heute aus?",
                created_at=now - timedelta(hours=2),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=mfa.id,
                content="Morgen! Wir haben 12 Termine heute.",
                created_at=now - timedelta(hours=2, minutes=-5),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=staff.id,
                content="Wartezimmer ist fertig 👍",
                created_at=now - timedelta(hours=1, minutes=30),
            ),
        ]
        db.add_all(messages)
        
        await db.commit()
        
        print("✅ Seed data created successfully!")
        print("\n📋 Test Accounts:")
        print("   Admin:      admin@sanad.de / Admin123!")
        print("   Arzt:       arzt@sanad.de / Arzt123!")
        print("   MFA:        mfa@sanad.de / Mfa123!")
        print("   Mitarbeiter: mitarbeiter@sanad.de / Staff123!")
        print("   Patient:    patient@example.de / Patient123!")


if __name__ == "__main__":
    asyncio.run(seed_database())
