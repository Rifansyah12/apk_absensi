import { Router } from 'express';
import { frontDeskController } from '../controllers/frontdesk-controller';
import { authenticate, authorize } from '../middleware/auth';
import { financeController } from '../controllers/finance-controller';

const router = Router();

// Monitoring Real-time
router.get('/realtime-attendance', authenticate, authorize(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontDeskController.getRealtimeAttendance);
router.get('/daily-late-report', authenticate, authorize(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontDeskController.getDailyLateReport);
router.put('/deduction-settings/:division', authenticate, authorize(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), financeController.updateDeductionSettings);

// Operasional
router.post('/manual-checkin', authenticate, authorize(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontDeskController.manualCheckIn);
router.patch('/process-leave/:leaveId', authenticate, authorize(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontDeskController.processLeaveRequest);

export default router;