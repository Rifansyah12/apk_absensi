"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apoController = exports.ApoController = void 0;
const client_1 = require("@prisma/client");
const error_handler_1 = require("../utils/error-handler");
const prisma = new client_1.PrismaClient();
class ApoController {
    async getHRDashboard(_req, res) {
        try {
            const today = new Date();
            const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
            const attendanceStats = await prisma.attendance.groupBy({
                by: ['status'],
                where: {
                    date: {
                        gte: startOfMonth
                    }
                },
                _count: {
                    id: true
                }
            });
            const leaveStats = await prisma.leave.groupBy({
                by: ['status'],
                where: {
                    startDate: {
                        gte: startOfMonth
                    }
                },
                _count: {
                    id: true
                }
            });
            const employeeStats = await prisma.user.groupBy({
                by: ['division'],
                where: {
                    isActive: true
                },
                _count: {
                    id: true
                }
            });
            res.json({
                success: true,
                data: {
                    attendance: attendanceStats,
                    leaves: leaveStats,
                    employees: employeeStats,
                    summary: {
                        totalEmployees: employeeStats.reduce((sum, e) => sum + e._count.id, 0),
                        pendingLeaves: leaveStats.find(l => l.status === 'PENDING')?._count.id || 0,
                        attendanceRate: ((attendanceStats.find(a => a.status === 'PRESENT')?._count.id || 0) /
                            attendanceStats.reduce((sum, a) => sum + a._count.id, 1)) * 100
                    }
                }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async validateAttendance(req, res) {
        try {
            const { attendanceId, isValid, notes } = req.body;
            const attendance = await prisma.attendance.findUnique({
                where: { id: parseInt(attendanceId) },
                include: {
                    user: true
                }
            });
            if (!attendance) {
                res.status(404).json({
                    success: false,
                    message: 'Attendance record not found'
                });
                return;
            }
            if (!isValid) {
                await prisma.attendance.update({
                    where: { id: parseInt(attendanceId) },
                    data: {
                        status: 'ABSENT',
                        notes: `Face validation failed: ${notes}`
                    }
                });
                await prisma.notification.create({
                    data: {
                        userId: attendance.userId,
                        title: 'Validasi Absen Gagal',
                        message: `Absen Anda pada ${attendance.date} gagal validasi wajah. Alasan: ${notes}`,
                        type: 'ATTENDANCE_FAILED'
                    }
                });
            }
            res.json({
                success: true,
                message: `Attendance validation ${isValid ? 'passed' : 'failed'}`,
                data: { attendanceId, isValid }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async updateWorkHours(req, res) {
        try {
            const { division } = req.params;
            const { workStart, workEnd, lateThreshold } = req.body;
            const updatedSetting = await prisma.divisionSetting.update({
                where: { division: division },
                data: {
                    workStart,
                    workEnd,
                    lateThreshold
                }
            });
            res.json({
                success: true,
                message: 'Work hours updated successfully',
                data: updatedSetting
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getAllAttendanceHistory(req, res) {
        try {
            const { startDate, endDate, division, page = 1, limit = 20 } = req.query;
            const whereClause = {
                date: {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                }
            };
            if (division) {
                whereClause.user = {
                    division: division
                };
            }
            const attendances = await prisma.attendance.findMany({
                where: whereClause,
                include: {
                    user: {
                        select: {
                            name: true,
                            division: true,
                            position: true
                        }
                    }
                },
                skip: (parseInt(page) - 1) * parseInt(limit),
                take: parseInt(limit),
                orderBy: {
                    date: 'desc'
                }
            });
            const total = await prisma.attendance.count({ where: whereClause });
            res.json({
                success: true,
                data: attendances,
                meta: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    totalPages: Math.ceil(total / parseInt(limit))
                }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async uploadEmployeePhoto(req, res) {
        try {
            const { userId } = req.params;
            const photoPath = req.body.photoPath;
            const updatedUser = await prisma.user.update({
                where: { id: parseInt(userId) },
                data: { photo: photoPath },
                select: {
                    id: true,
                    name: true,
                    email: true,
                    photo: true
                }
            });
            res.json({
                success: true,
                message: 'Employee photo uploaded successfully',
                data: updatedUser
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
}
exports.ApoController = ApoController;
exports.apoController = new ApoController();
//# sourceMappingURL=apo-controller.js.map