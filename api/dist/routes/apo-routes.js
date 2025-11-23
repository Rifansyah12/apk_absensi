"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const apo_controller_1 = require("../controllers/apo-controller");
const auth_1 = require("../middleware/auth");
const finance_controller_1 = require("../controllers/finance-controller");
const router = (0, express_1.Router)();
router.get('/dashboard', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apo_controller_1.apoController.getHRDashboard);
router.post('/validate-attendance', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apo_controller_1.apoController.validateAttendance);
router.get('/attendance-history', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apo_controller_1.apoController.getAllAttendanceHistory);
router.put('/work-hours/:division', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apo_controller_1.apoController.updateWorkHours);
router.put('/deduction-settings/:division', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), finance_controller_1.financeController.updateDeductionSettings);
router.post('/upload-photo/:userId', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_APO', 'SUPER_ADMIN']), apo_controller_1.apoController.uploadEmployeePhoto);
exports.default = router;
//# sourceMappingURL=apo-routes.js.map