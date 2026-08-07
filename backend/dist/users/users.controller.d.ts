import { UsersService } from './users.service';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getProfile(req: any): any;
    getMyEvents(req: any): Promise<{
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
