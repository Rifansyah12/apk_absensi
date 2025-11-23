import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { sendErrorResponse } from '../utils/error-handler';

const prisma = new PrismaClient();

export class ApoController {
  // Dashboard HR
  async getHRDashboard(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const today = new Date();
      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

      // Statistik kehadiran
      const attendanceStats = await prisma.attendance.groupBy({
        by: ['status'],
        where: {
          date: {
            gte: startOfMonth
          }
        },
        _count: {
          id: true
        }
      });

      // Statistik cuti
      const leaveStats = await prisma.leave.groupBy({
        by: ['status'],
        where: {
          startDate: {
            gte: startOfMonth
          }
        },
        _count: {
          id: true
        }
      });

      // Statistik karyawan
      const employeeStats = await prisma.user.groupBy({
        by: ['division'],
        where: {
          isActive: true
        },
        _count: {
          id: true
        }
      });

      res.json({
        success: true,
        data: {
          attendance: attendanceStats,
          leaves: leaveStats,
          employees: employeeStats,
          summary: {
            totalEmployees: employeeStats.reduce((sum, e) => sum + e._count.id, 0),
            pendingLeaves: leaveStats.find(l => l.status === 'PENDING')?._count.id || 0,
            attendanceRate: ((attendanceStats.find(a => a.status === 'PRESENT')?._count.id || 0) / 
              attendanceStats.reduce((sum, a) => sum + a._count.id, 1)) * 100
          }
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Validasi absensi dengan face recognition
  async validateAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { attendanceId, isValid, notes } = req.body;

      const attendance = await prisma.attendance.findUnique({
        where: { id: parseInt(attendanceId) },
        include: {
          user: true
        }
      });

      if (!attendance) {
        res.status(404).json({
          success: false,
          message: 'Attendance record not found'
        });
        return;
      }

      // Jika tidak valid, update status dan buat notifikasi
      if (!isValid) {
        await prisma.attendance.update({
          where: { id: parseInt(attendanceId) },
          data: {
            status: 'ABSENT',
            notes: `Face validation failed: ${notes}`
          }
        });

        // Buat notifikasi untuk user
        await prisma.notification.create({
          data: {
            userId: attendance.userId,
            title: 'Validasi Absen Gagal',
            message: `Absen Anda pada ${attendance.date} gagal validasi wajah. Alasan: ${notes}`,
            type: 'ATTENDANCE_FAILED'
          }
        });
      }

      res.json({
        success: true,
        message: `Attendance validation ${isValid ? 'passed' : 'failed'}`,
        data: { attendanceId, isValid }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Kelola jam kerja divisi
  async updateWorkHours(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { division } = req.params;
      const { workStart, workEnd, lateThreshold } = req.body;

      const updatedSetting = await prisma.divisionSetting.update({
        where: { division: division as any },
        data: {
          workStart,
          workEnd,
          lateThreshold
        }
      });

      res.json({
        success: true,
        message: 'Work hours updated successfully',
        data: updatedSetting
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Riwayat absensi seluruh karyawan
  async getAllAttendanceHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { startDate, endDate, division, page = 1, limit = 20 } = req.query;

      const whereClause: any = {
        date: {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        }
      };

      if (division) {
        whereClause.user = {
          division: division as string
        };
      }

      const attendances = await prisma.attendance.findMany({
        where: whereClause,
        include: {
          user: {
            select: {
              name: true,
              division: true,
              position: true
            }
          }
        },
        skip: (parseInt(page as string) - 1) * parseInt(limit as string),
        take: parseInt(limit as string),
        orderBy: {
          date: 'desc'
        }
      });

      const total = await prisma.attendance.count({ where: whereClause });

      res.json({
        success: true,
        data: attendances,
        meta: {
          page: parseInt(page as string),
          limit: parseInt(limit as string),
          total,
          totalPages: Math.ceil(total / parseInt(limit as string))
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Upload foto karyawan
  async uploadEmployeePhoto(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId } = req.params;
      
      // Di sini Anda akan menangani upload file
      // Contoh sederhana - asumsi file sudah diupload dan path disimpan
      const photoPath = req.body.photoPath; // atau dari multer

      const updatedUser = await prisma.user.update({
        where: { id: parseInt(userId) },
        data: { photo: photoPath },
        select: {
          id: true,
          name: true,
          email: true,
          photo: true
        }
      });

      res.json({
        success: true,
        message: 'Employee photo uploaded successfully',
        data: updatedUser
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }
}

export const apoController = new ApoController();