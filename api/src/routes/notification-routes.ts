import { Router } from 'express';
import { NotificationController } from '../controllers/notification-controller';
import { authenticate } from '../middleware/auth';

const router = Router();
const notificationController = new NotificationController();

router.get('/', authenticate, notificationController.getMyNotifications);
router.get('/unread-count', authenticate, notificationController.getUnreadCount);
router.patch('/:id/read', authenticate, notificationController.markAsRead);
router.patch('/read-all', authenticate, notificationController.markAllAsRead);

export default router;