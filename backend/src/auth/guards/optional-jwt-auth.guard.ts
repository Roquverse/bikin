import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  // Override handleRequest so it doesn't throw an error when no token is provided
  handleRequest(err: any, user: any, info: any) {
    // return user if found, otherwise return null
    return user || null;
  }
}
