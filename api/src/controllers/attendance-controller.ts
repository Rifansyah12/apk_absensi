import { Response } from 'express';
import { AuthRequest, AttendanceFormDataRequest } from '../types';
import { AttendanceService } from '../services/attendance-service';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const attendanceService = new AttendanceService();

export class AttendanceController {
  async checkIn(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Handle form-data request
      const { lat, lng } = req.body as AttendanceFormDataRequest;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          message: 'Latitude dan longitude diperlukan',
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'Foto selfie diperlukan',
        });
        return;
      }

      const location = `${lat},${lng}`;
      const date = new Date();

      const attendance = await attendanceService.checkIn(req.user.id, {
        date,
        location,
        selfie: req.file.buffer, // Kirim buffer file langsung
        note: req.body.note || '',
      });

      res.json({
        success: true,
        message: 'Check-in berhasil',
        data: attendance,
      });
    } catch (error: any) {
      console.error('Check-in error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Check-in gagal',
      });
    }
  }

  async checkOut(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Handle form-data request
      const { lat, lng } = req.body as AttendanceFormDataRequest;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          message: 'Latitude dan longitude diperlukan',
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: 'Foto selfie diperlukan',
        });
        return;
      }

      const location = `${lat},${lng}`;
      const date = new Date();

      const attendance = await attendanceService.checkOut(req.user.id, {
        date,
        location,
        selfie: req.file.buffer, // Kirim buffer file langsung
      });

      res.json({
        success: true,
        message: 'Check-out berhasil',
        data: attendance,
      });
    } catch (error: any) {
      console.error('Check-out error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Check-out gagal',
      });
    }
  }

  async getAttendanceHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { startDate, endDate } = req.query;
      const start = startDate ? new Date(startDate as string) : new Date();
      const end = endDate ? new Date(endDate as string) : new Date();

      start.setDate(start.getDate() - 30); // Default to last 30 days

      const attendances = await attendanceService.getAttendanceHistory(
        req.user.id,
        start,
        end
      );
      res.json({
        success: true,
        data: attendances,
      });
    } catch (error: any) {
      console.error('Get attendance history error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get attendance history',
      });
    }
  }

  async getAttendanceSummary(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { month, year } = req.query;
      const currentDate = new Date();
      const targetMonth = month ? parseInt(month as string) : currentDate.getMonth() + 1;
      const targetYear = year ? parseInt(year as string) : currentDate.getFullYear();

      const summary = await attendanceService.getAttendanceSummary(
        req.user.id,
        targetMonth,
        targetYear
      );

      res.json({
        success: true,
        data: summary,
      });
    } catch (error: any) {
      console.error('Get attendance summary error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get attendance summary',
      });
    }
  }

  async manualAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId, date, checkIn, checkOut, reason } = req.body;

      // Ambil division user yang akan dibuatkan absensi manual
      const targetUser = await prisma.user.findUnique({
        where: { id: Number(userId) },
        select: { division: true }
      });

      if (!targetUser) {
        res.status(404).json({
          success: false,
          message: 'Target user not found',
        });
        return;
      }

      // Opsional: super admin hanya boleh input untuk division yang sama
      // Jika tidak butuh, HAPUS kondisi ini
      if (req.user?.division !== targetUser.division) {
        res.status(403).json({
          success: false,
          message: 'You cannot record attendance for another division',
        });
        return;
      }

      const attendance = await prisma.attendance.create({
        data: {
          userId: Number(userId),
          date: new Date(date),
          checkIn: checkIn ? new Date(checkIn) : null,
          checkOut: checkOut ? new Date(checkOut) : null,
          status: 'PRESENT',
          notes: `Manual entry: ${reason}`,
        },
      });

      res.json({
        success: true,
        message: 'Manual attendance recorded successfully',
        data: attendance,
      });

    } catch (error: any) {
      console.error('Manual attendance error:', error);

      res.status(400).json({
        success: false,
        message: error.message || 'Failed to record manual attendance',
      });
    }
  }

  async getTodayAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const attendance = await prisma.attendance.findFirst({
        where: {
          userId: req.user.id,
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      });

      res.json({
        success: true,
        data: attendance,
      });
    } catch (error: any) {
      console.error('Get today attendance error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to get today attendance',
      });
    }
  }

  async getAttendanceHistoryByDivision(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
      }

      const { startDate, endDate } = req.query;

      let start: Date;
      let end: Date;

      if (startDate && endDate) {
        start = new Date(startDate as string);
        end = new Date(endDate as string);
      } else {
        // Default: 30 hari ke belakang
        end = new Date();
        start = new Date();
        start.setDate(start.getDate() - 30);
      }

      const attendances = await attendanceService.getAttendanceHistoryByDivision(
        req.user!.division,
        start,
        end
      );

      res.json({
        success: true,
        data: attendances,
      });
    } catch (error: any) {
      console.error("Get attendance history error:", error);
      res.status(400).json({
        success: false,
        message: error.message || "Failed to get attendance history",
      });
    }
  }

  async deleteAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { id } = req.params;

      // Validasi parameter
      if (!id || isNaN(parseInt(id))) {
        res.status(400).json({
          success: false,
          message: 'Invalid attendance ID',
        });
        return;
      }

      const attendanceId = parseInt(id);

      // Optional: Cek apakah user memiliki akses untuk menghapus attendance ini
      // (jika diperlukan authorization tambahan)
      const attendance = await prisma.attendance.findUnique({
        where: { id: attendanceId },
        include: { user: true }
      });

      if (attendance) {
        // Cek jika admin hanya bisa menghapus attendance di division yang sama
        if (attendance.user.division !== req.user.division) {
          res.status(403).json({
            success: false,
            message: 'You cannot delete attendance from another division',
          });
          return;
        }
      }

      await attendanceService.deleteAttendance(attendanceId);

      res.json({
        success: true,
        message: 'Attendance record deleted successfully',
      });
    } catch (error: any) {
      console.error('Delete attendance error:', error);

      // Handle different types of errors
      if (error.message.includes('not found')) {
        res.status(404).json({
          success: false,
          message: error.message,
        });
      } else if (error.code === 'P2025') {
        res.status(404).json({
          success: false,
          message: 'Attendance record not found',
        });
      } else {
        res.status(400).json({
          success: false,
          message: error.message || 'Failed to delete attendance record',
        });
      }
    }
  }

  async updateManualAttendance(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { attendanceId, checkIn, checkOut, reason } = req.body;

      if (!attendanceId) {
        res.status(400).json({
          success: false,
          message: 'Attendance ID is required',
        });
        return;
      }

      // Cek apakah attendance exists
      const existingAttendance = await prisma.attendance.findUnique({
        where: { id: Number(attendanceId) },
        include: { user: true }
      });

      if (!existingAttendance) {
        res.status(404).json({
          success: false,
          message: 'Attendance record not found',
        });
        return;
      }

      // Authorization check - hanya bisa edit attendance di division yang sama
      if (existingAttendance.user.division !== req.user?.division) {
        res.status(403).json({
          success: false,
          message: 'You cannot edit attendance from another division',
        });
        return;
      }

      // Update data
      const updatedAttendance = await prisma.attendance.update({
        where: { id: Number(attendanceId) },
        data: {
          checkIn: checkIn ? new Date(checkIn) : null,
          checkOut: checkOut ? new Date(checkOut) : null,
          notes: reason || null,
          // Recalculate status based on new times if needed
          // Anda bisa menambahkan logic untuk recalculate lateMinutes, overtimeMinutes, status
        },
      });

      res.json({
        success: true,
        message: 'Manual attendance updated successfully',
        data: updatedAttendance,
      });

    } catch (error: any) {
      console.error('Update manual attendance error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to update manual attendance',
      });
    }
  }
}