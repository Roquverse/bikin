import { EventsService } from './events.service';
export declare class EventsController {
    private readonly eventsService;
    constructor(eventsService: EventsService);
    createEvent(data: any, req: any): Promise<{
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
            name: string;
            id: string;
            email: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        status: string;
        eventId: string;
        tierId: string | null;
        userId: string;
    })[]>;
    updateEvent(id: string, data: any, req: any): Promise<{
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
}
