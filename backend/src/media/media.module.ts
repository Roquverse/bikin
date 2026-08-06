import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { MediaService } from './media.service';
import { MediaController } from './media.controller';

@Module({
  imports: [HttpModule],
  providers: [MediaService],
  controllers: [MediaController],
  exports: [MediaService],
})
export class MediaModule {}
