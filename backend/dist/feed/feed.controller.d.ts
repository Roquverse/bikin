import { FeedService } from './feed.service';
import type { Request } from 'express';
export declare class FeedController {
    private readonly feedService;
    constructor(feedService: FeedService);
    getFeed(page: string, category: string, req: Request): Promise<{
        id: string;
        date: string;
        location: string;
        category: any;
        videoUrl: string | null;
        thumbnailUrl: string | null;
        caption: string;
        hashtags: never[];
        organizerId: string;
        organizerName: string;
        organizerAvatarUrl: string;
        likesCount: number;
        commentsCount: number;
        hasTickets: boolean;
        isLikedByMe: boolean;
        isFollowingOrganizer: boolean;
    }[]>;
    getDiscoverFeed(page: string, category: string, req: Request): Promise<{
        id: string;
        date: string;
        location: string;
        category: any;
        videoUrl: string | null;
        thumbnailUrl: string | null;
        caption: string;
        hashtags: never[];
        organizerId: string;
        organizerName: string;
        organizerAvatarUrl: string;
        likesCount: number;
        commentsCount: number;
        hasTickets: boolean;
        isLikedByMe: boolean;
        isFollowingOrganizer: boolean;
    }[]>;
    getCategories(): Promise<{
        id: string;
        name: string;
    }[]>;
}
