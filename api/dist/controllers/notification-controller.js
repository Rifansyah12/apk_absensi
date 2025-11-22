"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationController = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class NotificationController {
    async getMyNotifications(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { page = '1', limit = '10' } = req.query;
            const pageNum = parseInt(page);
            const limitNum = parseInt(limit);
            const skip = (pageNum - 1) * limitNum;
            const notifications = await prisma.notification.findMany({
                where: { userId: req.user.id },
                orderBy: { createdAt: 'desc' },
                skip,
                take: limitNum,
            });
            const total = await prisma.notification.count({
                where: { userId: req.user.id },
            });
            res.json({
                success: true,
                data: {
                    notifications,
                    pagination: {
                        page: pageNum,
                        limit: limitNum,
                        total,
                        pages: Math.ceil(total / limitNum),
                    },
                },
            });
        }
        catch (error) {
            console.error('Get notifications error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async markAsRead(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { id } = req.params;
            await prisma.notification.update({
                where: { id: parseInt(id), userId: req.user.id },
                data: { isRead: true },
            });
            res.json({
                success: true,
                message: 'Notification marked as read',
            });
        }
        catch (error) {
            console.error('Mark notification as read error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async markAllAsRead(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            await prisma.notification.updateMany({
                where: { userId: req.user.id, isRead: false },
                data: { isRead: true },
            });
            res.json({
                success: true,
                message: 'All notifications marked as read',
            });
        }
        catch (error) {
            console.error('Mark all notifications as read error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getUnreadCount(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const count = await prisma.notification.count({
                where: { userId: req.user.id, isRead: false },
            });
            res.json({
                success: true,
                data: { unreadCount: count },
            });
        }
        catch (error) {
            console.error('Get unread count error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
}
exports.NotificationController = NotificationController;
//# sourceMappingURL=notification-controller.js.map