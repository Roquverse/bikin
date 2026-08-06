import { MediaService } from './media.service';
export declare class MediaController {
    private readonly mediaService;
    constructor(mediaService: MediaService);
    createVideo(title: string): Promise<{
        videoId: any;
        message: string;
    }>;
    deleteVideo(id: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
