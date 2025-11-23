import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class AnalysisController {
    getPerformanceAnalysis(req: AuthRequest, res: Response): Promise<void>;
    private generateRecommendations;
    private generateSummary;
}
//# sourceMappingURL=analysis-controller.d.ts.map