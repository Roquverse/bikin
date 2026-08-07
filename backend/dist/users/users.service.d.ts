import { PrismaService } from '../common/prisma/prisma.service';
import { Prisma, Role, User } from '@prisma/client';
export declare class UsersService {
    private prisma;
    constructor(prisma: PrismaService);
    create(data: Prisma.UserCreateInput): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    updateRole(id: string, role: Role): Promise<User>;
    updateProfile(id: string, data: {
        name?: string;
        avatarUrl?: string;
        bio?: string;
        role?: Role;
    }): Promise<User>;
    getUserStats(userId: string): Promise<{
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
    }>;
    getUserEvents(userId: string): Promise<{
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
    }[]>;
    getUserTickets(userId: string): Promise<({
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
            price: number;
            organizerId: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        eventId: string;
        status: string;
    })[]>;
}
