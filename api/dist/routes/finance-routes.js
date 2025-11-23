"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const finance_controller_1 = require("../controllers/finance-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
router.get('/dashboard', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), finance_controller_1.financeController.getFinanceDashboard);
router.get('/financial-report', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), finance_controller_1.financeController.getFinancialReport);
router.get('/export-salary', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), finance_controller_1.financeController.exportSalaryReport);
router.put('/deduction-settings/:division', auth_1.authenticate, (0, auth_1.authorize)(['SUPER_ADMIN_FINANCE', 'SUPER_ADMIN']), finance_controller_1.financeController.updateDeductionSettings);
exports.default = router;
//# sourceMappingURL=finance-routes.js.map