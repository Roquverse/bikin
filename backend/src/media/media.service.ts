import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import { v2 as cloudinary } from 'cloudinary';
import * as fs from 'fs';

@Injectable()
export class MediaService {
  private readonly bunnyApiKey = process.env.BUNNY_API_KEY;
  private readonly bunnyLibraryId = process.env.BUNNY_LIBRARY_ID;

  constructor(private readonly httpService: HttpService) {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
    });
  }

  async createVideo(title: string) {
    if (!this.bunnyApiKey || !this.bunnyLibraryId) {
      throw new HttpException('Bunny Stream is not configured', HttpStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      const url = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos`;
      const response = await lastValueFrom(
        this.httpService.post(
          url,
          { title },
          {
            headers: {
              AccessKey: this.bunnyApiKey,
              'Content-Type': 'application/json',
              Accept: 'application/json',
            },
          },
        ),
      );

      // response.data contains guid (videoId)
      return {
        videoId: response.data.guid,
        message: 'Video created successfully on Bunny Stream. Ready for upload.',
      };
    } catch (error: any) {
      throw new HttpException(
        `Failed to create video on Bunny: ${error?.response?.data?.Message || error.message}`,
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async uploadImageToCloudinary(filePath: string): Promise<string> {
    try {
      if (!process.env.CLOUDINARY_CLOUD_NAME) {
         return `/uploads/${filePath.split('/').pop()}`; // Fallback if not configured
      }
      const result = await cloudinary.uploader.upload(filePath, { folder: 'bikin' });
      return result.secure_url;
    } catch (e) {
      console.error(e);
      throw new HttpException('Failed to upload image to Cloudinary', HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async uploadVideoToBunny(filePath: string): Promise<string> {
    if (!this.bunnyApiKey || !this.bunnyLibraryId || !process.env.BUNNY_PULL_ZONE) {
      return `/uploads/${filePath.split('/').pop()}`; // Fallback if not configured
    }

    try {
      // 1. Create video object
      const createUrl = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos`;
      const createResponse = await lastValueFrom(
        this.httpService.post(
          createUrl,
          { title: `Upload-${Date.now()}` },
          {
            headers: {
              AccessKey: this.bunnyApiKey,
              'Content-Type': 'application/json',
              Accept: 'application/json',
            },
          },
        ),
      );

      const videoId = createResponse.data.guid;

      // 2. Upload video file
      const uploadUrl = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos/${videoId}`;
      const fileStream = fs.createReadStream(filePath);
      
      await lastValueFrom(
        this.httpService.put(uploadUrl, fileStream, {
          headers: {
            AccessKey: this.bunnyApiKey,
            'Content-Type': 'application/octet-stream',
          },
        }),
      );

      // 3. Return playback URL
      return `https://${process.env.BUNNY_PULL_ZONE}/${videoId}/playlist.m3u8`;
    } catch (error) {
      console.error(error);
      throw new HttpException('Failed to upload video to Bunny Stream', HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async deleteVideo(videoId: string) {
    if (!this.bunnyApiKey || !this.bunnyLibraryId) {
      throw new HttpException('Bunny Stream is not configured', HttpStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      const url = `https://video.bunnycdn.com/library/${this.bunnyLibraryId}/videos/${videoId}`;
      await lastValueFrom(
        this.httpService.delete(url, {
          headers: {
            AccessKey: this.bunnyApiKey,
            Accept: 'application/json',
          },
        }),
      );

      return { success: true, message: 'Video deleted from Bunny Stream' };
    } catch (error) {
      throw new HttpException(
        `Failed to delete video on Bunny: ${error?.response?.data?.Message || error.message}`,
        HttpStatus.BAD_REQUEST,
      );
    }
  }
}
