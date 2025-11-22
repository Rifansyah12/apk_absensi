"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AttendanceController = void 0;
const attendance_service_1 = require("../services/attendance-service");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const attendanceService = new attendance_service_1.AttendanceService();
class AttendanceController {
    async checkIn(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { lat, lng } = req.body;
            if (!lat || !lng) {
                res.status(400).json({
                    success: false,
                    message: 'Latitude dan longitude diperlukan',
                });
                return;
            }
            if (!req.file) {
                res.status(400).json({
                    success: false,
                    message: 'Foto selfie diperlukan',
                });
                return;
            }
            const location = `${lat},${lng}`;
            const date = new Date();
            const attendance = await attendanceService.checkIn(req.user.id, {
                date,
                location,
                selfie: req.file.buffer,
            });
            res.json({
                success: true,
                message: 'Check-in berhasil',
                data: attendance,
            });
        }
        catch (error) {
            console.error('Check-in error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Check-in gagal',
            });
        }
    }
    async checkOut(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { lat, lng } = req.body;
            if (!lat || !lng) {
                res.status(400).json({
                    success: false,
                    message: 'Latitude dan longitude diperlukan',
                });
                return;
            }
            if (!req.file) {
                res.status(400).json({
                    success: false,
                    message: 'Foto selfie diperlukan',
                });
                return;
            }
            const location = `${lat},${lng}`;
            const date = new Date();
            const attendance = await attendanceService.checkOut(req.user.id, {
                date,
                location,
                selfie: req.file.buffer,
            });
            res.json({
                success: true,
                message: 'Check-out berhasil',
                data: attendance,
            });
        }
        catch (error) {
            console.error('Check-out error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Check-out gagal',
            });
        }
    }
    async getAttendanceHistory(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { startDate, endDate } = req.query;
            const start = startDate ? new Date(startDate) : new Date();
            const end = endDate ? new Date(endDate) : new Date();
            start.setDate(start.getDate() - 30);
            const attendances = await attendanceService.getAttendanceHistory(req.user.id, start, end);
            res.json({
                success: true,
                data: attendances,
            });
        }
        catch (error) {
            console.error('Get attendance history error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to get attendance history',
            });
        }
    }
    async getAttendanceSummary(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { month, year } = req.query;
            const currentDate = new Date();
            const targetMonth = month ? parseInt(month) : currentDate.getMonth() + 1;
            const targetYear = year ? parseInt(year) : currentDate.getFullYear();
            const summary = await attendanceService.getAttendanceSummary(req.user.id, targetMonth, targetYear);
            res.json({
                success: true,
                data: summary,
            });
        }
        catch (error) {
            console.error('Get attendance summary error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to get attendance summary',
            });
        }
    }
    async manualAttendance(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { userId, date, checkIn, checkOut, reason } = req.body;
            const attendance = await prisma.attendance.create({
                data: {
                    userId: parseInt(userId),
                    date: new Date(date),
                    checkIn: checkIn ? new Date(checkIn) : null,
                    checkOut: checkOut ? new Date(checkOut) : null,
                    status: 'PRESENT',
                    notes: `Manual entry: ${reason}`,
                },
            });
            res.json({
                success: true,
                message: 'Manual attendance recorded successfully',
                data: attendance,
            });
        }
        catch (error) {
            console.error('Manual attendance error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to record manual attendance',
            });
        }
    }
}
exports.AttendanceController = AttendanceController;
//# sourceMappingURL=attendance-controller.js.map