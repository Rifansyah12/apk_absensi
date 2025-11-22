import { Response } from 'express';
import { AuthRequest } from '../types';
import { ReportService } from '../services/report-service';

const reportService = new ReportService();

export class ReportController {
  async getAttendanceReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Hanya SUPER_ADMIN yang bisa akses laporan lengkap
      if (req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const filters = {
        startDate: req.query.startDate as string,
        endDate: req.query.endDate as string,
        division: req.query.division as any,
        employeeId: req.query.employeeId as string,
        type: (req.query.type as 'daily' | 'weekly' | 'monthly') || 'monthly',
      };

      const report = await reportService.generateAttendanceReport(filters);

      res.json({
        success: true,
        data: report,
      });
    } catch (error: any) {
      console.error('Get attendance report error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getSalaryReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Hanya SUPER_ADMIN yang bisa akses laporan gaji
      if (req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { month, year, division } = req.query;
      const report = await reportService.generateSalaryReport(
        parseInt(month as string) || new Date().getMonth() + 1,
        parseInt(year as string) || new Date().getFullYear(),
        division as any
      );

      res.json({
        success: true,
        data: report,
      });
    } catch (error: any) {
      console.error('Get salary report error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getDashboardStats(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { division } = req.query;
      
      // Jika user bukan SUPER_ADMIN, hanya bisa melihat stats divisinya sendiri
      const userDivision = req.user.role === 'SUPER_ADMIN' ? (division as any) : req.user.division;

      const stats = await reportService.getDashboardStats(userDivision);

      res.json({
        success: true,
        data: stats,
      });
    } catch (error: any) {
      console.error('Get dashboard stats error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getPersonalReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { month, year } = req.query;
      const targetMonth = parseInt(month as string) || new Date().getMonth() + 1;
      const targetYear = parseInt(year as string) || new Date().getFullYear();

      // User hanya bisa melihat laporan pribadi
      const summary = await reportService.getPersonalAttendanceSummary(
        req.user.id,
        targetMonth,
        targetYear
      );

      res.json({
        success: true,
        data: summary,
      });
    } catch (error: any) {
      console.error('Get personal report error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }
}