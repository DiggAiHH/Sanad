"""
Seed script for development data.

Run with: python -m app.seed_data
"""

import asyncio
import logging
import hashlib
import uuid
from datetime import datetime, timedelta, timezone

from passlib.context import CryptContext
from sqlalchemy import select

from app.config import get_settings
from app.models.models import (
    CheckInEvent,
    CheckInMethod,
    DeviceStatus,
    DeviceType,
    IoTDevice,
    NFCCardType,
    PatientNFCCard,
    Practice,
    Queue,
    Task,
    TaskPriority,
    TaskStatus,
    Ticket,
    TicketPriority,
    TicketStatus,
    User,
    UserRole,
    ChatRoom,
    ChatParticipant,
    ChatMessage,
)
from app.database import async_session_maker


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
settings = get_settings()
logger = logging.getLogger(__name__)


async def seed_database() -> None:
    """Create seed data for development."""
    async with async_session_maker() as db:
        # Check if data already exists
        existing_user = await db.execute(
            select(User).where(User.email == "admin@sanad.de")
        )
        if existing_user.scalar_one_or_none():
            logger.info("Seed-Daten existieren bereits, überspringe...")
            return

        logger.info("Seeding database...")

        # Create Practice
        practice = Practice(
            id=uuid.uuid4(),
            name="Praxis Dr. Müller",
            address="Hauptstraße 42, 80331 München",
            phone="+49 89 123456",
            email="praxis@dr-mueller.de",
            website="https://www.praxis-dr-mueller.de",
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

        # Create NFC device + card for analytics seed data
        device_secret = "seed-device-secret"
        nfc_uid = "04AABBCCDD1122"
        nfc_uid_hash = hashlib.sha256(
            nfc_uid.upper().replace(":", "").replace(" ", "").encode()
        ).hexdigest()
        nfc_device = IoTDevice(
            id=uuid.uuid4(),
            practice_id=practice.id,
            device_type=DeviceType.NFC_READER,
            device_name="Eingang NFC-Reader",
            device_serial="NFC-SEED-001",
            device_secret_hash=pwd_context.hash(device_secret),
            location="Eingang",
            status=DeviceStatus.ONLINE,
            is_active=True,
        )
        nfc_card = PatientNFCCard(
            id=uuid.uuid4(),
            patient_id=patient.id,
            nfc_uid_encrypted=f"enc:{nfc_uid}",
            nfc_uid_hash=nfc_uid_hash,
            card_type=NFCCardType.CUSTOM,
            card_label="Hauptkarte",
            is_active=True,
        )
        db.add_all([nfc_device, nfc_card])

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
                patient_name="Erika Mustermann",
                status=TicketStatus.IN_PROGRESS,
                priority=TicketPriority.NORMAL,
                created_by_id=mfa.id,
                assigned_to_id=doctor.id,
                created_at=now - timedelta(minutes=30),
                called_at=now - timedelta(minutes=5),
                notes="Routinekontrolle Blutdruck",
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A002",
                patient_name="Klaus Bauer",
                status=TicketStatus.WAITING,
                priority=TicketPriority.HIGH,
                notes="Diabetes-Patient - Nüchternblutzucker prüfen",
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
                notes="Grippe-Impfung",
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=10),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A004",
                patient_name="Thomas Schmidt",
                status=TicketStatus.WAITING,
                priority=TicketPriority.NORMAL,
                notes="Rezept abholen",
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=5),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="A005",
                patient_name="Anna Weber",
                status=TicketStatus.COMPLETED,
                priority=TicketPriority.NORMAL,
                notes="Ultraschall abgeschlossen",
                created_by_id=mfa.id,
                assigned_to_id=doctor.id,
                created_at=now - timedelta(hours=2),
                called_at=now - timedelta(hours=1, minutes=50),
                completed_at=now - timedelta(hours=1, minutes=30),
            ),
            Ticket(
                id=uuid.uuid4(),
                queue_id=queue.id,
                ticket_number="B001",
                patient_name="Fatima Al-Hassan",
                status=TicketStatus.WAITING,
                priority=TicketPriority.URGENT,
                notes="Starke Kopfschmerzen seit 3 Tagen",
                created_by_id=mfa.id,
                created_at=now - timedelta(minutes=2),
            ),
        ]
        db.add_all(tickets)

        # Create check-in events for analytics seed data
        check_in_events = [
            CheckInEvent(
                id=uuid.uuid4(),
                practice_id=practice.id,
                ticket_id=tickets[0].id,
                device_id=nfc_device.id,
                nfc_card_id=nfc_card.id,
                check_in_method=CheckInMethod.NFC,
                patient_id=patient.id,
                success=True,
                checked_in_at=tickets[0].created_at,
            ),
            CheckInEvent(
                id=uuid.uuid4(),
                practice_id=practice.id,
                ticket_id=tickets[1].id,
                device_id=nfc_device.id,
                nfc_card_id=nfc_card.id,
                check_in_method=CheckInMethod.NFC,
                patient_id=patient.id,
                success=True,
                checked_in_at=tickets[1].created_at,
            ),
            CheckInEvent(
                id=uuid.uuid4(),
                practice_id=practice.id,
                ticket_id=tickets[2].id,
                check_in_method=CheckInMethod.MANUAL,
                success=True,
                checked_in_at=tickets[2].created_at,
            ),
            CheckInEvent(
                id=uuid.uuid4(),
                practice_id=practice.id,
                ticket_id=tickets[3].id,
                check_in_method=CheckInMethod.MANUAL,
                success=True,
                checked_in_at=tickets[3].created_at,
            ),
            CheckInEvent(
                id=uuid.uuid4(),
                practice_id=practice.id,
                ticket_id=tickets[4].id,
                check_in_method=CheckInMethod.ONLINE,
                success=True,
                checked_in_at=tickets[4].created_at,
            ),
        ]
        db.add_all(check_in_events)

        # Create Tasks
        tasks = [
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Patientenakten digitalisieren",
                description="Akten aus Ordner 2023-A scannen und ablegen (35 Akten, Priorität Patienten mit Terminen nächste Woche)",
                status=TaskStatus.TODO,
                priority=TaskPriority.MEDIUM,
                assignee_id=staff.id,
                due_date=now + timedelta(days=3),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Bestellung Praxisbedarf",
                description="Handschuhe (500 Stück), Desinfektionsmittel (5 Liter), Verbandsmaterial (Komplett-Set)",
                status=TaskStatus.IN_PROGRESS,
                priority=TaskPriority.HIGH,
                assignee_id=mfa.id,
                due_date=now + timedelta(days=1),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Wartezimmer aufräumen",
                description="Zeitschriften sortieren, Spielecke desinfizieren, Pflanzen gießen",
                status=TaskStatus.COMPLETED,
                priority=TaskPriority.LOW,
                assignee_id=staff.id,
                completed_at=now - timedelta(hours=2),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Labor-Ergebnisse nachverfolgen",
                description="3 ausstehende Befunde anfordern: Klaus Bauer (HbA1c), Anna Weber (Schilddrüse), Thomas Schmidt (Urin)",
                status=TaskStatus.TODO,
                priority=TaskPriority.HIGH,
                assignee_id=mfa.id,
                due_date=now + timedelta(hours=4),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Geräte-Wartung planen",
                description="EKG-Gerät Kalibrierung überfällig - Techniker kontaktieren (Firma Medtec, Tel. 089-12345)",
                status=TaskStatus.TODO,
                priority=TaskPriority.URGENT,
                assignee_id=doctor.id,
                due_date=now + timedelta(hours=6),
            ),
            Task(
                id=uuid.uuid4(),
                practice_id=practice.id,
                title="Impf-Kampagne koordinieren",
                description="15 Patienten für Grippe-Impfung nächste Woche einbestellen, Impfstoff prüfen (12 Dosen vorrätig)",
                status=TaskStatus.IN_PROGRESS,
                priority=TaskPriority.MEDIUM,
                assignee_id=mfa.id,
                due_date=now + timedelta(days=5),
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
                content="Morgen! Wir haben 6 Tickets in der Warteschlange. Klaus Bauer (A002) ist Diabetes-Notfall, sollte prioritär behandelt werden.",
                created_at=now - timedelta(hours=1, minutes=55),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=doctor.id,
                content="Verstanden, rufe ihn gleich nach Erika auf. Sind die Labor-Ergebnisse schon da?",
                created_at=now - timedelta(hours=1, minutes=50),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=mfa.id,
                content="Noch nicht, habe gerade beim Labor angerufen - kommen bis 14 Uhr. Ich erstelle die Task.",
                created_at=now - timedelta(hours=1, minutes=45),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=staff.id,
                content="Übrigens: EKG-Gerät zeigt Kalibrierungsfehler. Techniker kontaktiert?",
                created_at=now - timedelta(hours=1, minutes=30),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=doctor.id,
                content="Danke für den Hinweis! @mfa kannst du Firma Medtec anrufen? Dringend!",
                created_at=now - timedelta(hours=1, minutes=25),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=mfa.id,
                content="✓ Mache ich sofort. Termin für morgen früh angefragt.",
                created_at=now - timedelta(hours=1, minutes=20),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=staff.id,
                content="Impfstoff-Inventur: 12 Grippe-Dosen vorrätig, Nachbestellung nötig für Kampagne nächste Woche.",
                created_at=now - timedelta(minutes=45),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=mfa.id,
                content="Gut, ich bestelle 30 Dosen nach. Liste für Impftermine ist fast voll (15/20 Plätze belegt).",
                created_at=now - timedelta(minutes=40),
            ),
            ChatMessage(
                id=uuid.uuid4(),
                room_id=team_chat.id,
                sender_id=doctor.id,
                content="Perfekt! Bitte auch Fatima Al-Hassan (B001) im Auge behalten - starke Kopfschmerzen, evtl. Migräne. Rufe sie als nächstes.",
                created_at=now - timedelta(minutes=5),
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

        logger.info("Seed data created successfully!")
        logger.info("Test Accounts:")
        logger.info("   Admin:      admin@sanad.de / Admin123!")
        logger.info("   Arzt:       arzt@sanad.de / Arzt123!")
        logger.info("   MFA:        mfa@sanad.de / Mfa123!")
        logger.info("   Mitarbeiter: staff@sanad.de / Staff123!")
        logger.info("   Patient:    patient@example.de / Patient123!")


if __name__ == "__main__":
    asyncio.run(seed_database())
