import { PrismaClient, Division } from '@prisma/client';
import { ReportFilter } from '../types';

const prisma = new PrismaClient();

export class ReportService {
  async generateAttendanceReport(filters: ReportFilter) {
    const { startDate, endDate, division, employeeId } = filters;

    const whereClause: any = {};

    if (startDate && endDate) {
      whereClause.date = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      };
    }

    if (division) {
      whereClause.user = {
        division: division as Division,
      };
    }

    if (employeeId) {
      whereClause.user = {
        ...whereClause.user,
        employeeId,
      };
    }

    const attendances = await prisma.attendance.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            id: true,
            employeeId: true,
            name: true,
            position: true,
            division: true,
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    });

    // Transform data for report
    const reportData = attendances.map(attendance => ({
      nama: attendance.user.name,
      jabatan: attendance.user.position,
      tanggal: attendance.date.toISOString().split('T')[0],
      jamMasuk: attendance.checkIn?.toLocaleTimeString('id-ID') || '-',
      jamPulang: attendance.checkOut?.toLocaleTimeString('id-ID') || '-',
      terlambat: attendance.lateMinutes,
      lembur: Math.round((attendance.overtimeMinutes / 60) * 100) / 100,
      potongan: this.calculateDeduction(attendance.lateMinutes, attendance.user.division),
      totalGaji: this.calculateTotalSalary(attendance),
      lokasi: attendance.locationCheckIn || attendance.locationCheckOut || '-',
    }));

    return reportData;
  }

  async getPersonalAttendanceSummary(userId: number, month: number, year: number) {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    const attendances = await prisma.attendance.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    const overtimes = await prisma.overtime.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
        status: 'APPROVED',
      },
    });

    const leaves = await prisma.leave.findMany({
      where: {
        userId,
        status: 'APPROVED',
        OR: [
          {
            startDate: { lte: endDate },
            endDate: { gte: startDate },
          },
        ],
      },
    });

    const totalPresent = attendances.filter(a =>
      a.status === 'PRESENT' || a.status === 'LATE'
    ).length;

    const totalLate = attendances.filter(a => a.status === 'LATE').length;
    const totalAbsent = attendances.filter(a => a.status === 'ABSENT').length;

    const totalLeaveDays = leaves.reduce((sum, leave) => {
      const leaveStart = new Date(leave.startDate);
      const leaveEnd = new Date(leave.endDate);
      const overlapStart = leaveStart < startDate ? startDate : leaveStart;
      const overlapEnd = leaveEnd > endDate ? endDate : leaveEnd;

      const diffTime = Math.abs(overlapEnd.getTime() - overlapStart.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

      return sum + diffDays;
    }, 0);

    const totalOvertimeHours = overtimes.reduce((sum, ot) => sum + ot.hours, 0);

    // Hitung total working days dalam bulan tersebut
    const totalWorkingDays = this.getWorkingDays(startDate, endDate);

    return {
      totalPresent,
      totalLate,
      totalAbsent,
      totalLeave: totalLeaveDays,
      totalOvertime: Math.round(totalOvertimeHours * 100) / 100,
      totalWorkingDays,
      attendanceRate: totalWorkingDays > 0 ? (totalPresent / totalWorkingDays) * 100 : 0,
    };
  }

  private getWorkingDays(startDate: Date, endDate: Date): number {
    let count = 0;
    const current = new Date(startDate);

    while (current <= endDate) {
      // Sabtu (6) dan Minggu (0) dianggap weekend
      if (current.getDay() !== 0 && current.getDay() !== 6) {
        count++;
      }
      current.setDate(current.getDate() + 1);
    }

    return count;
  }

  async generateSalaryReport(month: number, year: number, division?: Division) {
    const whereClause: any = {
      month,
      year,
    };

    if (division) {
      whereClause.user = {
        division,
      };
    }

    const salaries = await prisma.salary.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            id: true,
            employeeId: true,
            name: true,
            position: true,
            division: true,
          },
        },
      },
      orderBy: {
        user: {
          name: 'asc',
        },
      },
    });

    return salaries.map(salary => ({
      nama: salary.user.name,
      jabatan: salary.user.position,
      divisi: salary.user.division,
      gajiPokok: salary.baseSalary,
      lembur: salary.overtimeSalary,
      potongan: salary.deduction,
      totalGaji: salary.totalSalary,
      bulan: salary.month,
      tahun: salary.year,
    }));
  }

  private calculateDeduction(lateMinutes: number, division: Division): number {
    const deductionRates: Record<string, number> = {
      'FINANCE': 1000,
      'APO': 900,
      'FRONT_DESK': 800,
      'ONSITE': 850,
    };

    return lateMinutes * (deductionRates[division] || 1000);
  }

  private calculateTotalSalary(attendance: any): number {
    // Simplified calculation - in real scenario, use the salary service
    const baseSalary = 6000000; // Example base salary
    const dailySalary = baseSalary / 30; // Approximate daily salary
    const overtimeRate = 50000; // Example overtime rate per hour
    const overtimeHours = attendance.overtimeMinutes / 60;

    return dailySalary + (overtimeHours * overtimeRate) - this.calculateDeduction(attendance.lateMinutes, attendance.user.division);
  }

  async getDashboardStats(division?: Division) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const whereClause: any = {
      date: {
        gte: today,
        lt: tomorrow,
      },
    };

    if (division) {
      whereClause.user = {
        division,
      };
    }

    const todayAttendances = await prisma.attendance.findMany({
      where: whereClause,
      include: {
        user: true,
      },
    });

    const totalEmployees = await prisma.user.count({
      where: division ? { division, isActive: true } : { isActive: true },
    });

    const presentToday = todayAttendances.filter(a =>
      a.status === 'PRESENT' || a.status === 'LATE'
    ).length;

    const lateToday = todayAttendances.filter(a => a.status === 'LATE').length;
    const absentToday = totalEmployees - presentToday;

    const pendingLeaves = await prisma.leave.count({
      where: {
        status: 'PENDING',
        ...(division && { user: { division } }),
      },
    });

    const pendingOvertime = await prisma.overtime.count({
      where: {
        status: 'PENDING',
        ...(division && { user: { division } }),
      },
    });

    return {
      totalEmployees,
      presentToday,
      lateToday,
      absentToday,
      pendingLeaves,
      pendingOvertime,
      attendanceRate: totalEmployees > 0 ? (presentToday / totalEmployees) * 100 : 0,
    };
  }
}