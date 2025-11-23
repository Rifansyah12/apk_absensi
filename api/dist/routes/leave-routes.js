"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const leave_controller_1 = require("../controllers/leave-controller");
const auth_1 = require("../middleware/auth");
const validation_1 = require("../middleware/validation");
const router = (0, express_1.Router)();
const leaveController = new leave_controller_1.LeaveController();
router.post('/', auth_1.authenticate, validation_1.validateLeave, validation_1.handleValidationErrors, leaveController.requestLeave);
router.get('/my-leaves', auth_1.authenticate, leaveController.getMyLeaves);
router.get('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), leaveController.getPendingLeaves);
router.patch('/:leaveId/status', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), leaveController.approveRejectLeave);
exports.default = router;
//# sourceMappingURL=leave-routes.js.map