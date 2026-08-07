import { Controller, Get, Post, Put, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { EventsService } from './events.service';

@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  async createEvent(@Body() data: any, @Request() req) {
    return this.eventsService.createEvent(req.user.id, data);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id/tickets/tiers')
  async getTicketTiers(@Param('id') id: string) {
    return this.eventsService.getTicketTiers(id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/tickets/book')
  async bookTickets(@Param('id') id: string, @Body() data: any, @Request() req) {
    return this.eventsService.bookTickets(id, req.user.id, data);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id/bookings')
  async getBookings(@Param('id') id: string, @Request() req) {
    return this.eventsService.getEventBookings(id, req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  async updateEvent(@Param('id') id: string, @Body() data: any, @Request() req) {
    return this.eventsService.updateEvent(id, req.user.id, data);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async deleteEvent(@Param('id') id: string, @Request() req) {
    return this.eventsService.deleteEvent(id, req.user.id);
  }
}
