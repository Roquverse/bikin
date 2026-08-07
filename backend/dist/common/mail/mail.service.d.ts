export declare class MailService {
    private readonly logger;
    private transporter;
    constructor();
    sendOtpEmail(to: string, otpCode: string, userName: string): Promise<void>;
}
