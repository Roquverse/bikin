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
    deleteVideo(videoId: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
