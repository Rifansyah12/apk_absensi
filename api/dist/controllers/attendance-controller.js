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
                note: req.body.note || '',
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
            const { userId, date, checkIn, checkOut, reason } = req.body;
            const targetUser = await prisma.user.findUnique({
                where: { id: Number(userId) },
                select: { division: true }
            });
            if (!targetUser) {
                res.status(404).json({
                    success: false,
                    message: 'Target user not found',
                });
                return;
            }
            if (req.user?.division !== targetUser.division) {
                res.status(403).json({
                    success: false,
                    message: 'You cannot record attendance for another division',
                });
                return;
            }
            const attendance = await prisma.attendance.create({
                data: {
                    userId: Number(userId),
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
    async getTodayAttendance(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const tomorrow = new Date(today);
            tomorrow.setDate(tomorrow.getDate() + 1);
            const attendance = await prisma.attendance.findFirst({
                where: {
                    userId: req.user.id,
                    date: {
                        gte: today,
                        lt: tomorrow,
                    },
                },
            });
            res.json({
                success: true,
                data: attendance,
            });
        }
        catch (error) {
            console.error('Get today attendance error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to get today attendance',
            });
        }
    }
    async getAttendanceHistoryByDivision(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
            }
            const { startDate, endDate } = req.query;
            let start;
            let end;
            if (startDate && endDate) {
                start = new Date(startDate);
                end = new Date(endDate);
            }
            else {
                end = new Date();
                start = new Date();
                start.setDate(start.getDate() - 30);
            }
            const attendances = await attendanceService.getAttendanceHistoryByDivision(req.user.division, start, end);
            res.json({
                success: true,
                data: attendances,
            });
        }
        catch (error) {
            console.error("Get attendance history error:", error);
            res.status(400).json({
                success: false,
                message: error.message || "Failed to get attendance history",
            });
        }
    }
    async deleteAttendance(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { id } = req.params;
            if (!id || isNaN(parseInt(id))) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid attendance ID',
                });
                return;
            }
            const attendanceId = parseInt(id);
            const attendance = await prisma.attendance.findUnique({
                where: { id: attendanceId },
                include: { user: true }
            });
            if (attendance) {
                if (attendance.user.division !== req.user.division) {
                    res.status(403).json({
                        success: false,
                        message: 'You cannot delete attendance from another division',
                    });
                    return;
                }
            }
            await attendanceService.deleteAttendance(attendanceId);
            res.json({
                success: true,
                message: 'Attendance record deleted successfully',
            });
        }
        catch (error) {
            console.error('Delete attendance error:', error);
            if (error.message.includes('not found')) {
                res.status(404).json({
                    success: false,
                    message: error.message,
                });
            }
            else if (error.code === 'P2025') {
                res.status(404).json({
                    success: false,
                    message: 'Attendance record not found',
                });
            }
            else {
                res.status(400).json({
                    success: false,
                    message: error.message || 'Failed to delete attendance record',
                });
            }
        }
    }
    async updateManualAttendance(req, res) {
        try {
            const { attendanceId, checkIn, checkOut, reason } = req.body;
            if (!attendanceId) {
                res.status(400).json({
                    success: false,
                    message: 'Attendance ID is required',
                });
                return;
            }
            const existingAttendance = await prisma.attendance.findUnique({
                where: { id: Number(attendanceId) },
                include: { user: true }
            });
            if (!existingAttendance) {
                res.status(404).json({
                    success: false,
                    message: 'Attendance record not found',
                });
                return;
            }
            if (existingAttendance.user.division !== req.user?.division) {
                res.status(403).json({
                    success: false,
                    message: 'You cannot edit attendance from another division',
                });
                return;
            }
            const updatedAttendance = await prisma.attendance.update({
                where: { id: Number(attendanceId) },
                data: {
                    checkIn: checkIn ? new Date(checkIn) : null,
                    checkOut: checkOut ? new Date(checkOut) : null,
                    notes: reason || null,
                },
            });
            res.json({
                success: true,
                message: 'Manual attendance updated successfully',
                data: updatedAttendance,
            });
        }
        catch (error) {
            console.error('Update manual attendance error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to update manual attendance',
            });
        }
    }
}
exports.AttendanceController = AttendanceController;
//# sourceMappingURL=attendance-controller.js.map