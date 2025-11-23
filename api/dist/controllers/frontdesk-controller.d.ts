import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class FrontDeskController {
    getRealtimeAttendance(_req: AuthRequest, res: Response): Promise<void>;
    getDailyLateReport(req: AuthRequest, res: Response): Promise<void>;
    manualCheckIn(req: AuthRequest, res: Response): Promise<void>;
    processLeaveRequest(req: AuthRequest, res: Response): Promise<void>;
}
export declare const frontDeskController: FrontDeskController;
//# sourceMappingURL=frontdesk-controller.d.ts.map