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
var MailService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MailService = void 0;
const common_1 = require("@nestjs/common");
const nodemailer = __importStar(require("nodemailer"));
let MailService = MailService_1 = class MailService {
    constructor() {
        this.logger = new common_1.Logger(MailService_1.name);
        this.transporter = null;
        const host = process.env.SMTP_HOST;
        const port = process.env.SMTP_PORT;
        const user = process.env.SMTP_USER;
        const pass = process.env.SMTP_PASS;
        if (host && port && user && pass) {
            this.transporter = nodemailer.createTransport({
                host,
                port: parseInt(port, 10),
                secure: parseInt(port, 10) === 465,
                auth: {
                    user,
                    pass,
                },
            });
            this.logger.log('📧 MailService initialized with SMTP transport.');
        }
        else {
            this.logger.warn('📧 MailService: SMTP credentials missing. Emails will be logged to the console.');
        }
    }
    async sendOtpEmail(to, otpCode, userName) {
        const subject = 'Your Bikin Verification Code';
        const text = `Hello ${userName},\n\nYour 6-digit verification code is: ${otpCode}\n\nThis code will expire in 5 minutes. If you did not request this code, please ignore this email.\n\nBest regards,\nThe Bikin Team`;
        const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
        <h2 style="color: #ff3366; text-align: center;">Welcome to Bikin!</h2>
        <p>Hello <strong>${userName}</strong>,</p>
        <p>Your 6-digit email verification code is:</p>
        <div style="background-color: #f9f9f9; border: 1px dashed #ff3366; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 4px; color: #333; margin: 20px 0; border-radius: 4px;">
          ${otpCode}
        </div>
        <p>This code will expire in <strong>5 minutes</strong>.</p>
        <p>If you did not request this verification code, please ignore this email.</p>
        <br/>
        <hr style="border: none; border-top: 1px solid #eee;" />
        <p style="font-size: 12px; color: #888; text-align: center;">This is an automated message, please do not reply directly.</p>
      </div>
    `;
        if (this.transporter) {
            try {
                await this.transporter.sendMail({
                    from: process.env.SMTP_FROM || '"Bikin App" <noreply@bikin.app>',
                    to,
                    subject,
                    text,
                    html,
                });
                this.logger.log(`📧 OTP Email successfully sent to ${to}`);
            }
            catch (error) {
                this.logger.error(`❌ Failed to send OTP email to ${to}: ${error.message}`);
            }
        }
        else {
            this.logger.log(`
=========================================
📧 EMAIL LOG (MOCK DEVELOPMENT SENDER)
To: ${to}
Subject: ${subject}
Code: ${otpCode}
=========================================
`);
        }
    }
};
exports.MailService = MailService;
exports.MailService = MailService = MailService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [])
], MailService);
//# sourceMappingURL=mail.service.js.map