"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const salary_controller_1 = require("../controllers/salary-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const salaryController = new salary_controller_1.SalaryController();
router.get('/my-salaries', auth_1.authenticate, salaryController.getMySalaries);
router.get('/:id', auth_1.authenticate, salaryController.getSalaryById);
router.post('/calculate', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), salaryController.calculateSalary);
exports.default = router;
//# sourceMappingURL=salary.js.map