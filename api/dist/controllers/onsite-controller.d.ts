import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class OnsiteController {
    validateGPSCheckIn(req: AuthRequest, res: Response): Promise<void>;
    getFieldMonitoring(_req: AuthRequest, res: Response): Promise<void>;
    processOvertimeOnsite(req: AuthRequest, res: Response): Promise<void>;
    getOnsiteAttendanceReport(req: AuthRequest, res: Response): Promise<void>;
    private groupEmployeesByLocation;
    private getLocationName;
}
export declare const onsiteController: OnsiteController;
//# sourceMappingURL=onsite-controller.d.ts.map