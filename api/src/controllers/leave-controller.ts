import { Response } from 'express';
import { AuthRequest, LeaveRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { sendNotification } from '../utils/notification';

const prisma = new PrismaClient();

export class LeaveController {
  async requestLeave(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { startDate, endDate, type, reason }: LeaveRequest = req.body;

      const leave = await prisma.leave.create({
        data: {
          userId: req.user.id,
          startDate: new Date(startDate),
          endDate: new Date(endDate),
          type: type as any,
          reason,
          status: 'PENDING',
        },
      });

      res.json({
        success: true,
        message: 'Leave request submitted successfully',
        data: leave,
      });
    } catch (error: any) {
      console.error('Leave request error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to submit leave request',
      });
    }
  }

  async getMyLeaves(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const leaves = await prisma.leave.findMany({
        where: { userId: req.user.id },
        orderBy: { createdAt: 'desc' },
      });

      res.json({
        success: true,
        data: leaves,
      });
    } catch (error: any) {
      console.error('Get leaves error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get leave requests',
      });
    }
  }

  async approveRejectLeave(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { leaveId } = req.params;
      const { status, notes } = req.body;

      if (!['APPROVED', 'REJECTED'].includes(status)) {
        res.status(400).json({
          success: false,
          message: 'Status must be APPROVED or REJECTED',
        });
        return;
      }

      const leave = await prisma.leave.update({
        where: { id: parseInt(leaveId) },
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
        leave.userId,
        `Cuti ${status === 'APPROVED' ? 'Disetujui' : 'Ditolak'}`,
        `Permohonan cuti Anda ${status === 'APPROVED' ? 'telah disetujui' : 'ditolak'}.${notes ? ` Catatan: ${notes}` : ''}`,
        status === 'APPROVED' ? 'LEAVE_APPROVED' : 'LEAVE_REJECTED'
      );

      res.json({
        success: true,
        message: `Leave ${status.toLowerCase()} successfully`,
        data: leave,
      });
    } catch (error: any) {
      console.error('Approve/reject leave error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to update leave status',
      });
    }
  }

  async getPendingLeaves(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const leaves = await prisma.leave.findMany({
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
        data: leaves,
      });
    } catch (error: any) {
      console.error('Get pending leaves error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get pending leaves',
      });
    }
  }
}