import { Router } from 'express';
import { HelpController } from '../controllers/help-controller';
import { authenticate } from '../middleware/auth';

const router = Router();
const helpController = new HelpController();

// Public routes (butuh authentication)
router.get('/', authenticate, helpController.getHelp);

// Admin routes
router.get('/admin/all', authenticate, helpController.getAllHelpContent);
router.post('/admin', authenticate, helpController.createHelpContent);
router.put('/admin/:id', authenticate, helpController.updateHelpContent);
router.delete('/admin/:id', authenticate, helpController.deleteHelpContent);
router.patch('/admin/:id/toggle-status', authenticate, helpController.toggleHelpContentStatus);

export default router;