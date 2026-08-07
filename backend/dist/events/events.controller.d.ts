import { EventsService } from './events.service';
export declare class EventsController {
    private readonly eventsService;
    constructor(eventsService: EventsService);
    createEvent(data: any, req: any): Promise<{
        id: string;
        title: string;
        description: string;
        date: Date;
        location: string;
        mediaUrl: string | null;
        thumbnailUrl: string | null;
        price: number;
        createdAt: Date;
        updatedAt: Date;
        organizerId: string;
    }>;
    getTicketTiers(id: string): Promise<{
        id: string;
        name: string;
        price: number;
        availableQuantity: number;
    }[]>;
    bookTickets(id: string, data: any, req: any): Promise<{
        success: boolean;
        ticketsBooked: number;
    }>;
    getBookings(id: string, req: any): Promise<({
        user: {
            id: string;
            name: string;
            email: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        eventId: string;
        userId: string;
        tierId: string | null;
        status: string;
    })[]>;
    updateEvent(id: string, data: any, req: any): Promise<{
        id: string;
        title: string;
        description: string;
        date: Date;
        location: string;
        mediaUrl: string | null;
        thumbnailUrl: string | null;
        price: number;
        createdAt: Date;
        updatedAt: Date;
        organizerId: string;
    }>;
    deleteEvent(id: string, req: any): Promise<{
        success: boolean;
    }>;
    getComments(id: string): Promise<{
        id: string;
        userId: string;
        userName: string;
        userAvatarUrl: string;
        text: string;
        createdAt: Date;
        isOrganizer: boolean;
    }[]>;
    addComment(id: string, data: any, req: any): Promise<{
        id: string;
        userId: string;
        userName: string;
        userAvatarUrl: string;
        text: string;
        createdAt: Date;
        isOrganizer: boolean;
    }>;
    toggleLike(id: string, isLiked: boolean, req: any): Promise<{
        success: boolean;
    }>;
}
