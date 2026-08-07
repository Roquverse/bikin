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
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let UsersService = class UsersService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(data) {
        return this.prisma.user.create({ data });
    }
    async findByEmail(email) {
        return this.prisma.user.findUnique({ where: { email } });
    }
    async findById(id) {
        return this.prisma.user.findUnique({ where: { id } });
    }
    async updateRole(id, role) {
        return this.prisma.user.update({
            where: { id },
            data: { role },
        });
    }
    async getUserStats(userId) {
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
        let recentSales = [];
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
            recentSales.sort((a, b) => b.date.getTime() - a.date.getTime());
            recentSales = recentSales.slice(0, 10);
        }
        return {
            followersCount: user._count.followers,
            followingCount: user._count.following,
            walletBalance,
            recentSales
        };
    }
    async getUserEvents(userId) {
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
    async getUserTickets(userId) {
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
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UsersService);
//# sourceMappingURL=users.service.js.map