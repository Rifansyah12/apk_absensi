import { Router } from 'express';
import { LeaveController } from '../controllers/leave-controller';
import { authenticate, authorize } from '../middleware/auth';
import { validateLeave, handleValidationErrors } from '../middleware/validation';

const router = Router();
const leaveController = new LeaveController();

router.post('/', authenticate, validateLeave, handleValidationErrors, leaveController.requestLeave);
router.get('/my-leaves', authenticate, leaveController.getMyLeaves);
router.get('/', authenticate, authorize('SUPER_ADMIN'), leaveController.getPendingLeaves);
router.patch('/:leaveId/status', authenticate, authorize('SUPER_ADMIN'), leaveController.approveRejectLeave);

export default router;