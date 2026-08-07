import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class EventsService {
  constructor(private readonly prisma: PrismaService) {}

  async createEvent(organizerId: string, data: any) {
    if (!data.title || !data.date || !data.location) {
      throw new BadRequestException('Missing required fields: title, date, location');
    }
    
    return this.prisma.event.create({
      data: {
        title: data.title,
        description: data.description || '',
        date: new Date(data.date),
        location: data.location,
        mediaUrl: data.mediaUrl,
        price: data.price ? parseFloat(data.price) : 0.0,
        organizerId,
      },
    });
  }

  async getTicketTiers(eventId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    return [
      {
        id: 't1',
        name: 'General Admission',
        price: event.price,
        availableQuantity: 100,
      }
    ];
  }

  async bookTickets(eventId: string, userId: string, data: any) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    let count = 1;
    if (data.selectedTiers && data.selectedTiers['t1']) {
      count = data.selectedTiers['t1'];
    }

    for (let i = 0; i < count; i++) {
      await this.prisma.ticket.create({
        data: {
          eventId,
          userId,
          status: 'VALID',
        },
      });
    }
    
    return { success: true };
  }

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
