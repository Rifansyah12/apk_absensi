"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = __importDefault(require("./auth"));
const attendance_1 = __importDefault(require("./attendance"));
const user_1 = __importDefault(require("./user"));
const leave_1 = __importDefault(require("./leave"));
const overtime_1 = __importDefault(require("./overtime"));
const report_1 = __importDefault(require("./report"));
const notification_1 = __importDefault(require("./notification"));
const salary_1 = __importDefault(require("./salary"));
const router = (0, express_1.Router)();
router.use('/auth', auth_1.default);
router.use('/attendance', attendance_1.default);
router.use('/users', user_1.default);
router.use('/leaves', leave_1.default);
router.use('/overtime', overtime_1.default);
router.use('/reports', report_1.default);
router.use('/notifications', notification_1.default);
router.use('/salaries', salary_1.default);
exports.default = router;
//# sourceMappingURL=index.js.map