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
        price: number;
        createdAt: Date;
        updatedAt: Date;
        organizerId: string;
    }>;
    getTicketTiers(id: string): Promise<any>;
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
        status: string;
    })[]>;
    updateEvent(id: string, data: any, req: any): Promise<{
        id: string;
        title: string;
        description: string;
        date: Date;
        location: string;
        mediaUrl: string | null;
        price: number;
        createdAt: Date;
        updatedAt: Date;
        organizerId: string;
    }>;
    deleteEvent(id: string, req: any): Promise<{
        success: boolean;
    }>;
}
