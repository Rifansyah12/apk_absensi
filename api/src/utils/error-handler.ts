import { Response } from 'express';
import { Prisma } from '@prisma/client';

export enum ErrorType {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  CONFLICT = 'CONFLICT',
  BAD_REQUEST = 'BAD_REQUEST',
  INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR'
}

export class AppError extends Error {
  constructor(
    public type: ErrorType,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export const handleServiceError = (error: any): never => {
  console.error('Service Error:', error);

  // Handle Prisma errors
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case 'P2002':
        throw new AppError(
          ErrorType.CONFLICT,
          'Data already exists',
          { target: error.meta?.target }
        );
      case 'P2025':
        throw new AppError(
          ErrorType.NOT_FOUND,
          'Record not found',
          { cause: error.meta?.cause }
        );
      case 'P2003':
        throw new AppError(
          ErrorType.VALIDATION_ERROR,
          'Foreign key constraint failed',
          { field: error.meta?.field_name }
        );
      default:
        throw new AppError(
          ErrorType.INTERNAL_SERVER_ERROR,
          `Database error: ${error.code}`,
          { code: error.code }
        );
    }
  }

  // Handle Prisma unknown errors
  if (error instanceof Prisma.PrismaClientUnknownRequestError) {
    throw new AppError(
      ErrorType.INTERNAL_SERVER_ERROR,
      'Unknown database error'
    );
  }

  // Handle validation errors
  if (error instanceof AppError) {
    throw error;
  }

  // Handle other errors
  throw new AppError(
    ErrorType.INTERNAL_SERVER_ERROR,
    error.message || 'Internal server error'
  );
};

export const sendErrorResponse = (res: Response, error: any): void => {
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
  } else {
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Helper functions untuk common errors
export const throwValidationError = (message: string, details?: any): never => {
  throw new AppError(ErrorType.VALIDATION_ERROR, message, details);
};

export const throwNotFoundError = (message: string, details?: any): never => {
  throw new AppError(ErrorType.NOT_FOUND, message, details);
};

export const throwConflictError = (message: string, details?: any): never => {
  throw new AppError(ErrorType.CONFLICT, message, details);
};