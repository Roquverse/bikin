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
    // req.user will be populated if token is provided and valid, otherwise undefined
    const userId = (req.user as any)?.id;
    return this.feedService.getFeedVideos(pageNumber, 10, userId);
  }

  @UseGuards(OptionalJwtAuthGuard)
  @Get('discover')
  async getDiscoverFeed(@Query('page') page: string, @Req() req: Request) {
    const pageNumber = page ? parseInt(page, 10) : 1;
    const userId = (req.user as any)?.id;
    return this.feedService.getDiscoverFeed(pageNumber, 10, userId);
  }
}
