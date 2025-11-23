import { Router } from 'express';
import authRoutes from './auth-routes';
import userRoutes from './user-routes';
import attendanceRoutes from './attendance-routes';
import leaveRoutes from './leave-routes';
import overtimeRoutes from './overtime-routes';
import salaryRoutes from './salary-routes';
import reportRoutes from './report-routes';
import notificationRoutes from './notification-routes';

// Import routes baru untuk divisi super admin
import financeRoutes from './finance-routes';
import apoRoutes from './apo-routes';
import frontdeskRoutes from './frontdesk-routes';
import onsiteRoutes from './onsite-routes';

import divisionSettingRoutes from './division-setting-routes';
import analysisRoutes from './analysis-routes';
import helpRoutes from './help-routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/leaves', leaveRoutes);
router.use('/overtime', overtimeRoutes);
router.use('/salaries', salaryRoutes);
router.use('/reports', reportRoutes);
router.use('/notifications', notificationRoutes);

router.use('/division-settings', divisionSettingRoutes);
router.use('/analysis', analysisRoutes);
router.use('/help', helpRoutes);

// Tambahkan routes baru untuk divisi super admin
router.use('/finance', financeRoutes);
router.use('/apo', apoRoutes);
router.use('/frontdesk', frontdeskRoutes);
router.use('/onsite', onsiteRoutes);

export default router;