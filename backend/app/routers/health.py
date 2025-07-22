from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.database import get_db
from app.redis_client import redis_client
from pydantic import BaseModel
import asyncio
from typing import Dict, Any

router = APIRouter()

class HealthStatus(BaseModel):
    status: str
    services: Dict[str, Any]

@router.get("/health", response_model=HealthStatus)
async def health_check(db: AsyncSession = Depends(get_db)):
    """
    Comprehensive health check endpoint that verifies all services are running.
    """
    services = {}
    overall_status = "healthy"
    
    # Check PostgreSQL
    try:
        result = await db.execute(text("SELECT 1"))
        result.fetchone()
        services["postgresql"] = {
            "status": "connected",
            "message": "Database connection successful"
        }
    except Exception as e:
        services["postgresql"] = {
            "status": "error",
            "message": f"Database connection failed: {str(e)}"
        }
        overall_status = "unhealthy"
    
    # Check Redis
    try:
        await redis_client.ping()
        services["redis"] = {
            "status": "connected",
            "message": "Redis connection successful"
        }
    except Exception as e:
        services["redis"] = {
            "status": "error",
            "message": f"Redis connection failed: {str(e)}"
        }
        overall_status = "unhealthy"
    
    # API Health
    services["api"] = {
        "status": "running",
        "message": "FastAPI service is operational"
    }
    
    return HealthStatus(
        status=overall_status,
        services=services
    )

@router.get("/health/db")
async def database_health(db: AsyncSession = Depends(get_db)):
    """Check specifically database connectivity."""
    try:
        result = await db.execute(text("SELECT version()"))
        version = result.fetchone()
        return {
            "status": "connected",
            "postgresql_version": version[0] if version else "unknown"
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database unavailable: {str(e)}")

@router.get("/health/redis")
async def redis_health():
    """Check specifically Redis connectivity."""
    try:
        info = await redis_client.info()
        return {
            "status": "connected",
            "redis_version": info.get("redis_version", "unknown"),
            "connected_clients": info.get("connected_clients", 0)
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Redis unavailable: {str(e)}")
