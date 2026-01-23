"""
Alembic Migration: Add website field to practices.

Adds: practices.website (nullable)

Revision ID: 003_add_practice_website
Revises: 002_zero_touch_reception
Create Date: 2026-01-22
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = "003_add_practice_website"
down_revision = "002_zero_touch_reception"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("practices", sa.Column("website", sa.String(255), nullable=True))


def downgrade() -> None:
    op.drop_column("practices", "website")
