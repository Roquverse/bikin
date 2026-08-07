import { Controller, Get, UseGuards, Request } from '@nestjs/common';
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
