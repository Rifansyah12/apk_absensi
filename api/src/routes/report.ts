import { Router } from 'express';
import { ReportController } from '../controllers/report-controller';
import { authenticate } from '../middleware/auth';

const router = Router();
const reportController = new ReportController();

router.get('/attendance', authenticate, reportController.getAttendanceReport);
router.get('/salary', authenticate, reportController.getSalaryReport);
router.get('/dashboard', authenticate, reportController.getDashboardStats);
router.get('/personal', authenticate, reportController.getPersonalReport);

export default router;