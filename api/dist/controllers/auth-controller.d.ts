import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class AuthController {
    login(req: AuthRequest, res: Response): Promise<void>;
    getProfile(req: AuthRequest, res: Response): Promise<void>;
    changePassword(req: AuthRequest, res: Response): Promise<void>;
    updateProfile(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=auth-controller.d.ts.map