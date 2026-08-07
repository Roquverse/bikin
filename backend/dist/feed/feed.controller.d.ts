import { FeedService } from './feed.service';
import type { Request } from 'express';
export declare class FeedController {
    private readonly feedService;
    constructor(feedService: FeedService);
    getFeed(page: string, req: Request): Promise<any>;
}
