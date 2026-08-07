"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const users_service_1 = require("../users/users.service");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcrypt"));
const redis_service_1 = require("../common/redis/redis.service");
const mail_service_1 = require("../common/mail/mail.service");
const client_1 = require("@prisma/client");
let AuthService = class AuthService {
    constructor(usersService, jwtService, redisService, mailService) {
        this.usersService = usersService;
        this.jwtService = jwtService;
        this.redisService = redisService;
        this.mailService = mailService;
    }
    async register(registerDto) {
        const existingUser = await this.usersService.findByEmail(registerDto.email);
        if (existingUser) {
            throw new common_1.ConflictException('Email is already in use');
        }
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const email = registerDto.email.toLowerCase();
        const hashedPassword = await bcrypt.hash(registerDto.password, 10);
        const pendingUser = {
            ...registerDto,
            email,
            password: hashedPassword,
        };
        await this.redisService.set(`PENDING_USER:${email}`, JSON.stringify(pendingUser), 'EX', 300);
        await this.redisService.set(`OTP:${email}`, otp, 'EX', 300);
        await this.mailService.sendOtpEmail(email, otp, registerDto.name);
        return {
            message: 'Verification code sent to your email',
        };
    }
    async verifyOtp(verifyOtpDto) {
        const email = verifyOtpDto.email.toLowerCase();
        const storedOtp = await this.redisService.get(`OTP:${email}`);
        if (!storedOtp) {
            throw new common_1.BadRequestException('Verification code has expired or is invalid');
        }
        if (storedOtp !== verifyOtpDto.otp) {
            throw new common_1.BadRequestException('Invalid verification code');
        }
        const pendingUserDataStr = await this.redisService.get(`PENDING_USER:${email}`);
        if (!pendingUserDataStr) {
            throw new common_1.BadRequestException('Registration session expired. Please sign up again.');
        }
        const pendingUser = JSON.parse(pendingUserDataStr);
        const user = await this.usersService.create(pendingUser);
        await this.redisService.del(`OTP:${email}`);
        await this.redisService.del(`PENDING_USER:${email}`);
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
    async login(loginDto) {
        const user = await this.usersService.findByEmail(loginDto.email);
        if (!user) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isMatch = await bcrypt.compare(loginDto.password, user.password);
        if (!isMatch) {
            throw new common_1.UnauthorizedException('Invalid credentials');
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
    async setAccountType(userId, roleName) {
        const role = roleName.toUpperCase() === 'ORGANIZER' ? client_1.Role.ORGANIZER : client_1.Role.ATTENDEE;
        return this.usersService.updateRole(userId, role);
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [users_service_1.UsersService,
        jwt_1.JwtService,
        redis_service_1.RedisService,
        mail_service_1.MailService])
], AuthService);
//# sourceMappingURL=auth.service.js.map