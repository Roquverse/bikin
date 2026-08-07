import { PrismaService } from '../common/prisma/prisma.service';
export declare class FeedService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getFeedVideos(page?: number, limit?: number, userId?: string, category?: string): Promise<{
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
    getDiscoverFeed(page?: number, limit?: number, userId?: string): Promise<{
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
