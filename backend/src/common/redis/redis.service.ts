import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService extends Redis implements OnModuleInit, OnModuleDestroy {
  constructor() {
    const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
    const isTls = redisUrl.startsWith('rediss://');

    super(redisUrl, {
      tls: isTls ? {} : undefined,
      lazyConnect: true,
      maxRetriesPerRequest: null,
    });
  }

  onModuleInit() {
    this.on('connect', () => console.log('✅ Connected to Redis'));
    this.on('error', (err) => console.error('Redis error:', err.message));
    this.connect().catch((err) => console.error('Redis connect error:', err.message));
  }

  onModuleDestroy() {
    this.disconnect();
  }
}

