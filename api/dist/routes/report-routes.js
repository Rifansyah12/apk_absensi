"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const report_controller_1 = require("../controllers/report-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const reportController = new report_controller_1.ReportController();
router.get('/attendance', auth_1.authenticate, reportController.getAttendanceReport);
router.get('/attendance/export', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), reportController.exportAttendanceReport);
router.get('/salary', auth_1.authenticate, reportController.getSalaryReport);
router.get('/salary/export', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), reportController.exportSalaryReport);
router.get('/dashboard', auth_1.authenticate, reportController.getDashboardStats);
exports.default = router;
//# sourceMappingURL=report-routes.js.map