import { Division } from '@prisma/client';
import { ReportFilter } from '../types';
export declare class ReportService {
    generateAttendanceReport(division: Division, filters: ReportFilter): Promise<{
        nama: string;
        jabatan: string;
        tanggal: string;
        jamMasuk: string;
        jamPulang: string;
        terlambat: number;
        lembur: number;
        potongan: number;
        totalGaji: number;
        lokasi: string;
    }[]>;
    getPersonalAttendanceSummary(userId: number, month: number, year: number): Promise<{
        totalPresent: number;
        totalLate: number;
        totalAbsent: number;
        totalLeave: number;
        totalOvertime: number;
        totalWorkingDays: number;
        attendanceRate: number;
    }>;
    private getWorkingDays;
    generateSalaryReport(month: number, year: number, division?: Division): Promise<{
        nama: string;
        jabatan: string;
        divisi: import(".prisma/client").$Enums.Division;
        gajiPokok: number;
        lembur: number;
        potongan: number;
        totalGaji: number;
        bulan: number;
        tahun: number;
    }[]>;
    private calculateDeduction;
    private calculateTotalSalary;
    getDashboardStats(division?: Division): Promise<{
        totalEmployees: number;
        presentToday: number;
        lateToday: number;
        absentToday: number;
        pendingLeaves: number;
        pendingOvertime: number;
        attendanceRate: number;
    }>;
}
//# sourceMappingURL=report-service.d.ts.map