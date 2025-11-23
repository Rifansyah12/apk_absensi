"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const frontdesk_controller_1 = require("../controllers/frontdesk-controller");
const auth_1 = require("../middleware/auth");
const finance_controller_1 = require("../controllers/finance-controller");
const router = (0, express_1.Router)();
router.get('/realtime-attendance', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontdesk_controller_1.frontDeskController.getRealtimeAttendance);
router.get('/daily-late-report', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontdesk_controller_1.frontDeskController.getDailyLateReport);
router.put('/deduction-settings/:division', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), finance_controller_1.financeController.updateDeductionSettings);
router.post('/manual-checkin', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontdesk_controller_1.frontDeskController.manualCheckIn);
router.patch('/process-leave/:leaveId', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FRONT_DESK', 'SUPER_ADMIN']), frontdesk_controller_1.frontDeskController.processLeaveRequest);
exports.default = router;
//# sourceMappingURL=frontdesk-routes.js.map