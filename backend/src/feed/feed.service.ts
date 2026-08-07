import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class FeedService {
  constructor(private readonly prisma: PrismaService) {}

  async getFeedVideos(page: number = 1, limit: number = 10, userId?: string) {
    const skip = (page - 1) * limit;

    const events = await this.prisma.event.findMany({
      where: {
        mediaUrl: {
          not: null, // Only fetch events that have videos
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      skip,
      take: limit,
      include: {
        organizer: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            followers: userId ? {
              where: { followerId: userId },
              take: 1
            } : false,
          },
        },
        _count: {
          select: {
            likes: true,
            comments: true,
            tickets: true,
          },
        },
        likes: userId ? {
          where: {
            userId,
          },
          take: 1,
        } : false,
      },
    });

    return events.map(event => ({
      id: event.id,
      date: event.date.toISOString(),
      location: event.location,
      videoUrl: event.mediaUrl,
      thumbnailUrl: event.thumbnailUrl || event.mediaUrl, // Fallback to mediaUrl
      caption: event.description || event.title,
      hashtags: [], // You can extend Prisma schema to have hashtags later
      organizerId: event.organizerId,
      organizerName: event.organizer.name,
      organizerAvatarUrl: event.organizer.avatarUrl || `https://i.pravatar.cc/150?u=${event.organizerId}`,
      likesCount: event._count.likes,
      commentsCount: event._count.comments,
      hasTickets: event.price > 0,
      isLikedByMe: event.likes && event.likes.length > 0,
      isFollowingOrganizer: event.organizer.followers && event.organizer.followers.length > 0,
    }));
  }

  async getDiscoverFeed(page: number = 1, limit: number = 10, userId?: string, location?: string) {
    const skip = (page - 1) * limit;

    const whereClause: any = {};
    if (location && location !== 'All') {
      whereClause.location = { equals: location, mode: 'insensitive' };
    }

    const events = await this.prisma.event.findMany({
      where: whereClause,
      orderBy: {
        createdAt: 'desc',
      },
      skip,
      take: limit,
      include: {
        organizer: {
          select: {
            id: true,
            name: true,
            avatarUrl: true,
            followers: userId ? {
              where: { followerId: userId },
              take: 1
            } : false,
          },
        },
        _count: {
          select: {
            likes: true,
            comments: true,
            tickets: true,
          },
        },
        likes: userId ? {
          where: {
            userId,
          },
          take: 1,
        } : false,
      },
    });

    return events.map(event => ({
      id: event.id,
      date: event.date.toISOString(),
      location: event.location,
      videoUrl: event.mediaUrl,
      thumbnailUrl: event.thumbnailUrl || event.mediaUrl, // Prefer thumbnailUrl for discovery
      caption: event.description || event.title,
      hashtags: [], 
      organizerId: event.organizerId,
      organizerName: event.organizer.name,
      organizerAvatarUrl: event.organizer.avatarUrl || `https://i.pravatar.cc/150?u=${event.organizerId}`,
      likesCount: event._count.likes,
      commentsCount: event._count.comments,
      hasTickets: event.price > 0,
      isLikedByMe: event.likes && event.likes.length > 0,
      isFollowingOrganizer: event.organizer.followers && event.organizer.followers.length > 0,
    }));
  }

  async getLocations() {
    // These are predefined locations acting as "created by admin"
    return [
      { id: '1', name: 'Lagos' },
      { id: '2', name: 'Abuja' },
      { id: '3', name: 'Ibadan' },
      { id: '4', name: 'Port Harcourt' },
      { id: '5', name: 'London' }
    ];
  }
}
