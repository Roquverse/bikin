import { Controller, Get, Put, Body, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Request() req) {
    // req.user is populated by JwtStrategy
    return req.user;
  }

  @UseGuards(JwtAuthGuard)
  @Put('me')
  async updateProfile(@Request() req, @Body() data: any) {
    return this.usersService.updateProfile(req.user.id, data);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  async getMyStats(@Request() req) {
    return this.usersService.getUserStats(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/events')
  async getMyEvents(@Request() req) {
    return this.usersService.getUserEvents(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/tickets')
  async getMyTickets(@Request() req) {
    return this.usersService.getUserTickets(req.user.id);
  }
}
