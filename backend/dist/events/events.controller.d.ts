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
    }>;
    getBookings(id: string, req: any): Promise<({
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
        status: string;
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
        price: number;
        organizerId: string;
    }>;
    deleteEvent(id: string, req: any): Promise<{
        success: boolean;
    }>;
}
