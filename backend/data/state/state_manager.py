from typing import Final, Optional
from enum import Enum, auto

import aioredis


REDIS_URL = "redis://localhost"


class StateManager:
    def __init__(self) -> None:
        self._redis: aioredis.Redis = None

    @property
    async def redis(self) -> aioredis.Redis:
        if self._redis is None:
            self._redis = await aioredis.StrictRedis.from_url(
                REDIS_URL, decode_responses=True
            )

        return self._redis

    async def dictSet(self, id, key, value):
        redis = await self.redis
        await redis.hset(id, key, value)

    async def dictSetMultiple(self, id, map):
        redis = await self.redis
        return await redis.hmset(id, map)

    async def dictGetMultiple(self, id):
        redis = await self.redis

        return await redis.hgetall(id)

    async def dictContains(self, id, key):
        redis = await self.redis
        return await redis.hexists(id, key)

    async def dictRemove(self, id, key):
        redis = await self.redis

        return await redis.hdel(id, key)

    async def dictDelete(self, id):
        redis = await self.redis
        return await redis.delete(id)

    async def setSet(self, id, value):
        redis = await self.redis
        await redis.sadd(id, value)

    async def setRemove(self, id, value):
        redis = await self.redis
        await redis.srem(id, value)

    async def setGet(self, id):
        redis = await self.redis
        return await redis.smembers(id)

    async def setContains(self, id, value):
        redis = await self.redis
        return await redis.sismember(id, value)


stateManager: Final[StateManager] = StateManager()
