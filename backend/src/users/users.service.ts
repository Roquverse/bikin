import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { Prisma, Role, User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return this.prisma.user.create({ data });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async updateRole(id: string, role: Role): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data: { role },
    });
  }

  async updateProfile(id: string, data: { name?: string, avatarUrl?: string, bio?: string, role?: Role }): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

  async getUserStats(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        _count: {
          select: { followers: true, following: true }
        }
      }
    });

    if (!user) {
      throw new Error('User not found');
    }

    let walletBalance = 0;
    let recentSales: {
      ticketId: string;
      buyerName: string;
      eventTitle: string;
      price: number;
      date: Date;
    }[] = [];

    if (user.role === 'ORGANIZER') {
      const events = await this.prisma.event.findMany({
        where: { organizerId: userId },
        include: {
          tickets: {
            where: { status: 'VALID' },
            include: {
              user: { select: { name: true } },
              event: { select: { title: true } }
            },
            orderBy: { createdAt: 'desc' }
          }
        }
      });

      events.forEach(event => {
        walletBalance += event.price * event.tickets.length;
        recentSales.push(...event.tickets.map(t => ({
          ticketId: t.id,
          buyerName: t.user.name,
          eventTitle: t.event.title,
          price: event.price,
          date: t.createdAt
        })));
      });

      // Sort sales globally by most recent
      recentSales.sort((a, b) => b.date.getTime() - a.date.getTime());
      recentSales = recentSales.slice(0, 10); // Top 10 recent
    }

    return {
      followersCount: user._count.followers,
      followingCount: user._count.following,
      walletBalance,
      recentSales
    };
  }

  async getUserEvents(userId: string) {
    const events = await this.prisma.event.findMany({
      where: { organizerId: userId },
      orderBy: { createdAt: 'desc' },
      include: {
        organizer: {
          select: { id: true, name: true }
        },
        _count: {
          select: { likes: true, comments: true, tickets: true }
        },
        likes: {
          where: { userId },
          take: 1
        }
      }
    });

    return events.map((event) => ({
      id: event.id,
      videoUrl: event.mediaUrl,
      thumbnailUrl: '',
      caption: event.description || event.title,
      hashtags: [],
      organizerId: event.organizerId,
      organizerName: event.organizer.name,
      organizerAvatarUrl: `https://i.pravatar.cc/150?u=${event.organizerId}`,
      likesCount: event._count.likes,
      commentsCount: event._count.comments,
      hasTickets: event.price > 0,
      isLikedByMe: event.likes && event.likes.length > 0,
      isFollowingOrganizer: false
    }));
  }

  async getUserTickets(userId: string) {
    return this.prisma.ticket.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        event: {
          include: {
            organizer: {
              select: { name: true }
            }
          }
        }
      }
    });
  }
}
