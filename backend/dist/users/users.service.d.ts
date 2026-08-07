import { PrismaService } from '../common/prisma/prisma.service';
import { Prisma, Role, User } from '@prisma/client';
export declare class UsersService {
    private prisma;
    constructor(prisma: PrismaService);
    create(data: Prisma.UserCreateInput): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    updateRole(id: string, role: Role): Promise<User>;
    getUserEvents(userId: string): Promise<{
        id: string;
        videoUrl: string | null;
        thumbnailUrl: string;
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
        eventId: string;
        userId: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
    })[]>;
}
