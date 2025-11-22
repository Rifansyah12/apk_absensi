import { body, validationResult } from 'express-validator';
import { Response, NextFunction } from 'express';
import { AuthRequest } from '../types';

export const handleValidationErrors = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  const errors = validationResult(req);
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

export const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
];

export const validateAttendance = [
  body('date')
    .optional()
    .isISO8601()
    .withMessage('Please provide a valid date'),
  body('locationCheckIn')
    .optional()
    .isString()
    .withMessage('Location check-in must be a string'),
  body('locationCheckOut')
    .optional()
    .isString()
    .withMessage('Location check-out must be a string'),
];

export const validateLeave = [
  body('startDate')
    .isISO8601()
    .withMessage('Please provide a valid start date'),
  body('endDate')
    .isISO8601()
    .withMessage('Please provide a valid end date'),
  body('type')
    .isIn(['CUTI_TAHUNAN', 'CUTI_SAKIT', 'CUTI_MELAHIRKAN', 'IZIN'])
    .withMessage('Invalid leave type'),
  body('reason')
    .isLength({ min: 10 })
    .withMessage('Reason must be at least 10 characters long'),
];

export const validateOvertime = [
  body('date')
    .isISO8601()
    .withMessage('Please provide a valid date'),
  body('hours')
    .isFloat({ min: 0.5, max: 12 })
    .withMessage('Hours must be between 0.5 and 12'),
  body('reason')
    .isLength({ min: 10 })
    .withMessage('Reason must be at least 10 characters long'),
];