import { Response } from 'express';
import { AuthRequest } from '../types';
import { Division, PrismaClient } from '@prisma/client';
import { sendErrorResponse } from '../utils/error-handler';
import { ReportService } from '../services/report-service';
import { ExportUtils } from '../utils/export';

const reportService = new ReportService();

const prisma = new PrismaClient();

export class FinanceController {
  // Dashboard khusus finance
  async getFinanceDashboard(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { month = new Date().getMonth() + 1, year = new Date().getFullYear() } = req.query;

      // Total payroll bulan ini
      const salaryStats = await prisma.salary.aggregate({
        where: {
          month: parseInt(month as string),
          year: parseInt(year as string)
        },
        _sum: {
          baseSalary: true,
          overtimeSalary: true,
          deduction: true,
          totalSalary: true
        },
        _count: {
          id: true
        }
      });

      // Data potongan terlambat
      const lateDeductions = await prisma.attendance.aggregate({
        where: {
          date: {
            gte: new Date(parseInt(year as string), parseInt(month as string) - 1, 1),
            lt: new Date(parseInt(year as string), parseInt(month as string), 1)
          },
          lateMinutes: {
            gt: 0
          }
        },
        _sum: {
          lateMinutes: true
        },
        _count: {
          id: true
        }
      });

      // Data lembur
      const overtimeStats = await prisma.overtime.aggregate({
        where: {
          date: {
            gte: new Date(parseInt(year as string), parseInt(month as string) - 1, 1),
            lt: new Date(parseInt(year as string), parseInt(month as string), 1)
          },
          status: 'APPROVED'
        },
        _sum: {
          hours: true
        },
        _count: {
          id: true
        }
      });

      res.json({
        success: true,
        data: {
          salarySummary: {
            totalEmployees: salaryStats._count.id,
            totalBaseSalary: salaryStats._sum.baseSalary || 0,
            totalOvertime: salaryStats._sum.overtimeSalary || 0,
            totalDeductions: salaryStats._sum.deduction || 0,
            netSalary: salaryStats._sum.totalSalary || 0
          },
          lateSummary: {
            totalLateIncidents: lateDeductions._count.id,
            totalLateMinutes: lateDeductions._sum.lateMinutes || 0,
            estimatedDeduction: (lateDeductions._sum.lateMinutes || 0) * 5000
          },
          overtimeSummary: {
            totalOvertimeHours: overtimeStats._sum.hours || 0,
            totalOvertimeCases: overtimeStats._count.id
          }
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Laporan keuangan detail
  async getFinancialReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { startDate, endDate, division } = req.query;

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

      // Data gaji
      const salaries = await prisma.salary.findMany({
        where: {
          month: new Date(startDate as string).getMonth() + 1,
          year: new Date(startDate as string).getFullYear()
        },
        include: {
          user: {
            select: {
              name: true,
              division: true,
              position: true
            }
          }
        }
      });

      // Data potongan
      const deductions = await prisma.attendance.findMany({
        where: whereClause,
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
        data: {
          salaries,
          deductions: deductions.filter(d => d.lateMinutes > 0),
          summary: {
            totalSalary: salaries.reduce((sum, s) => sum + s.totalSalary, 0),
            totalDeductions: salaries.reduce((sum, s) => sum + s.deduction, 0),
            totalOvertime: salaries.reduce((sum, s) => sum + s.overtimeSalary, 0)
          }
        }
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Atur nilai potongan
  async updateDeductionSettings(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { division } = req.params;
      const { deductionPerMinute, lateThreshold } = req.body;

      const updatedSetting = await prisma.divisionSetting.update({
        where: { division: division as Division },
        data: {
          deductionPerMinute,
          lateThreshold
        }
      });

      res.json({
        success: true,
        message: 'Deduction settings updated successfully',
        data: updatedSetting
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Input manual absensi untuk karyawan finance
  // async manualAttendance(req: AuthRequest, res: Response): Promise<void> {
  //   try {
  //     const { userId, date, checkIn, checkOut, reason } = req.body;

  //     // Validasi: hanya untuk karyawan divisi finance
  //     const user = await prisma.user.findUnique({
  //       where: { id: parseInt(userId) }
  //     });

  //     if (!user || user.division !== 'FINANCE') {
  //       res.status(400).json({
  //         success: false,
  //         message: 'Can only create manual attendance for FINANCE division employees'
  //       });
  //       return;
  //     }

  //     const attendance = await prisma.attendance.create({
  //       data: {
  //         userId: parseInt(userId),
  //         date: new Date(date),
  //         checkIn: checkIn ? new Date(checkIn) : null,
  //         checkOut: checkOut ? new Date(checkOut) : null,
  //         notes: `Manual entry: ${reason}`,
  //         status: 'PRESENT'
  //       },
  //       include: {
  //         user: {
  //           select: {
  //             name: true,
  //             division: true
  //           }
  //         }
  //       }
  //     });

  //     res.json({
  //       success: true,
  //       message: 'Manual attendance created successfully',
  //       data: attendance
  //     });
  //   } catch (error: any) {
  //     sendErrorResponse(res, error);
  //   }
  // }

  // Export laporan gaji
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

export const financeController = new FinanceController();