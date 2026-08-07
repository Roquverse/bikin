import { MediaService } from './media.service';
export declare class MediaController {
    private readonly mediaService;
    constructor(mediaService: MediaService);
    uploadFile(file: Express.Multer.File): Promise<{
        message: string;
        url: string;
    }>;
    createVideo(title: string): Promise<{
        videoId: any;
        message: string;
    }>;
    deleteVideo(id: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
