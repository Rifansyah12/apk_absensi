import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { sendErrorResponse } from '../utils/error-handler';

const prisma = new PrismaClient();

export class FrontDeskController {
  // Dashboard real-time kehadiran
  async getRealtimeAttendance(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Data kehadiran hari ini
      const todayAttendance = await prisma.attendance.findMany({
        where: {
          date: {
            gte: today
          }
        },
        include: {
          user: {
            select: {
              name: true,
              division: true,
              position: true
            }
          }
        },
        orderBy: {
          checkIn: 'desc'
        }
      });

      // Statistik real-time
      const totalEmployees = await prisma.user.count({
        where: { isActive: true }
      });

      const checkedIn = todayAttendance.filter(a => a.checkIn).length;
      const checkedOut = todayAttendance.filter(a => a.checkOut).length;
      const lateArrivals = todayAttendance.filter(a => a.lateMinutes > 0).length;

      res.json({
        success: true,
        data: {
          attendance: todayAttendance,
          stats: {
            totalEmployees,
            checkedIn,
            checkedOut,
            lateArrivals,
            notCheckedIn: totalEmployees - checkedIn
          },
          lastUpdated: new Date()
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Laporan keterlambatan harian
  async getDailyLateReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { date = new Date().toISOString().split('T')[0] } = req.query;

      const lateAttendances = await prisma.attendance.findMany({
        where: {
          date: new Date(date as string),
          lateMinutes: {
            gt: 0
          }
        },
        include: {
          user: {
            select: {
              name: true,
              division: true,
              position: true
            }
          }
        },
        orderBy: {
          lateMinutes: 'desc'
        }
      });

      const summary = {
        totalLate: lateAttendances.length,
        totalLateMinutes: lateAttendances.reduce((sum, a) => sum + a.lateMinutes, 0),
        averageLate: lateAttendances.length > 0 ? 
          lateAttendances.reduce((sum, a) => sum + a.lateMinutes, 0) / lateAttendances.length : 0
      };

      res.json({
        success: true,
        data: {
          lateAttendances,
          summary
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Input manual absensi oleh front desk
  async manualCheckIn(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId, checkInTime, reason } = req.body;

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Cek apakah sudah ada absensi hari ini
      const existingAttendance = await prisma.attendance.findFirst({
        where: {
          userId: parseInt(userId),
          date: {
            gte: today
          }
        }
      });

      if (existingAttendance) {
        res.status(400).json({
          success: false,
          message: 'User already has attendance record for today'
        });
        return;
      }

      const attendance = await prisma.attendance.create({
        data: {
          userId: parseInt(userId),
          date: today,
          checkIn: new Date(checkInTime),
          notes: `Manual check-in by Front Desk: ${reason}`,
          status: 'PRESENT'
        },
        include: {
          user: {
            select: {
              name: true,
              division: true
            }
          }
        }
      });

      res.json({
        success: true,
        message: 'Manual check-in recorded successfully',
        data: attendance
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Approve/reject cuti dari sisi operasional
  async processLeaveRequest(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { leaveId } = req.params;
      const { status, notes } = req.body;

      const leave = await prisma.leave.findUnique({
        where: { id: parseInt(leaveId) },
        include: {
          user: true
        }
      });

      if (!leave) {
        res.status(404).json({
          success: false,
          message: 'Leave request not found'
        });
        return;
      }

      const updatedLeave = await prisma.leave.update({
        where: { id: parseInt(leaveId) },
        data: {
          status: status as any,
          notes: notes || `Processed by Front Desk: ${status}`
        }
      });

      // Buat notifikasi
      await prisma.notification.create({
        data: {
          userId: leave.userId,
          title: `Cuti ${status === 'APPROVED' ? 'Disetujui' : 'Ditolak'}`,
          message: `Permohonan cuti Anda telah ${status === 'APPROVED' ? 'disetujui' : 'ditolak'} oleh Front Desk. Catatan: ${notes}`,
          type: status === 'APPROVED' ? 'LEAVE_APPROVED' : 'LEAVE_REJECTED'
        }
      });

      res.json({
        success: true,
        message: `Leave request ${status.toLowerCase()} successfully`,
        data: updatedLeave
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }
}

export const frontDeskController = new FrontDeskController();