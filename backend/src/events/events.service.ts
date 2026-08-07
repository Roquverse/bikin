import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class EventsService {
  constructor(private readonly prisma: PrismaService) {}

  async getEventBookings(eventId: string, organizerId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }
    
    if (event.organizerId !== organizerId) {
      throw new ForbiddenException('Not authorized to view bookings for this event');
    }

    return this.prisma.ticket.findMany({
      where: { eventId },
      include: {
        user: {
          select: { id: true, name: true, email: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateEvent(eventId: string, organizerId: string, data: any) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }
    
    if (event.organizerId !== organizerId) {
      throw new ForbiddenException('Not authorized to update this event');
    }

    return this.prisma.event.update({
      where: { id: eventId },
      data,
    });
  }

  async deleteEvent(eventId: string, organizerId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }
    
    if (event.organizerId !== organizerId) {
      throw new ForbiddenException('Not authorized to delete this event');
    }

    await this.prisma.event.delete({
      where: { id: eventId },
    });

    return { success: true };
  }
}
