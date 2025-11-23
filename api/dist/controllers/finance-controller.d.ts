import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class FinanceController {
    getFinanceDashboard(req: AuthRequest, res: Response): Promise<void>;
    getFinancialReport(req: AuthRequest, res: Response): Promise<void>;
    updateDeductionSettings(req: AuthRequest, res: Response): Promise<void>;
    exportSalaryReport(req: AuthRequest, res: Response): Promise<void>;
}
export declare const financeController: FinanceController;
//# sourceMappingURL=finance-controller.d.ts.map