import nodemailer from 'nodemailer';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: parseInt(process.env.EMAIL_PORT || '587'),
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const sendNotification = async (
  userId: number,
  title: string,
  message: string,
  type: string
): Promise<void> => {
  try {
    // Save to database
    await prisma.notification.create({
      data: {
        userId,
        title,
        message,
        type: type as any,
      },
    });

    // Send email notification jika email tersedia
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
  } catch (error) {
    console.error('Error sending notification:', error);
    // Jangan throw error agar tidak mengganggu flow aplikasi utama
  }
};