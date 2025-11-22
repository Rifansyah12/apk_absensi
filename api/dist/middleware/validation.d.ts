import { Response, NextFunction } from 'express';
import { AuthRequest } from '../types';
export declare const handleValidationErrors: (req: AuthRequest, res: Response, next: NextFunction) => void;
export declare const validateLogin: import("express-validator").ValidationChain[];
export declare const validateAttendance: import("express-validator").ValidationChain[];
export declare const validateLeave: import("express-validator").ValidationChain[];
export declare const validateOvertime: import("express-validator").ValidationChain[];
//# sourceMappingURL=validation.d.ts.map