import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class ReportController {
    getAttendanceReport(req: AuthRequest, res: Response): Promise<void>;
    getSalaryReport(req: AuthRequest, res: Response): Promise<void>;
    getDashboardStats(req: AuthRequest, res: Response): Promise<void>;
    getPersonalReport(req: AuthRequest, res: Response): Promise<void>;
    exportAttendanceReport(req: AuthRequest, res: Response): Promise<void>;
    exportSalaryReport(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=report-controller.d.ts.map