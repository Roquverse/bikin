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
    updateEvent(eventId: string, organizerId: string, data: any): Promise<{
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
    deleteEvent(eventId: string, organizerId: string): Promise<{
        success: boolean;
    }>;
}
