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
exports.EventsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let EventsService = class EventsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createEvent(organizerId, data) {
        if (!data.title || !data.date || !data.location) {
            throw new common_1.BadRequestException('Missing required fields: title, date, location');
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
                    create: data.tiers.map((tier) => ({
                        name: tier.name,
                        price: parseFloat(tier.price) || 0.0,
                        capacity: parseInt(tier.capacity) || 100,
                    }))
                } : undefined,
            },
        });
    }
    async getTicketTiers(eventId) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event)
            throw new common_1.NotFoundException('Event not found');
        const tiers = await this.prisma.ticketTier.findMany({
            where: { eventId },
        });
        if (tiers.length > 0) {
            return tiers.map(t => ({
                id: t.id,
                name: t.name,
                price: t.price,
                availableQuantity: t.capacity,
            }));
        }
        return [
            {
                id: 't1',
                name: 'General Admission',
                price: event.price,
                availableQuantity: 100,
            }
        ];
    }
    async bookTickets(eventId, userId, data) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event)
            throw new common_1.NotFoundException('Event not found');
        let successCount = 0;
        if (data.selectedTiers && Object.keys(data.selectedTiers).length > 0) {
            for (const [tierId, count] of Object.entries(data.selectedTiers)) {
                const qty = count;
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
        }
        else {
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
    async getEventBookings(eventId, organizerId) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
        }
        if (event.organizerId !== organizerId) {
            throw new common_1.ForbiddenException('Not authorized to view bookings for this event');
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
    async updateEvent(eventId, organizerId, data) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
        }
        if (event.organizerId !== organizerId) {
            throw new common_1.ForbiddenException('Not authorized to update this event');
        }
        return this.prisma.event.update({
            where: { id: eventId },
            data,
        });
    }
    async deleteEvent(eventId, organizerId) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
        }
        if (event.organizerId !== organizerId) {
            throw new common_1.ForbiddenException('Not authorized to delete this event');
        }
        await this.prisma.event.delete({
            where: { id: eventId },
        });
        return { success: true };
    }
    async getEventComments(eventId) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
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
    async addEventComment(eventId, userId, data) {
        if (!data.text) {
            throw new common_1.BadRequestException('Comment text is required');
        }
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
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
    async toggleLike(eventId, userId, isLiked) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event) {
            throw new common_1.NotFoundException('Event not found');
        }
        if (isLiked) {
            try {
                await this.prisma.like.create({
                    data: {
                        eventId,
                        userId,
                    },
                });
            }
            catch (e) {
            }
        }
        else {
            await this.prisma.like.deleteMany({
                where: {
                    eventId,
                    userId,
                },
            });
        }
        return { success: true };
    }
};
exports.EventsService = EventsService;
exports.EventsService = EventsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], EventsService);
//# sourceMappingURL=events.service.js.map