"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const report_controller_1 = require("../controllers/report-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const reportController = new report_controller_1.ReportController();
router.get('/attendance', auth_1.authenticate, reportController.getAttendanceReport);
router.get('/salary', auth_1.authenticate, reportController.getSalaryReport);
router.get('/dashboard', auth_1.authenticate, reportController.getDashboardStats);
router.get('/personal', auth_1.authenticate, reportController.getPersonalReport);
exports.default = router;
//# sourceMappingURL=report.js.map