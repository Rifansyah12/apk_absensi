"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const onsite_controller_1 = require("../controllers/onsite-controller");
const auth_1 = require("../middleware/auth");
const finance_controller_1 = require("../controllers/finance-controller");
const router = (0, express_1.Router)();
router.post('/validate-gps-checkin', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsite_controller_1.onsiteController.validateGPSCheckIn);
router.get('/field-monitoring', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsite_controller_1.onsiteController.getFieldMonitoring);
router.get('/attendance-report', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsite_controller_1.onsiteController.getOnsiteAttendanceReport);
router.put('/deduction-settings/:division', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), finance_controller_1.financeController.updateDeductionSettings);
router.patch('/process-overtime/:overtimeId', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_ONSITE', 'SUPER_ADMIN']), onsite_controller_1.onsiteController.processOvertimeOnsite);
exports.default = router;
//# sourceMappingURL=onsite-routes.js.map