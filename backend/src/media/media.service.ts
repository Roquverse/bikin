import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';

@Injectable()
export class MediaService {
  private readonly bunnyApiKey = process.env.BUNNY_API_KEY;
  private readonly bunnyLibraryId = process.env.BUNNY_LIBRARY_ID;

  constructor(private readonly httpService: HttpService) {}

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
    } catch (error) {
      throw new HttpException(
        `Failed to create video on Bunny: ${error?.response?.data?.Message || error.message}`,
        HttpStatus.BAD_REQUEST,
      );
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
