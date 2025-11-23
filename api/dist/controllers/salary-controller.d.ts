import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class SalaryController {
    calculateSalary(req: AuthRequest, res: Response): Promise<void>;
    getMySalaries(req: AuthRequest, res: Response): Promise<void>;
    getSalaryById(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=salary-controller.d.ts.map