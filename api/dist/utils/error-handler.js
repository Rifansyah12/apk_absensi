"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.throwConflictError = exports.throwNotFoundError = exports.throwValidationError = exports.sendErrorResponse = exports.handleServiceError = exports.AppError = exports.ErrorType = void 0;
const client_1 = require("@prisma/client");
var ErrorType;
(function (ErrorType) {
    ErrorType["VALIDATION_ERROR"] = "VALIDATION_ERROR";
    ErrorType["NOT_FOUND"] = "NOT_FOUND";
    ErrorType["UNAUTHORIZED"] = "UNAUTHORIZED";
    ErrorType["FORBIDDEN"] = "FORBIDDEN";
    ErrorType["CONFLICT"] = "CONFLICT";
    ErrorType["BAD_REQUEST"] = "BAD_REQUEST";
    ErrorType["INTERNAL_SERVER_ERROR"] = "INTERNAL_SERVER_ERROR";
})(ErrorType || (exports.ErrorType = ErrorType = {}));
class AppError extends Error {
    constructor(type, message, details) {
        super(message);
        this.type = type;
        this.details = details;
        this.name = 'AppError';
    }
}
exports.AppError = AppError;
const handleServiceError = (error) => {
    console.error('Service Error:', error);
    if (error instanceof client_1.Prisma.PrismaClientKnownRequestError) {
        switch (error.code) {
            case 'P2002':
                throw new AppError(ErrorType.CONFLICT, 'Data already exists', { target: error.meta?.target });
            case 'P2025':
                throw new AppError(ErrorType.NOT_FOUND, 'Record not found', { cause: error.meta?.cause });
            case 'P2003':
                throw new AppError(ErrorType.VALIDATION_ERROR, 'Foreign key constraint failed', { field: error.meta?.field_name });
            default:
                throw new AppError(ErrorType.INTERNAL_SERVER_ERROR, `Database error: ${error.code}`, { code: error.code });
        }
    }
    if (error instanceof client_1.Prisma.PrismaClientUnknownRequestError) {
        throw new AppError(ErrorType.INTERNAL_SERVER_ERROR, 'Unknown database error');
    }
    if (error instanceof AppError) {
        throw error;
    }
    throw new AppError(ErrorType.INTERNAL_SERVER_ERROR, error.message || 'Internal server error');
};
exports.handleServiceError = handleServiceError;
const sendErrorResponse = (res, error) => {
    console.error('Error Response:', error);
    if (error instanceof AppError) {
        switch (error.type) {
            case ErrorType.VALIDATION_ERROR:
                res.status(400).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            case ErrorType.NOT_FOUND:
                res.status(404).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            case ErrorType.UNAUTHORIZED:
                res.status(401).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            case ErrorType.FORBIDDEN:
                res.status(403).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            case ErrorType.CONFLICT:
                res.status(409).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            case ErrorType.BAD_REQUEST:
                res.status(400).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
                break;
            default:
                res.status(500).json({
                    success: false,
                    message: error.message,
                    error: error.details
                });
        }
    }
    else {
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
exports.sendErrorResponse = sendErrorResponse;
const throwValidationError = (message, details) => {
    throw new AppError(ErrorType.VALIDATION_ERROR, message, details);
};
exports.throwValidationError = throwValidationError;
const throwNotFoundError = (message, details) => {
    throw new AppError(ErrorType.NOT_FOUND, message, details);
};
exports.throwNotFoundError = throwNotFoundError;
const throwConflictError = (message, details) => {
    throw new AppError(ErrorType.CONFLICT, message, details);
};
exports.throwConflictError = throwConflictError;
//# sourceMappingURL=error-handler.js.map