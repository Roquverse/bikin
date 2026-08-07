import { HttpService } from '@nestjs/axios';
export declare class MediaService {
    private readonly httpService;
    private readonly bunnyApiKey;
    private readonly bunnyLibraryId;
    constructor(httpService: HttpService);
    createVideo(title: string): Promise<{
        videoId: any;
        message: string;
    }>;
    uploadImageToCloudinary(filePath: string): Promise<string>;
    uploadVideoToBunny(filePath: string): Promise<string>;
    deleteVideo(videoId: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
