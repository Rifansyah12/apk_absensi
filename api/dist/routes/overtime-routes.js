"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const overtime_controller_1 = require("../controllers/overtime-controller");
const auth_1 = require("../middleware/auth");
const validation_1 = require("../middleware/validation");
const router = (0, express_1.Router)();
const overtimeController = new overtime_controller_1.OvertimeController();
router.post('/', auth_1.authenticate, validation_1.validateOvertime, validation_1.handleValidationErrors, overtimeController.requestOvertime);
router.get('/my-overtime', auth_1.authenticate, overtimeController.getMyOvertime);
router.get('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), overtimeController.getAllOvertime);
router.patch('/:overtimeId/status', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), overtimeController.approveRejectOvertime);
exports.default = router;
//# sourceMappingURL=overtime-routes.js.map