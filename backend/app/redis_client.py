import redis.asyncio as redis
from app.core.config import settings

# Create Redis client with explicit password configuration
redis_client = redis.Redis(
    host="redis",
    port=6379,
    password="redis123",
    db=0,
    encoding="utf-8",
    decode_responses=True
)
