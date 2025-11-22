"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendNotification = void 0;
const nodemailer_1 = __importDefault(require("nodemailer"));
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const transporter = nodemailer_1.default.createTransport({
    host: process.env.EMAIL_HOST,
    port: parseInt(process.env.EMAIL_PORT || '587'),
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});
const sendNotification = async (userId, title, message, type) => {
    try {
        await prisma.notification.create({
            data: {
                userId,
                title,
                message,
                type: type,
            },
        });
        const user = await prisma.user.findUnique({
            where: { id: userId },
        });
        if (user && user.email && process.env.EMAIL_USER) {
            await transporter.sendMail({
                from: process.env.EMAIL_USER,
                to: user.email,
                subject: title,
                html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">${title}</h2>
            <p style="color: #666; line-height: 1.6;">${message}</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="color: #999; font-size: 12px;">
              Sistem Absensi - PT. Perusahaan Contoh
            </p>
          </div>
        `,
            });
        }
    }
    catch (error) {
        console.error('Error sending notification:', error);
    }
};
exports.sendNotification = sendNotification;
//# sourceMappingURL=notification.js.map