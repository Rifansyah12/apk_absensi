import { Router } from 'express';
import { apoController } from '../controllers/apo-controller';
import { authenticate, authorize } from '../middleware/auth';
import { financeController } from '../controllers/finance-controller';

const router = Router();

// Dashboard HR
router.get('/dashboard', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apoController.getHRDashboard);

// Validasi & Monitoring
router.post('/validate-attendance', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apoController.validateAttendance);
router.get('/attendance-history', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apoController.getAllAttendanceHistory);

// Pengaturan HR
router.put('/work-hours/:division', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apoController.updateWorkHours);

router.put('/deduction-settings/:division', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), financeController.updateDeductionSettings);

// Upload foto
router.post('/upload-photo/:userId', authenticate, authorize(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apoController.uploadEmployeePhoto);

export default router;