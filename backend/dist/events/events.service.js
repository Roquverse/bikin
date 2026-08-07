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
    async getTicketTiers(eventId) {
        const event = await this.prisma.event.findUnique({
            where: { id: eventId },
        });
        if (!event)
            throw new common_1.NotFoundException('Event not found');
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
};
exports.EventsService = EventsService;
exports.EventsService = EventsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], EventsService);
//# sourceMappingURL=events.service.js.map