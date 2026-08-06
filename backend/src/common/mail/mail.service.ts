import { Injectable, Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;

  constructor() {
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT;
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;

    if (host && port && user && pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port: parseInt(port, 10),
        secure: parseInt(port, 10) === 465, // true for 465, false for other ports
        auth: {
          user,
          pass,
        },
      });
      this.logger.log('📧 MailService initialized with SMTP transport.');
    } else {
      this.logger.warn('📧 MailService: SMTP credentials missing. Emails will be logged to the console.');
    }
  }

  async sendOtpEmail(to: string, otpCode: string, userName: string) {
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
      } catch (error) {
        this.logger.error(`❌ Failed to send OTP email to ${to}: ${error.message}`);
      }
    } else {
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
}
