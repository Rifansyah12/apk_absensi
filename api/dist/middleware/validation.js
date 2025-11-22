"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateOvertime = exports.validateLeave = exports.validateAttendance = exports.validateLogin = exports.handleValidationErrors = void 0;
const express_validator_1 = require("express-validator");
const handleValidationErrors = (req, res, next) => {
    const errors = (0, express_validator_1.validationResult)(req);
    if (!errors.isEmpty()) {
        res.status(400).json({
            success: false,
            message: 'Validation errors',
            errors: errors.array(),
        });
        return;
    }
    next();
};
exports.handleValidationErrors = handleValidationErrors;
exports.validateLogin = [
    (0, express_validator_1.body)('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email'),
    (0, express_validator_1.body)('password')
        .isLength({ min: 6 })
        .withMessage('Password must be at least 6 characters long'),
];
exports.validateAttendance = [
    (0, express_validator_1.body)('date')
        .optional()
        .isISO8601()
        .withMessage('Please provide a valid date'),
    (0, express_validator_1.body)('locationCheckIn')
        .optional()
        .isString()
        .withMessage('Location check-in must be a string'),
    (0, express_validator_1.body)('locationCheckOut')
        .optional()
        .isString()
        .withMessage('Location check-out must be a string'),
];
exports.validateLeave = [
    (0, express_validator_1.body)('startDate')
        .isISO8601()
        .withMessage('Please provide a valid start date'),
    (0, express_validator_1.body)('endDate')
        .isISO8601()
        .withMessage('Please provide a valid end date'),
    (0, express_validator_1.body)('type')
        .isIn(['CUTI_TAHUNAN', 'CUTI_SAKIT', 'CUTI_MELAHIRKAN', 'IZIN'])
        .withMessage('Invalid leave type'),
    (0, express_validator_1.body)('reason')
        .isLength({ min: 10 })
        .withMessage('Reason must be at least 10 characters long'),
];
exports.validateOvertime = [
    (0, express_validator_1.body)('date')
        .isISO8601()
        .withMessage('Please provide a valid date'),
    (0, express_validator_1.body)('hours')
        .isFloat({ min: 0.5, max: 12 })
        .withMessage('Hours must be between 0.5 and 12'),
    (0, express_validator_1.body)('reason')
        .isLength({ min: 10 })
        .withMessage('Reason must be at least 10 characters long'),
];
//# sourceMappingURL=validation.js.map