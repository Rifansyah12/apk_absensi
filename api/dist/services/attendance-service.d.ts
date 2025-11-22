import { Attendance } from '@prisma/client';
export declare class AttendanceService {
    checkIn(userId: number, data: {
        date: Date;
        location: string;
        selfie: Buffer;
    }): Promise<Attendance>;
    checkOut(userId: number, data: {
        date: Date;
        location: string;
        selfie: Buffer;
    }): Promise<Attendance>;
    getAttendanceHistory(userId: number, startDate: Date, endDate: Date): Promise<Attendance[]>;
    getAttendanceSummary(userId: number, month: number, year: number): Promise<{
        totalPresent: number;
        totalLate: number;
        totalAbsent: number;
        totalLeave: number;
        totalOvertime: number;
    }>;
}
//# sourceMappingURL=attendance-service.d.ts.map