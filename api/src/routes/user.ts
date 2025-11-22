import { Router } from 'express';
import { UserController } from '../controllers/user-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const userController = new UserController();

router.get('/', authenticate, authorize('SUPER_ADMIN'), userController.getAllUsers);
router.get('/:id', authenticate, userController.getUserById);
router.post('/', authenticate, authorize('SUPER_ADMIN'), userController.createUser);
router.put('/:id', authenticate, authorize('SUPER_ADMIN'), userController.updateUser);
router.delete('/:id', authenticate, authorize('SUPER_ADMIN'), userController.deleteUser);

export default router;