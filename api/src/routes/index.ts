import { Router } from 'express';
import authRoutes from './auth';
import attendanceRoutes from './attendance';
import userRoutes from './user';
import leaveRoutes from './leave';
import overtimeRoutes from './overtime';
import reportRoutes from './report';
import notificationRoutes from './notification';
import salaryRoutes from './salary';

const router = Router();

router.use('/auth', authRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/users', userRoutes);
router.use('/leaves', leaveRoutes);
router.use('/overtime', overtimeRoutes);
router.use('/reports', reportRoutes);
router.use('/notifications', notificationRoutes);
router.use('/salaries', salaryRoutes);

export default router;