import { Router } from 'express';
import { AnalysisController } from '../controllers/analysis-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const analysisController = new AnalysisController();

router.get('/performance', authenticate, authorize('SUPER_ADMIN'), analysisController.getPerformanceAnalysis);

export default router;