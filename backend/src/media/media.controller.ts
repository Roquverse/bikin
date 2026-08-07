import { Controller, Post, Body, UseGuards, Delete, Param, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('media')
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @UseGuards(JwtAuthGuard)
  @Post('upload')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const randomName = Array(32).fill(null).map(() => (Math.round(Math.random() * 16)).toString(16)).join('');
        cb(null, `${randomName}${extname(file.originalname)}`);
      }
    })
  }))
  async uploadFile(@UploadedFile() file: Express.Multer.File) {
    // Determine the base URL. In a real app, this would be an env variable.
    // For local dev with android/iOS emulators, we can just return a path and let the app build the URL,
    // or return the full URL if we know it.
    // Since we don't know the IP from here reliably without req, we'll return the relative path
    return {
      message: 'File uploaded successfully',
      url: `/uploads/${file.filename}`,
    };
  }

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
