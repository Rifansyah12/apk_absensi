"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const attendance_controller_1 = require("../controllers/attendance-controller");
const auth_1 = require("../middleware/auth");
const upload_1 = require("../middleware/upload");
const router = (0, express_1.Router)();
const attendanceController = new attendance_controller_1.AttendanceController();
router.post('/checkin', auth_1.authenticate, upload_1.uploadSinglePhoto, upload_1.handleUploadError, attendanceController.checkIn);
router.post('/checkout', auth_1.authenticate, upload_1.uploadSinglePhoto, upload_1.handleUploadError, attendanceController.checkOut);
router.get('/history', auth_1.authenticate, attendanceController.getAttendanceHistory);
router.get('/summary', auth_1.authenticate, attendanceController.getAttendanceSummary);
router.post('/manual', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), attendanceController.manualAttendance);
exports.default = router;
//# sourceMappingURL=attendance.js.map