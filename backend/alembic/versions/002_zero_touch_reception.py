"""
Alembic Migration: Add Zero-Touch Reception tables.

Adds: IoTDevice, Zone, LEDSegment, WayfindingRoute, PatientNFCCard, CheckInEvent, WaitTimeLog

Revision ID: 002_zero_touch_reception
Revises: 001_initial_migration
Create Date: 2026-01-13
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers
revision = "002_zero_touch_reception"
down_revision = "001_initial"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ==========================================================================
    # ENUMS
    # ==========================================================================
    device_type_enum = postgresql.ENUM(
        "nfc_reader",
        "led_controller",
        "display",
        "kiosk",
        name="devicetype",
        create_type=False,
    )
    device_status_enum = postgresql.ENUM(
        "online",
        "offline",
        "error",
        "maintenance",
        name="devicestatus",
        create_type=False,
    )
    led_pattern_enum = postgresql.ENUM(
        "solid",
        "pulse",
        "chase",
        "rainbow",
        "breathe",
        "wipe",
        name="ledpattern",
        create_type=False,
    )
    nfc_card_type_enum = postgresql.ENUM(
        "egk",
        "custom",
        "temporary",
        "mobile",
        name="nfccardtype",
        create_type=False,
    )
    check_in_method_enum = postgresql.ENUM(
        "nfc",
        "qr",
        "manual",
        "kiosk",
        "online",
        name="checkinmethod",
        create_type=False,
    )

    # Create enums
    device_type_enum.create(op.get_bind(), checkfirst=True)
    device_status_enum.create(op.get_bind(), checkfirst=True)
    led_pattern_enum.create(op.get_bind(), checkfirst=True)
    nfc_card_type_enum.create(op.get_bind(), checkfirst=True)
    check_in_method_enum.create(op.get_bind(), checkfirst=True)

    # ==========================================================================
    # ZONES TABLE (must be created before IoTDevices due to FK)
    # ==========================================================================
    op.create_table(
        "zones",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "practice_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("practices.id"),
            nullable=False,
        ),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("code", sa.String(20), nullable=False),
        sa.Column("zone_type", sa.String(50), nullable=False),
        sa.Column("floor", sa.Integer, default=0, nullable=False),
        sa.Column("x_position", sa.Integer, nullable=True),
        sa.Column("y_position", sa.Integer, nullable=True),
        sa.Column("is_destination", sa.Boolean, default=False, nullable=False),
        sa.Column("is_active", sa.Boolean, default=True, nullable=False),
        sa.Column(
            "created_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index("ix_zones_practice_id", "zones", ["practice_id"])
    op.create_index("ix_zones_code", "zones", ["code"])

    # ==========================================================================
    # IOT DEVICES TABLE
    # ==========================================================================
    op.create_table(
        "iot_devices",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "practice_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("practices.id"),
            nullable=False,
        ),
        sa.Column("device_type", device_type_enum, nullable=False),
        sa.Column("device_name", sa.String(100), nullable=False),
        sa.Column("device_serial", sa.String(100), unique=True, nullable=False),
        sa.Column("device_secret_hash", sa.String(255), nullable=False),
        sa.Column("location", sa.String(100), nullable=False),
        sa.Column(
            "zone_id", sa.Uuid(as_uuid=True), sa.ForeignKey("zones.id"), nullable=True
        ),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("firmware_version", sa.String(50), nullable=True),
        sa.Column("status", device_status_enum, default="offline", nullable=False),
        sa.Column("is_active", sa.Boolean, default=True, nullable=False),
        sa.Column("last_heartbeat", sa.DateTime, nullable=True),
        sa.Column(
            "created_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
        sa.Column(
            "updated_at",
            sa.DateTime,
            server_default=sa.func.now(),
            onupdate=sa.func.now(),
            nullable=False,
        ),
    )
    op.create_index("ix_iot_devices_practice_id", "iot_devices", ["practice_id"])
    op.create_index(
        "ix_iot_devices_device_serial", "iot_devices", ["device_serial"], unique=True
    )
    op.create_index("ix_iot_devices_status", "iot_devices", ["status"])

    # ==========================================================================
    # LED SEGMENTS TABLE
    # ==========================================================================
    op.create_table(
        "led_segments",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "zone_id", sa.Uuid(as_uuid=True), sa.ForeignKey("zones.id"), nullable=False
        ),
        sa.Column(
            "controller_device_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("iot_devices.id"),
            nullable=False,
        ),
        sa.Column("segment_id", sa.Integer, nullable=False),  # WLED segment 0-15
        sa.Column("start_led", sa.Integer, nullable=False),
        sa.Column("end_led", sa.Integer, nullable=False),
        sa.Column("default_color", sa.String(7), default="#0066CC", nullable=False),
        sa.Column("default_brightness", sa.Integer, default=128, nullable=False),
        sa.Column("is_active", sa.Boolean, default=True, nullable=False),
        sa.Column(
            "created_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index("ix_led_segments_zone_id", "led_segments", ["zone_id"])
    op.create_index(
        "ix_led_segments_controller", "led_segments", ["controller_device_id"]
    )

    # ==========================================================================
    # WAYFINDING ROUTES TABLE
    # ==========================================================================
    op.create_table(
        "wayfinding_routes",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "practice_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("practices.id"),
            nullable=False,
        ),
        sa.Column(
            "from_zone_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("zones.id"),
            nullable=False,
        ),
        sa.Column(
            "to_zone_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("zones.id"),
            nullable=False,
        ),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("led_segment_ids", sa.Text, nullable=False),  # JSON array
        sa.Column("led_pattern", led_pattern_enum, default="chase", nullable=False),
        sa.Column("led_color", sa.String(7), default="#00FF00", nullable=False),
        sa.Column("duration_seconds", sa.Integer, default=30, nullable=False),
        sa.Column("is_active", sa.Boolean, default=True, nullable=False),
        sa.Column(
            "created_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index(
        "ix_wayfinding_routes_practice", "wayfinding_routes", ["practice_id"]
    )
    op.create_index(
        "ix_wayfinding_routes_from_to",
        "wayfinding_routes",
        ["from_zone_id", "to_zone_id"],
    )

    # ==========================================================================
    # PATIENT NFC CARDS TABLE
    # ==========================================================================
    op.create_table(
        "patient_nfc_cards",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "patient_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("users.id"),
            nullable=False,
        ),
        sa.Column("nfc_uid_encrypted", sa.String(255), nullable=False),
        sa.Column("nfc_uid_hash", sa.String(64), unique=True, nullable=False),
        sa.Column("card_type", nfc_card_type_enum, nullable=False),
        sa.Column("card_label", sa.String(100), nullable=True),
        sa.Column("is_active", sa.Boolean, default=True, nullable=False),
        sa.Column(
            "issued_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
        sa.Column("expires_at", sa.DateTime, nullable=True),
        sa.Column("last_used_at", sa.DateTime, nullable=True),
    )
    op.create_index("ix_patient_nfc_cards_patient", "patient_nfc_cards", ["patient_id"])
    op.create_index(
        "ix_patient_nfc_cards_uid_hash",
        "patient_nfc_cards",
        ["nfc_uid_hash"],
        unique=True,
    )

    # ==========================================================================
    # CHECK-IN EVENTS TABLE
    # ==========================================================================
    op.create_table(
        "check_in_events",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "practice_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("practices.id"),
            nullable=False,
        ),
        sa.Column(
            "ticket_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("tickets.id"),
            nullable=True,
        ),
        sa.Column(
            "device_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("iot_devices.id"),
            nullable=True,
        ),
        sa.Column(
            "nfc_card_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("patient_nfc_cards.id"),
            nullable=True,
        ),
        sa.Column("check_in_method", check_in_method_enum, nullable=False),
        sa.Column(
            "patient_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("users.id"),
            nullable=True,
        ),
        sa.Column("raw_nfc_uid_hash", sa.String(64), nullable=True),
        sa.Column("success", sa.Boolean, default=True, nullable=False),
        sa.Column("failure_reason", sa.String(255), nullable=True),
        sa.Column("assigned_room", sa.String(50), nullable=True),
        sa.Column(
            "wayfinding_route_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("wayfinding_routes.id"),
            nullable=True,
        ),
        sa.Column(
            "checked_in_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index("ix_check_in_events_practice", "check_in_events", ["practice_id"])
    op.create_index("ix_check_in_events_patient", "check_in_events", ["patient_id"])
    op.create_index("ix_check_in_events_time", "check_in_events", ["checked_in_at"])
    op.create_index("ix_check_in_events_method", "check_in_events", ["check_in_method"])

    # ==========================================================================
    # WAIT TIME LOGS TABLE (for LED color visualization)
    # ==========================================================================
    op.create_table(
        "wait_time_logs",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True),
        sa.Column(
            "practice_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("practices.id"),
            nullable=False,
        ),
        sa.Column(
            "queue_id",
            sa.Uuid(as_uuid=True),
            sa.ForeignKey("queues.id"),
            nullable=False,
        ),
        sa.Column(
            "zone_id", sa.Uuid(as_uuid=True), sa.ForeignKey("zones.id"), nullable=True
        ),
        sa.Column("waiting_count", sa.Integer, default=0, nullable=False),
        sa.Column("average_wait_minutes", sa.Integer, default=0, nullable=False),
        sa.Column("max_wait_minutes", sa.Integer, default=0, nullable=False),
        sa.Column("led_color_state", sa.String(7), default="#00FF00", nullable=False),
        sa.Column(
            "recorded_at", sa.DateTime, server_default=sa.func.now(), nullable=False
        ),
    )
    op.create_index("ix_wait_time_logs_practice", "wait_time_logs", ["practice_id"])
    op.create_index("ix_wait_time_logs_queue", "wait_time_logs", ["queue_id"])
    op.create_index("ix_wait_time_logs_time", "wait_time_logs", ["recorded_at"])


def downgrade() -> None:
    # Drop tables in reverse order (due to FK constraints)
    op.drop_table("wait_time_logs")
    op.drop_table("check_in_events")
    op.drop_table("patient_nfc_cards")
    op.drop_table("wayfinding_routes")
    op.drop_table("led_segments")
    op.drop_table("iot_devices")
    op.drop_table("zones")

    # Drop enums
    op.execute("DROP TYPE IF EXISTS checkinmethod")
    op.execute("DROP TYPE IF EXISTS nfccardtype")
    op.execute("DROP TYPE IF EXISTS ledpattern")
    op.execute("DROP TYPE IF EXISTS devicestatus")
    op.execute("DROP TYPE IF EXISTS devicetype")
