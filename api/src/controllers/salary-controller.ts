import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { calculateSalary } from '../utils/decision-tree';
import { sendNotification } from '../utils/notification';

const prisma = new PrismaClient();

export class SalaryController {
  async getMySalaries(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const salaries = await prisma.salary.findMany({
        where: { userId: req.user.id },
        orderBy: [{ year: 'desc' }, { month: 'desc' }],
      });

      res.json({
        success: true,
        data: salaries,
      });
    } catch (error: any) {
      console.error('Get salaries error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getSalaryById(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const { id } = req.params;
      const salary = await prisma.salary.findUnique({
        where: { id: parseInt(id) },
      });

      if (!salary) {
        res.status(404).json({
          success: false,
          message: 'Salary not found',
        });
        return;
      }

      // Jika bukan super admin, hanya bisa melihat data sendiri
      if (req.user.role !== 'SUPER_ADMIN' && req.user.id !== salary.userId) {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      res.json({
        success: true,
        data: salary,
      });
    } catch (error: any) {
      console.error('Get salary by id error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async calculateSalary(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { month, year } = req.body;

      if (!month || !year) {
        res.status(400).json({
          success: false,
          message: 'Month and year are required',
        });
        return;
      }

      // Ambil semua user aktif
      const users = await prisma.user.findMany({
        where: { isActive: true },
      });

      const results = [];

      for (const user of users) {
        try {
          // Ambil data attendance dan overtime untuk bulan dan tahun tersebut
          const startDate = new Date(year, month - 1, 1);
          const endDate = new Date(year, month, 0);

          const attendances = await prisma.attendance.findMany({
            where: {
              userId: user.id,
              date: {
                gte: startDate,
                lte: endDate,
              },
            },
          });

          const overtimes = await prisma.overtime.findMany({
            where: {
              userId: user.id,
              date: {
                gte: startDate,
                lte: endDate,
              },
              status: 'APPROVED',
            },
          });

          // Hitung gaji menggunakan decision tree
          const salaryData = {
            userId: user.id,
            month,
            year,
            attendances,
            overtimes,
            division: user.division,
          };

          const calculatedSalary = calculateSalary(salaryData);

          // Simpan atau update gaji - variabel salary digunakan
          await prisma.salary.upsert({
            where: {
              userId_month_year: {
                userId: user.id,
                month,
                year,
              },
            },
            update: calculatedSalary,
            create: {
              userId: user.id,
              month,
              year,
              ...calculatedSalary,
            },
          });

          // Kirim notifikasi
          await sendNotification(
            user.id,
            'Gaji Telah Dihitung',
            `Gaji untuk periode ${month}/${year} telah dihitung. Total: Rp ${calculatedSalary.totalSalary.toLocaleString('id-ID')}`,
            'SALARY_RELEASED'
          );

          results.push({
            userId: user.id,
            name: user.name,
            success: true,
            salary: calculatedSalary.totalSalary,
          });
        } catch (error: any) {
          console.error(`Error calculating salary for user ${user.id}:`, error);
          results.push({
            userId: user.id,
            name: user.name,
            success: false,
            error: error.message,
          });
        }
      }

      res.json({
        success: true,
        message: 'Salary calculation completed',
        data: {
          processed: results.length,
          results,
        },
      });
    } catch (error: any) {
      console.error('Calculate salary error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }
}