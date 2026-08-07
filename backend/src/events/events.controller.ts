import { Controller, Get, Put, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { EventsService } from './events.service';

@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

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
