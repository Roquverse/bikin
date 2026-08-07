"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FeedService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let FeedService = class FeedService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getFeedVideos(page = 1, limit = 10, userId, category) {
        const skip = (page - 1) * limit;
        const whereClause = {
            mediaUrl: {
                not: null,
            },
        };
        if (category && category !== 'All') {
            whereClause.category = { equals: category, mode: 'insensitive' };
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
            isLikedByMe: event.likes && event.likes.length > 0,
            isFollowingOrganizer: event.organizer.followers && event.organizer.followers.length > 0,
        }));
    }
    async getDiscoverFeed(page = 1, limit = 10, userId, category) {
        const skip = (page - 1) * limit;
        const whereClause = {};
        if (category && category !== 'All') {
            whereClause.category = { equals: category, mode: 'insensitive' };
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
            isLikedByMe: event.likes && event.likes.length > 0,
            isFollowingOrganizer: event.organizer.followers && event.organizer.followers.length > 0,
        }));
    }
    async getCategories() {
        return [
            { id: '1', name: 'Music' },
            { id: '2', name: 'Comedy' },
            { id: '3', name: 'Tech' },
            { id: '4', name: 'Food' },
            { id: '5', name: 'Sports' }
        ];
    }
};
exports.FeedService = FeedService;
exports.FeedService = FeedService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FeedService);
//# sourceMappingURL=feed.service.js.map