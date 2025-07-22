from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql://postgres:postgres123@postgres:5432/trading_db"
    
    # Redis
    redis_url: str = "redis://:redis123@redis:6379/0"
    
    # Security
    secret_key: str = "your-secret-key-change-this-in-production-2025"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Application
    environment: str = "development"
    debug: bool = True
    app_name: str = "FnF Trading System API"
    version: str = "1.0.0"
    
    # CORS
    cors_origins: list[str] = [
        "http://localhost:3000", 
        "http://frontend:3000", 
        "http://localhost",
        "http://127.0.0.1:3000"
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
