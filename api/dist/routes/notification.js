"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const notification_controller_1 = require("../controllers/notification-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const notificationController = new notification_controller_1.NotificationController();
router.get('/', auth_1.authenticate, notificationController.getMyNotifications);
router.get('/unread-count', auth_1.authenticate, notificationController.getUnreadCount);
router.patch('/:id/read', auth_1.authenticate, notificationController.markAsRead);
router.patch('/read-all', auth_1.authenticate, notificationController.markAllAsRead);
exports.default = router;
//# sourceMappingURL=notification.js.map