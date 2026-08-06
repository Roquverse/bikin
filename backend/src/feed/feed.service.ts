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
      videoUrl: event.mediaUrl,
      thumbnailUrl: '', // Can be extended to Bunny thumbnail API later
      caption: event.description || event.title,
      hashtags: [], // You can extend Prisma schema to have hashtags later
      organizerId: event.organizerId,
      organizerName: event.organizer.name,
      organizerAvatarUrl: `https://i.pravatar.cc/150?u=${event.organizerId}`,
      likesCount: event._count.likes,
      commentsCount: event._count.comments,
      hasTickets: event._count.tickets > 0,
      isLikedByMe: event.likes && event.likes.length > 0,
      isFollowingOrganizer: false, // Can be extended with Follows table
    }));
  }
}
