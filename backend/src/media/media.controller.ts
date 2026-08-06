import { Controller, Post, Body, UseGuards, Delete, Param } from '@nestjs/common';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @UseGuards(JwtAuthGuard)
  @Post('videos')
  async createVideo(@Body('title') title: string) {
    return this.mediaService.createVideo(title || 'Untitled Video');
  }

  @UseGuards(JwtAuthGuard)
  @Delete('videos/:id')
  async deleteVideo(@Param('id') id: string) {
    return this.mediaService.deleteVideo(id);
  }
}
