import { Router } from 'express';
import { DivisionSettingController } from '../controllers/division-setting-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const divisionSettingController = new DivisionSettingController();

router.get('/', authenticate, authorize('SUPER_ADMIN'), divisionSettingController.getAllDivisionSettings);
router.get('/:division', authenticate, authorize('SUPER_ADMIN'), divisionSettingController.getDivisionSetting);
router.put('/:division', authenticate, authorize('SUPER_ADMIN'), divisionSettingController.updateDivisionSetting);
router.post('/', authenticate, authorize('SUPER_ADMIN'), divisionSettingController.createDivisionSetting);

export default router;