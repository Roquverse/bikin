import { PrismaService } from '../common/prisma/prisma.service';
export declare class EventsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createEvent(organizerId: string, data: any): Promise<{
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
    getTicketTiers(eventId: string): Promise<any>;
    bookTickets(eventId: string, userId: string, data: any): Promise<{
        success: boolean;
        ticketsBooked: number;
    }>;
    getEventBookings(eventId: string, organizerId: string): Promise<({
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
    updateEvent(eventId: string, organizerId: string, data: any): Promise<{
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
    deleteEvent(eventId: string, organizerId: string): Promise<{
        success: boolean;
    }>;
}
