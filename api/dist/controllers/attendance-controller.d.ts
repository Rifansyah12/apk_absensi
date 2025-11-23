import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class AttendanceController {
    checkIn(req: AuthRequest, res: Response): Promise<void>;
    checkOut(req: AuthRequest, res: Response): Promise<void>;
    getAttendanceHistory(req: AuthRequest, res: Response): Promise<void>;
    getAttendanceSummary(req: AuthRequest, res: Response): Promise<void>;
    manualAttendance(req: AuthRequest, res: Response): Promise<void>;
    getTodayAttendance(req: AuthRequest, res: Response): Promise<void>;
    getAttendanceHistoryByDivision(req: AuthRequest, res: Response): Promise<void>;
    deleteAttendance(req: AuthRequest, res: Response): Promise<void>;
    updateManualAttendance(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=attendance-controller.d.ts.map