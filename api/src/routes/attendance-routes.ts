import { Router } from 'express';
import { AttendanceController } from '../controllers/attendance-controller';
import { authenticate, authorize } from '../middleware/auth';
import { uploadSinglePhoto, handleUploadError } from '../middleware/upload';

const router = Router();
const attendanceController = new AttendanceController();

// Check-in dengan form-data (photo, lat, lng)
router.post('/checkin', 
  authenticate, 
  uploadSinglePhoto, 
  handleUploadError,
  attendanceController.checkIn
);

// Check-out dengan form-data (photo, lat, lng)
router.post('/checkout', 
  authenticate, 
  uploadSinglePhoto, 
  handleUploadError,
  attendanceController.checkOut
);

router.get('/today', authenticate, attendanceController.getTodayAttendance);
router.get('/history', authenticate, attendanceController.getAttendanceHistory);
router.get('/', authenticate, attendanceController.getAttendanceHistoryByDivision);
router.get('/summary', authenticate, attendanceController.getAttendanceSummary);
router.delete('/:id', authenticate, authorize('*'), attendanceController.deleteAttendance);
router.post('/manual', authenticate, authorize('*'), attendanceController.manualAttendance);
router.put('/manual', authenticate, authorize('*'), attendanceController.updateManualAttendance);


export default router;