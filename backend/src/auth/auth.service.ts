import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcrypt';
import { RedisService } from '../common/redis/redis.service';
import { MailService } from '../common/mail/mail.service';
import { Role } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private redisService: RedisService,
    private mailService: MailService,
  ) {}

  async register(registerDto: RegisterDto) {
    const existingUser = await this.usersService.findByEmail(registerDto.email);
    if (existingUser) {
      throw new ConflictException('Email is already in use');
    }

    // 1. Generate 6-digit random code
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const email = registerDto.email.toLowerCase();

    // 2. Hash password before storing temporarily
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    // 3. Store pending signup and OTP in Redis with 5 min (300 sec) TTL
    const pendingUser = {
      ...registerDto,
      email,
      password: hashedPassword,
    };

    await this.redisService.set(`PENDING_USER:${email}`, JSON.stringify(pendingUser), 'EX', 300);
    await this.redisService.set(`OTP:${email}`, otp, 'EX', 300);

    // 4. Send email alert
    await this.mailService.sendOtpEmail(email, otp, registerDto.name);

    return {
      message: 'Verification code sent to your email',
    };
  }

  async verifyOtp(verifyOtpDto: { email: string; otp: string }) {
    const email = verifyOtpDto.email.toLowerCase();
    const storedOtp = await this.redisService.get(`OTP:${email}`);

    if (!storedOtp) {
      throw new BadRequestException('Verification code has expired or is invalid');
    }

    if (storedOtp !== verifyOtpDto.otp) {
      throw new BadRequestException('Invalid verification code');
    }

    // Retrieve pending user payload
    const pendingUserDataStr = await this.redisService.get(`PENDING_USER:${email}`);
    if (!pendingUserDataStr) {
      throw new BadRequestException('Registration session expired. Please sign up again.');
    }

    const pendingUser = JSON.parse(pendingUserDataStr);

    // Register user in the database
    const user = await this.usersService.create(pendingUser);

    // Clean up Redis
    await this.redisService.del(`OTP:${email}`);
    await this.redisService.del(`PENDING_USER:${email}`);

    const payload = { sub: user.id, email: user.email, role: user.role };
    
    return {
      access_token: await this.jwtService.signAsync(payload),
      refresh_token: await this.jwtService.signAsync(payload, { expiresIn: '30d' }), // return refresh token as expected by Flutter
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      }
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.usersService.findByEmail(loginDto.email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(loginDto.password, user.password);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: user.id, email: user.email, role: user.role };

    return {
      access_token: await this.jwtService.signAsync(payload),
      refresh_token: await this.jwtService.signAsync(payload, { expiresIn: '30d' }),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      }
    };
  }

  async setAccountType(userId: string, roleName: string) {
    const role = roleName.toUpperCase() === 'ORGANIZER' ? Role.ORGANIZER : Role.ATTENDEE;
    return this.usersService.updateRole(userId, role);
  }
}
