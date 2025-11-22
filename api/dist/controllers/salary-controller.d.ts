import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class SalaryController {
    getMySalaries(req: AuthRequest, res: Response): Promise<void>;
    getSalaryById(req: AuthRequest, res: Response): Promise<void>;
    calculateSalary(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=salary-controller.d.ts.map