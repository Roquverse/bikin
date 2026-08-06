import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './common/prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MediaModule } from './media/media.module';
import { PaymentsModule } from './payments/payments.module';
import { FeedModule } from './feed/feed.module';
import { MailModule } from './common/mail/mail.module';

@Module({
  imports: [PrismaModule, RedisModule, AuthModule, UsersModule, MediaModule, PaymentsModule, FeedModule, MailModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
