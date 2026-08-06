import { FeedService } from './feed.service';
import { Request } from 'express';
export declare class FeedController {
    private readonly feedService;
    constructor(feedService: FeedService);
    getFeed(page: string, req: Request): Promise<{
        id: string;
        videoUrl: string | null;
        thumbnailUrl: string;
        caption: string;
        hashtags: never[];
        organizerId: string;
        organizerName: any;
        organizerAvatarUrl: string;
        likesCount: any;
        commentsCount: any;
        hasTickets: boolean;
        isLikedByMe: any;
        isFollowingOrganizer: boolean;
    }[]>;
}
