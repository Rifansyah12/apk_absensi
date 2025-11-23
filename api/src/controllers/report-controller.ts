import { Response } from 'express';
import { AuthRequest } from '../types';
import { ReportService } from '../services/report-service';
import { ExportUtils } from '../utils/export';

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

      const report = await reportService.generateAttendanceReport(req.user.division, filters);

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

  async exportAttendanceReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const filters = {
        startDate: req.query.startDate as string,
        endDate: req.query.endDate as string,
        division: req.query.division as any,
        employeeId: req.query.employeeId as string,
        type: req.query.type as 'daily' | 'weekly' | 'monthly',
      };

      const format = req.query.format as 'excel' | 'pdf';
      const report = await reportService.generateAttendanceReport(req.user.division, filters);

      const columns = [
        { header: 'Nama', key: 'nama', width: 20 },
        { header: 'Jabatan', key: 'jabatan', width: 20 },
        { header: 'Tanggal', key: 'tanggal', width: 15 },
        { header: 'Jam Masuk', key: 'jamMasuk', width: 15 },
        { header: 'Jam Pulang', key: 'jamPulang', width: 15 },
        { header: 'Terlambat (menit)', key: 'terlambat', width: 15 },
        { header: 'Lembur (jam)', key: 'lembur', width: 15 },
        { header: 'Potongan', key: 'potongan', width: 15 },
        { header: 'Total Gaji', key: 'totalGaji', width: 15 },
        { header: 'Lokasi', key: 'lokasi', width: 20 },
      ];

      const filename = `Laporan_Absensi_${filters.startDate}_to_${filters.endDate}`;

      if (format === 'excel') {
        await ExportUtils.exportToExcel(report, columns, filename, res);
      } else if (format === 'pdf') {
        ExportUtils.exportToPDF(report, columns, filename, res); // Perhatikan parameter terakhir
      } else {
        res.status(400).json({
          success: false,
          message: 'Format must be excel or pdf',
        });
      }
    } catch (error: any) {
      console.error('Export attendance report error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  // Di ReportController - exportSalaryReport method
  async exportSalaryReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { month, year, division } = req.query;
      const format = req.query.format as 'excel' | 'pdf';

      const report = await reportService.generateSalaryReport(
        parseInt(month as string) || new Date().getMonth() + 1,
        parseInt(year as string) || new Date().getFullYear(),
        division as any
      );

      const columns = [
        { header: 'Nama', key: 'nama', width: 25 },
        { header: 'Jabatan', key: 'jabatan', width: 25 },
        { header: 'Divisi', key: 'divisi', width: 15 },
        { header: 'Gaji Pokok', key: 'gajiPokok', width: 20 },
        { header: 'Lembur', key: 'lembur', width: 15 },
        { header: 'Potongan', key: 'potongan', width: 15 },
        { header: 'Total Gaji', key: 'totalGaji', width: 20 },
      ];

      const monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      const monthName = monthNames[parseInt(month as string) - 1] || '';

      const filename = `Laporan_Gaji_${monthName}_${year}`;

      if (format === 'excel') {
        await ExportUtils.exportToExcel(report, columns, filename, res);
      } else if (format === 'pdf') {
        ExportUtils.exportToPDF(report, columns, filename, res);
      } else {
        res.status(400).json({
          success: false,
          message: 'Format must be excel or pdf',
        });
      }
    } catch (error: any) {
      console.error('Export salary report error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }
}