import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class UserController {
    getAllUsers(req: AuthRequest, res: Response): Promise<void>;
    getUserById(req: AuthRequest, res: Response): Promise<void>;
    createUser(req: AuthRequest, res: Response): Promise<void>;
    updateUser(req: AuthRequest, res: Response): Promise<void>;
    deleteUser(req: AuthRequest, res: Response): Promise<void>;
    restoreUser(req: AuthRequest, res: Response): Promise<void>;
    getInactiveUsers(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=user-controller.d.ts.map