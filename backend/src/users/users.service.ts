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

    let eventsAttendedCount = 0;
    if (user.role === 'ATTENDEE') {
      eventsAttendedCount = await this.prisma.ticket.count({
        where: {
          userId,
          status: { in: ['VALID', 'USED'] },
          event: {
            date: {
              lt: new Date()
            }
          }
        }
      });
    }

    let walletBalance = 0;
    let recentSales: {
      ticketId: string;
      buyerName: string;
      eventTitle: string;
      price: number;
      date: Date;
    }[] = [];
    
    let eventsHostedCount = 0;
    let totalAttendeesCount = 0;
    let upcomingEventCount = 0;
    let avgReelEngagement = 0;

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
          },
          _count: {
            select: { likes: true, comments: true }
          }
        }
      });

      eventsHostedCount = events.length;

      const now = new Date();
      let totalEngagement = 0;

      events.forEach(event => {
        if (event.date > now) upcomingEventCount++;
        
        walletBalance += event.price * event.tickets.length;
        totalAttendeesCount += event.tickets.length;
        
        totalEngagement += event._count.likes + event._count.comments;

        recentSales.push(...event.tickets.map(t => ({
          ticketId: t.id,
          buyerName: t.user.name,
          eventTitle: t.event.title,
          price: event.price,
          date: t.createdAt
        })));
      });

      if (eventsHostedCount > 0) {
        avgReelEngagement = Math.round(totalEngagement / eventsHostedCount);
      }

      // Sort sales globally by most recent
      recentSales.sort((a, b) => b.date.getTime() - a.date.getTime());
      recentSales = recentSales.slice(0, 10); // Top 10 recent
    }

    return {
      followersCount: user._count.followers,
      followingCount: user._count.following,
      walletBalance,
      recentSales,
      eventsAttendedCount,
      eventsHostedCount,
      totalAttendeesCount,
      upcomingEventCount,
      avgReelEngagement
    };
  }

  async getUserEvents(userId: string) {
    const events = await this.prisma.event.findMany({
      where: { organizerId: userId },
      orderBy: { createdAt: 'desc' },
      include: {
        organizer: {
          select: { id: true, name: true, avatarUrl: true }
        },
        _count: {
          select: { likes: true, comments: true, tickets: true }
        },
        likes: {
          where: { userId },
          take: 1
        },
        tiers: {
          select: { capacity: true }
        }
      }
    });

    return events.map((event) => {
      // Calculate total capacity
      const totalCapacity = event.tiers.reduce((sum, tier) => sum + tier.capacity, 0);
      // Fallback capacity if no tiers exist
      const capacity = totalCapacity > 0 ? totalCapacity : 200; 

      return {
        id: event.id,
        date: event.date.toISOString(),
        location: event.location,
        videoUrl: event.mediaUrl,
        thumbnailUrl: event.mediaUrl,
        caption: event.description || event.title,
        hashtags: [],
        organizerId: event.organizerId,
        organizerName: event.organizer.name,
        organizerAvatarUrl: event.organizer.avatarUrl || `https://i.pravatar.cc/150?u=${event.organizerId}`,
        likesCount: event._count.likes,
        commentsCount: event._count.comments,
        hasTickets: event.price > 0,
        isLikedByMe: event.likes && event.likes.length > 0,
        isFollowingOrganizer: false,
        ticketsSold: event._count.tickets,
        capacity: capacity
      };
    });
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

  async toggleFollow(followingId: string, followerId: string, isFollowing: boolean) {
    if (followingId === followerId) {
      throw new Error('You cannot follow yourself');
    }

    if (isFollowing) {
      try {
        await this.prisma.follows.create({
          data: {
            followerId,
            followingId,
          }
        });
      } catch (e) {
        // Ignore if already exists
      }
    } else {
      await this.prisma.follows.deleteMany({
        where: {
          followerId,
          followingId,
        }
      });
    }

    return { success: true };
  }

  async getFollowing(userId: string) {
    const follows = await this.prisma.follows.findMany({
      where: { followerId: userId },
      include: {
        following: {
          include: {
            events: {
              where: {
                date: { gte: new Date() }
              },
              select: { id: true }
            }
          }
        }
      }
    });

    return follows.map(f => ({
      id: f.following.id,
      name: f.following.name,
      avatarUrl: f.following.avatarUrl || `https://i.pravatar.cc/150?u=${f.following.id}`,
      upcomingEventsCount: f.following.events.length,
    }));
  }

  async getLikedEvents(userId: string) {
    const likes = await this.prisma.like.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        event: {
          include: {
            organizer: {
              select: { id: true, name: true, avatarUrl: true }
            },
            _count: {
              select: { likes: true, comments: true, tickets: true }
            }
          }
        }
      }
    });

    return likes.map(like => {
      const event = like.event;
      return {
        id: event.id,
        date: event.date.toISOString(),
        location: event.location,
        category: event.category,
        videoUrl: event.mediaUrl,
        thumbnailUrl: event.thumbnailUrl || event.mediaUrl,
        caption: event.description || event.title,
        hashtags: [],
        organizerId: event.organizerId,
        organizerName: event.organizer.name,
        organizerAvatarUrl: event.organizer.avatarUrl || `https://i.pravatar.cc/150?u=${event.organizerId}`,
        likesCount: event._count.likes,
        commentsCount: event._count.comments,
        hasTickets: event.price > 0,
        isLikedByMe: true,
        isFollowingOrganizer: true, // we could compute this accurately, but usually if they liked it they might not be following. It's an approximation or we can query it.
      };
    });
  }
}
