import { Response } from 'express';
export declare enum ErrorType {
    VALIDATION_ERROR = "VALIDATION_ERROR",
    NOT_FOUND = "NOT_FOUND",
    UNAUTHORIZED = "UNAUTHORIZED",
    FORBIDDEN = "FORBIDDEN",
    CONFLICT = "CONFLICT",
    BAD_REQUEST = "BAD_REQUEST",
    INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR"
}
export declare class AppError extends Error {
    type: ErrorType;
    details?: any | undefined;
    constructor(type: ErrorType, message: string, details?: any | undefined);
}
export declare const handleServiceError: (error: any) => never;
export declare const sendErrorResponse: (res: Response, error: any) => void;
export declare const throwValidationError: (message: string, details?: any) => never;
export declare const throwNotFoundError: (message: string, details?: any) => never;
export declare const throwConflictError: (message: string, details?: any) => never;
//# sourceMappingURL=error-handler.d.ts.map