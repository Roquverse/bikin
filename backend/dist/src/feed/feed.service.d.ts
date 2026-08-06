import { PrismaService } from '../common/prisma/prisma.service';
export declare class FeedService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getFeedVideos(page?: number, limit?: number, userId?: string): Promise<{
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
