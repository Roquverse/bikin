import { UsersService } from './users.service';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getProfile(req: any): any;
    updateProfile(req: any, data: any): Promise<{
        id: string;
        email: string;
        password: string;
        name: string;
        avatarUrl: string | null;
        bio: string | null;
        role: import(".prisma/client").$Enums.Role;
        createdAt: Date;
        updatedAt: Date;
    }>;
    getMyStats(req: any): Promise<{
        followersCount: number;
        followingCount: number;
        walletBalance: number;
        recentSales: {
            ticketId: string;
            buyerName: string;
            eventTitle: string;
            price: number;
            date: Date;
        }[];
        eventsAttendedCount: number;
        eventsHostedCount: number;
        totalAttendeesCount: number;
        upcomingEventCount: number;
        avgReelEngagement: number;
    }>;
    getMyEvents(req: any): Promise<{
        id: string;
        date: string;
        location: string;
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
        ticketsSold: number;
        capacity: number;
    }[]>;
    getMyTickets(req: any): Promise<({
        event: {
            organizer: {
                name: string;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            title: string;
            description: string;
            date: Date;
            location: string;
            mediaUrl: string | null;
            thumbnailUrl: string | null;
            price: number;
            organizerId: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        eventId: string;
        tierId: string | null;
        status: string;
    })[]>;
    toggleFollow(id: string, isFollowing: boolean, req: any): Promise<{
        success: boolean;
    }>;
    getFollowing(req: any): Promise<{
        id: string;
        name: string;
        avatarUrl: string;
        upcomingEventsCount: number;
    }[]>;
    getLikedEvents(req: any): Promise<{
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
}
