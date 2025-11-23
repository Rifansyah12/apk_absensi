import { Router } from 'express';
import { ReportController } from '../controllers/report-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const reportController = new ReportController();

router.get('/attendance', authenticate, reportController.getAttendanceReport);
router.get('/attendance/export', authenticate, authorize('SUPER_ADMIN'), reportController.exportAttendanceReport); // New export route
router.get('/salary', authenticate, reportController.getSalaryReport);
router.get('/salary/export', authenticate, authorize('SUPER_ADMIN'), reportController.exportSalaryReport); // New export route
router.get('/dashboard', authenticate, reportController.getDashboardStats);

export default router;