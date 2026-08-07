import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class EventsService {
  constructor(private readonly prisma: PrismaService) {}

  async createEvent(organizerId: string, data: any) {
    if (!data.title || !data.date || !data.location) {
      throw new BadRequestException('Missing required fields: title, date, location');
    }
    const price = data.price ? parseFloat(data.price) : (data.tiers && data.tiers.length > 0 ? parseFloat(data.tiers[0].price) : 0.0);
    
    return this.prisma.event.create({
      data: {
        title: data.title,
        description: data.description || '',
        date: new Date(data.date),
        location: data.location,
        mediaUrl: data.mediaUrl,
        thumbnailUrl: data.thumbnailUrl,
        price: price,
        organizerId,
        tiers: data.tiers && data.tiers.length > 0 ? {
          create: data.tiers.map((tier: any) => ({
            name: tier.name,
            price: parseFloat(tier.price) || 0.0,
            capacity: parseInt(tier.capacity) || 100,
          }))
        } : undefined,
      },
    });
  }

  async getTicketTiers(eventId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    const tiers = await this.prisma.ticketTier.findMany({
      where: { eventId },
    });

    if (tiers.length > 0) {
      return tiers.map(t => ({
        id: t.id,
        name: t.name,
        price: t.price,
        availableQuantity: t.capacity, // Can be improved to compute capacity - booked tickets
      }));
    }

    // Fallback for events created before tiers existed
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

    let successCount = 0;
    
    if (data.selectedTiers && Object.keys(data.selectedTiers).length > 0) {
      for (const [tierId, count] of Object.entries(data.selectedTiers)) {
        const qty = count as number;
        for (let i = 0; i < qty; i++) {
          await this.prisma.ticket.create({
            data: {
              eventId,
              userId,
              tierId: tierId === 't1' ? null : tierId,
              status: 'VALID',
            },
          });
          successCount++;
        }
      }
    } else {
      // Fallback
      await this.prisma.ticket.create({
        data: {
          eventId,
          userId,
          status: 'VALID',
        },
      });
      successCount++;
    }
    
    return { success: true, ticketsBooked: successCount };
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

  async getEventComments(eventId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }

    const comments = await this.prisma.comment.findMany({
      where: { eventId },
      include: {
        user: {
          select: { id: true, name: true, avatarUrl: true, role: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return comments.map(c => ({
      id: c.id,
      userId: c.userId,
      userName: c.user.name,
      userAvatarUrl: c.user.avatarUrl || 'https://i.pravatar.cc/150',
      text: c.text,
      createdAt: c.createdAt,
      isOrganizer: c.user.role === 'ORGANIZER',
    }));
  }

  async addEventComment(eventId: string, userId: string, data: any) {
    if (!data.text) {
      throw new BadRequestException('Comment text is required');
    }

    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }

    const comment = await this.prisma.comment.create({
      data: {
        text: data.text,
        eventId,
        userId,
      },
      include: {
        user: {
          select: { id: true, name: true, avatarUrl: true, role: true },
        },
      },
    });

    return {
      id: comment.id,
      userId: comment.userId,
      userName: comment.user.name,
      userAvatarUrl: comment.user.avatarUrl || 'https://i.pravatar.cc/150',
      text: comment.text,
      createdAt: comment.createdAt,
      isOrganizer: comment.user.role === 'ORGANIZER',
    };
  }

  async toggleLike(eventId: string, userId: string, isLiked: boolean) {
    const event = await this.prisma.event.findUnique({
      where: { id: eventId },
    });
    
    if (!event) {
      throw new NotFoundException('Event not found');
    }

    if (isLiked) {
      try {
        await this.prisma.like.create({
          data: {
            eventId,
            userId,
          },
        });
      } catch (e) {
        // Ignore if already exists (Unique constraint failed)
      }
    } else {
      await this.prisma.like.deleteMany({
        where: {
          eventId,
          userId,
        },
      });
    }

    return { success: true };
  }
}
