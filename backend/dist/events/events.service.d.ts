import { PrismaService } from '../common/prisma/prisma.service';
export declare class EventsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getEventBookings(eventId: string, organizerId: string): Promise<({
        user: {
            id: string;
            email: string;
            name: string;
        };
    } & {
        id: string;
        eventId: string;
        userId: string;
        status: string;
        createdAt: Date;
        updatedAt: Date;
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
