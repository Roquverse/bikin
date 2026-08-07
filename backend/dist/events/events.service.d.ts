import { PrismaService } from '../common/prisma/prisma.service';
export declare class EventsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createEvent(organizerId: string, data: any): Promise<{
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
    }>;
    getTicketTiers(eventId: string): Promise<{
        id: string;
        name: string;
        price: number;
        availableQuantity: number;
    }[]>;
    bookTickets(eventId: string, userId: string, data: any): Promise<{
        success: boolean;
        ticketsBooked: number;
    }>;
    getEventBookings(eventId: string, organizerId: string): Promise<({
        user: {
            id: string;
            email: string;
            name: string;
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
    updateEvent(eventId: string, organizerId: string, data: any): Promise<{
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
    }>;
    deleteEvent(eventId: string, organizerId: string): Promise<{
        success: boolean;
    }>;
    getEventComments(eventId: string): Promise<{
        id: string;
        userId: string;
        userName: string;
        userAvatarUrl: string;
        text: string;
        createdAt: Date;
        isOrganizer: boolean;
    }[]>;
    addEventComment(eventId: string, userId: string, data: any): Promise<{
        id: string;
        userId: string;
        userName: string;
        userAvatarUrl: string;
        text: string;
        createdAt: Date;
        isOrganizer: boolean;
    }>;
    toggleLike(eventId: string, userId: string, isLiked: boolean): Promise<{
        success: boolean;
    }>;
}
