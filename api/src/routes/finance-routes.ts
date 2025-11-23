import { Router } from 'express';
import { financeController } from '../controllers/finance-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();

// Dashboard & Laporan
router.get('/dashboard', authenticate, authorize(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), financeController.getFinanceDashboard);
router.get('/financial-report', authenticate, authorize(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), financeController.getFinancialReport);
router.get('/export-salary', authenticate, authorize(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), financeController.exportSalaryReport);

// Pengaturan
router.put('/deduction-settings/:division', authenticate, authorize(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), financeController.updateDeductionSettings);

// Operasional
// router.post('/manual-attendance', authenticate, authorize(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), financeController.manualAttendance);

export default router;