import { Router } from 'express';
import { AuthController } from '../controllers/auth-controller';
import { authenticate } from '../middleware/auth';
import { validateLogin, handleValidationErrors } from '../middleware/validation';

const router = Router();
const authController = new AuthController();

router.post('/login', validateLogin, handleValidationErrors, authController.login);
router.get('/profile', authenticate, authController.getProfile);
router.post('/change-password', authenticate, authController.changePassword);

export default router;