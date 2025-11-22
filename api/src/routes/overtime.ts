import { Router } from 'express';
import { OvertimeController } from '../controllers/overtime-controller';
import { authenticate, authorize } from '../middleware/auth';
import { validateOvertime, handleValidationErrors } from '../middleware/validation';

const router = Router();
const overtimeController = new OvertimeController();

router.post('/', authenticate, validateOvertime, handleValidationErrors, overtimeController.requestOvertime);
router.get('/my-overtime', authenticate, overtimeController.getMyOvertime);
router.get('/pending', authenticate, authorize('SUPER_ADMIN'), overtimeController.getPendingOvertime);
router.patch('/:overtimeId/status', authenticate, authorize('SUPER_ADMIN'), overtimeController.approveRejectOvertime);

export default router;