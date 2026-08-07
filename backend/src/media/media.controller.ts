import { Controller, Post, Body, UseGuards, Delete, Param, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import * as fs from 'fs';
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
    try {
      const filePath = `./uploads/${file.filename}`;
      const isVideo = file.mimetype.startsWith('video/');
      
      let finalUrl = '';
      if (isVideo) {
        finalUrl = await this.mediaService.uploadVideoToBunny(filePath);
      } else {
        finalUrl = await this.mediaService.uploadImageToCloudinary(filePath);
      }

      // Cleanup local file
      try {
        fs.unlinkSync(filePath);
      } catch (e) {
        console.error('Failed to cleanup file:', e);
      }

      return {
        message: 'File uploaded successfully',
        url: finalUrl,
      };
    } catch (error) {
      try {
        fs.unlinkSync(`./uploads/${file.filename}`);
      } catch (e) {}
      throw error;
    }
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
