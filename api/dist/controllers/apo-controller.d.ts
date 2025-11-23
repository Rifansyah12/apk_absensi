import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class ApoController {
    getHRDashboard(_req: AuthRequest, res: Response): Promise<void>;
    validateAttendance(req: AuthRequest, res: Response): Promise<void>;
    updateWorkHours(req: AuthRequest, res: Response): Promise<void>;
    getAllAttendanceHistory(req: AuthRequest, res: Response): Promise<void>;
    uploadEmployeePhoto(req: AuthRequest, res: Response): Promise<void>;
}
export declare const apoController: ApoController;
//# sourceMappingURL=apo-controller.d.ts.map