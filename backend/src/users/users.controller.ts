import { Controller, Get, Put, Post, Body, UseGuards, Request, Param } from '@nestjs/common';
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

  @UseGuards(JwtAuthGuard)
  @Post(':id/follow')
  async toggleFollow(@Param('id') id: string, @Body('isFollowing') isFollowing: boolean, @Request() req) {
    return this.usersService.toggleFollow(id, req.user.id, isFollowing);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/following')
  async getFollowing(@Request() req) {
    return this.usersService.getFollowing(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/liked-events')
  async getLikedEvents(@Request() req) {
    return this.usersService.getLikedEvents(req.user.id);
  }
}
