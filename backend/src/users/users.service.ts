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
