import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RedisService } from '../common/redis/redis.service';
import { MailService } from '../common/mail/mail.service';
export declare class AuthService {
    private usersService;
    private jwtService;
    private redisService;
    private mailService;
    constructor(usersService: UsersService, jwtService: JwtService, redisService: RedisService, mailService: MailService);
    register(registerDto: RegisterDto): Promise<{
        message: string;
    }>;
    verifyOtp(verifyOtpDto: {
        email: string;
        otp: string;
    }): Promise<{
        access_token: string;
        refresh_token: string;
        user: {
            id: string;
            name: string;
            email: string;
            role: import(".prisma/client").$Enums.Role;
        };
    }>;
    login(loginDto: LoginDto): Promise<{
        access_token: string;
        refresh_token: string;
        user: {
            id: string;
            name: string;
            email: string;
            role: import(".prisma/client").$Enums.Role;
        };
    }>;
    setAccountType(userId: string, roleName: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        email: string;
        password: string;
        name: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
}
