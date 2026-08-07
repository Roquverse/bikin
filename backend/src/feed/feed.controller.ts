import { Controller, Get, Query, UseGuards, Req } from '@nestjs/common';
import { FeedService } from './feed.service';
import { OptionalJwtAuthGuard } from '../auth/guards/optional-jwt-auth.guard';
import type { Request } from 'express';

@Controller('feed')
export class FeedController {
  constructor(private readonly feedService: FeedService) {}

  @UseGuards(OptionalJwtAuthGuard)
  @Get()
  async getFeed(@Query('page') page: string, @Req() req: Request) {
    const pageNumber = page ? parseInt(page, 10) : 1;
  async getFeed(@Query('page') page: string, @Query('category') category: string, @Req() req: Request) {
    const pageNumber = page ? parseInt(page, 10) : 1;
    const userId = (req.user as any)?.id;
    return this.feedService.getFeed(pageNumber, 10, userId, category);
  }

  @UseGuards(OptionalJwtAuthGuard)
  @Get('discover')
  async getDiscoverFeed(@Query('page') page: string, @Req() req: Request) {
    const pageNumber = page ? parseInt(page, 10) : 1;
    const userId = (req.user as any)?.id;
    return this.feedService.getDiscoverFeed(pageNumber, 10, userId);
  }

  @Get('categories')
  async getCategories() {
    return this.feedService.getCategories();
  }
}
