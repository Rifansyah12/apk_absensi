import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class OvertimeController {
    requestOvertime(req: AuthRequest, res: Response): Promise<void>;
    getMyOvertime(req: AuthRequest, res: Response): Promise<void>;
    approveRejectOvertime(req: AuthRequest, res: Response): Promise<void>;
    getPendingOvertime(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=overtime-controller.d.ts.map