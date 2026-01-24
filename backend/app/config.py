"""
Application configuration using Pydantic Settings.

Security: All secrets loaded from environment variables (Fail Fast).
"""

from functools import lru_cache
from typing import Any

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings with environment variable validation.

    Raises:
        ValidationError: If required environment variables are missing.

    Security Implications:
        - All secrets MUST be provided via environment variables.
        - No default values for sensitive data.
    """

    # Application
    APP_NAME: str = "Sanad API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # Database - REQUIRED
    DATABASE_URL: str

    # JWT Authentication - REQUIRED
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS - Support comma-separated string from env
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080"]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: Any) -> list[str]:
        """Parse CORS origins from comma-separated string or list."""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return v

    # Seed data on startup (for demo/testing)
    SEED_ON_STARTUP: bool = True

    # Test mode toggle (skips startup DB init/seed)
    TESTING: bool = False

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60

    # Request size limits (MB)
    MAX_REQUEST_SIZE_MB: int = 5

    # Security headers
    ENABLE_HSTS: bool = True

    # WebRTC / TURN Server Configuration (Option B: Managed EU Provider)
    # Examples: Twilio TURN (EU), Cloudflare Calls, Xirsys (EU region)
    TURN_SERVER_URL: str | None = None
    TURN_SERVER_USERNAME: str | None = None
    TURN_SERVER_CREDENTIAL: str | None = None
    TURN_SERVER_REALM: str = "sanad.de"

    # E2E Encryption (Option B: Client-side with searchable index)
    E2E_ENCRYPTION_ENABLED: bool = True
    E2E_KEY_DERIVATION_ITERATIONS: int = 100000

    # Netlify domains (auto-generated)
    NETLIFY_DOMAINS: list[str] = [
        "https://sanad-admin.netlify.app",
        "https://sanad-mfa.netlify.app",
        "https://sanad-staff.netlify.app",
        "https://sanad-patient.netlify.app",
        # With owner suffix
        "https://sanad-admin-diggaihh.netlify.app",
        "https://sanad-mfa-diggaihh.netlify.app",
        "https://sanad-staff-diggaihh.netlify.app",
        "https://sanad-patient-diggaihh.netlify.app",
    ]

    @property
    def all_cors_origins(self) -> list[str]:
        """Get all allowed CORS origins including Netlify domains."""
        return list(set(self.CORS_ORIGINS + self.NETLIFY_DOMAINS))

    @property
    def async_database_url(self) -> str:
        """Convert standard postgres:// URL to asyncpg format."""
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+asyncpg://", 1)
        elif url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )


@lru_cache
def get_settings() -> Settings:
    """
    Get cached application settings.

    Returns:
        Settings: Application configuration singleton.
    """
    return Settings()
