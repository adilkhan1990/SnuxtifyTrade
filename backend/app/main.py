from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio
from app.database import engine, Base
from app.redis_client import redis_client
from app.routers import health, auth, trading
from app.core.config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Starting up FnF Trading System...")
    
    # Create database tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    print("Database tables created successfully")
    
    yield
    
    # Shutdown
    print("Shutting down FnF Trading System...")
    await redis_client.close()
    print("Redis connection closed")

app = FastAPI(
    title=settings.app_name,
    description="A comprehensive trading system API built with FastAPI",
    version=settings.version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/api/v1", tags=["health"])
app.include_router(auth.router, prefix="/api/v1", tags=["authentication"])
app.include_router(trading.router, prefix="/api/v1", tags=["trading"])

@app.get("/")
async def root():
    return {
        "message": f"Welcome to {settings.app_name}",
        "version": settings.version,
        "environment": settings.environment,
        "docs": "/docs",
        "status": "running"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
