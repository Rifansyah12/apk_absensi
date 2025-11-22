"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LeaveController = void 0;
const client_1 = require("@prisma/client");
const notification_1 = require("../utils/notification");
const prisma = new client_1.PrismaClient();
class LeaveController {
    async requestLeave(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { startDate, endDate, type, reason } = req.body;
            const leave = await prisma.leave.create({
                data: {
                    userId: req.user.id,
                    startDate: new Date(startDate),
                    endDate: new Date(endDate),
                    type: type,
                    reason,
                    status: 'PENDING',
                },
            });
            res.json({
                success: true,
                message: 'Leave request submitted successfully',
                data: leave,
            });
        }
        catch (error) {
            console.error('Leave request error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to submit leave request',
            });
        }
    }
    async getMyLeaves(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const leaves = await prisma.leave.findMany({
                where: { userId: req.user.id },
                orderBy: { createdAt: 'desc' },
            });
            res.json({
                success: true,
                data: leaves,
            });
        }
        catch (error) {
            console.error('Get leaves error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to get leave requests',
            });
        }
    }
    async approveRejectLeave(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { leaveId } = req.params;
            const { status, notes } = req.body;
            if (!['APPROVED', 'REJECTED'].includes(status)) {
                res.status(400).json({
                    success: false,
                    message: 'Status must be APPROVED or REJECTED',
                });
                return;
            }
            const leave = await prisma.leave.update({
                where: { id: parseInt(leaveId) },
                data: {
                    status: status,
                    approvedBy: req.user.id,
                    notes,
                },
                include: {
                    user: true,
                },
            });
            await (0, notification_1.sendNotification)(leave.userId, `Cuti ${status === 'APPROVED' ? 'Disetujui' : 'Ditolak'}`, `Permohonan cuti Anda ${status === 'APPROVED' ? 'telah disetujui' : 'ditolak'}.${notes ? ` Catatan: ${notes}` : ''}`, status === 'APPROVED' ? 'LEAVE_APPROVED' : 'LEAVE_REJECTED');
            res.json({
                success: true,
                message: `Leave ${status.toLowerCase()} successfully`,
                data: leave,
            });
        }
        catch (error) {
            console.error('Approve/reject leave error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to update leave status',
            });
        }
    }
    async getPendingLeaves(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const leaves = await prisma.leave.findMany({
                where: { status: 'PENDING' },
                include: {
                    user: {
                        select: {
                            id: true,
                            name: true,
                            employeeId: true,
                            division: true,
                            position: true,
                        },
                    },
                },
                orderBy: { createdAt: 'desc' },
            });
            res.json({
                success: true,
                data: leaves,
            });
        }
        catch (error) {
            console.error('Get pending leaves error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to get pending leaves',
            });
        }
    }
}
exports.LeaveController = LeaveController;
//# sourceMappingURL=leave-controller.js.map