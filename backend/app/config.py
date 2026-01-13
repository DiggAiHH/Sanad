"""
Application configuration using Pydantic Settings.

Security: All secrets loaded from environment variables (Fail Fast).
"""

from functools import lru_cache
from pydantic_settings import BaseSettings


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
    
    # Seed data on startup (for demo/testing)
    SEED_ON_STARTUP: bool = True
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60
    
    @property
    def async_database_url(self) -> str:
        """Convert standard postgres:// URL to asyncpg format."""
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+asyncpg://", 1)
        elif url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache
def get_settings() -> Settings:
    """
    Get cached application settings.
    
    Returns:
        Settings: Application configuration singleton.
    """
    return Settings()
