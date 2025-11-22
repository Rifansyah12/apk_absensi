import { Response } from 'express';
import { AuthRequest, OvertimeRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { sendNotification } from '../utils/notification';

const prisma = new PrismaClient();

export class OvertimeController {
  async requestOvertime(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { date, hours, reason }: OvertimeRequest = req.body;

      const overtime = await prisma.overtime.create({
        data: {
          userId: req.user.id,
          date: new Date(date),
          hours: parseFloat(hours.toString()),
          reason,
          status: 'PENDING',
        },
      });

      res.json({
        success: true,
        message: 'Overtime request submitted successfully',
        data: overtime,
      });
    } catch (error: any) {
      console.error('Overtime request error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to submit overtime request',
      });
    }
  }

  async getMyOvertime(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const overtimes = await prisma.overtime.findMany({
        where: { userId: req.user.id },
        orderBy: { createdAt: 'desc' },
      });

      res.json({
        success: true,
        data: overtimes,
      });
    } catch (error: any) {
      console.error('Get overtime error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get overtime requests',
      });
    }
  }

  async approveRejectOvertime(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { overtimeId } = req.params;
      const { status, notes } = req.body;

      if (!['APPROVED', 'REJECTED'].includes(status)) {
        res.status(400).json({
          success: false,
          message: 'Status must be APPROVED or REJECTED',
        });
        return;
      }

      const overtime = await prisma.overtime.update({
        where: { id: parseInt(overtimeId) },
        data: {
          status: status as any,
          approvedBy: req.user.id,
          notes,
        },
        include: {
          user: true,
        },
      });

      // Send notification
      await sendNotification(
        overtime.userId,
        `Lembur ${status === 'APPROVED' ? 'Disetujui' : 'Ditolak'}`,
        `Permohonan lembur Anda ${status === 'APPROVED' ? 'telah disetujui' : 'ditolak'}.${notes ? ` Catatan: ${notes}` : ''}`,
        status === 'APPROVED' ? 'OVERTIME_APPROVED' : 'OVERTIME_REJECTED'
      );

      res.json({
        success: true,
        message: `Overtime ${status.toLowerCase()} successfully`,
        data: overtime,
      });
    } catch (error: any) {
      console.error('Approve/reject overtime error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to update overtime status',
      });
    }
  }

  async getPendingOvertime(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const overtimes = await prisma.overtime.findMany({
        where: { status: 'PENDING' },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              employeeId: true,
              division: true,
              position: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      });

      res.json({
        success: true,
        data: overtimes,
      });
    } catch (error: any) {
      console.error('Get pending overtime error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get pending overtime',
      });
    }
  }
}