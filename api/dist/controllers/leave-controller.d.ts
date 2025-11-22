import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class LeaveController {
    requestLeave(req: AuthRequest, res: Response): Promise<void>;
    getMyLeaves(req: AuthRequest, res: Response): Promise<void>;
    approveRejectLeave(req: AuthRequest, res: Response): Promise<void>;
    getPendingLeaves(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=leave-controller.d.ts.map