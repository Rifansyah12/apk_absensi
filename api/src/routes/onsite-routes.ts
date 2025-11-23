import { Router } from 'express';
import { onsiteController } from '../controllers/onsite-controller';
import { authenticate, authorize } from '../middleware/auth';
import { financeController } from '../controllers/finance-controller';

const router = Router();

// Validasi GPS
router.post('/validate-gps-checkin', authenticate, authorize(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsiteController.validateGPSCheckIn);

// Monitoring
router.get('/field-monitoring', authenticate, authorize(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsiteController.getFieldMonitoring);
router.get('/attendance-report', authenticate, authorize(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsiteController.getOnsiteAttendanceReport);

router.put('/deduction-settings/:division', authenticate, authorize(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), financeController.updateDeductionSettings);

// Persetujuan
router.patch('/process-overtime/:overtimeId', authenticate, authorize(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsiteController.processOvertimeOnsite);

export default router;