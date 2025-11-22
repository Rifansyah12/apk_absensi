import { Request } from 'express';
import { User, Division, Attendance, Overtime } from '@prisma/client';
export interface AuthRequest extends Request {
    user?: User;
}
export interface LoginRequest {
    email: string;
    password: string;
}
export interface RegisterRequest {
    employeeId: string;
    name: string;
    email: string;
    password: string;
    division: Division;
    position: string;
    joinDate: string;
    phone?: string;
    address?: string;
}
export interface AttendanceRequest {
    date?: string;
    checkIn?: string;
    checkOut?: string;
    locationCheckIn?: string;
    locationCheckOut?: string;
    selfieCheckIn?: string;
    selfieCheckOut?: string;
}
export interface LeaveRequest {
    startDate: string;
    endDate: string;
    type: string;
    reason: string;
}
export interface OvertimeRequest {
    date: string;
    hours: number;
    reason: string;
}
export interface ReportFilter {
    startDate?: string;
    endDate?: string;
    division?: Division;
    employeeId?: string;
    type: 'daily' | 'weekly' | 'monthly';
}
export interface SalaryCalculationData {
    userId: number;
    month: number;
    year: number;
    attendances: Attendance[];
    overtimes: Overtime[];
    division: Division;
}
export interface DecisionTreeResult {
    baseSalary: number;
    overtimeSalary: number;
    deductions: number;
    totalSalary: number;
}
export interface NaiveBayesResult {
    performanceScore: number;
    rewardEligibility: boolean;
    overtimeCost: number;
}
export interface GPSValidationResult {
    isValid: boolean;
    distance: number;
    message: string;
}
export interface FaceRecognitionResult {
    isMatch: boolean;
    confidence: number;
    message: string;
}
export interface AttendanceFormDataRequest {
    lat: string;
    lng: string;
    photo?: Express.Multer.File;
}
export interface AttendanceCheckInOutRequest {
    location: string;
    selfie: Buffer;
}
//# sourceMappingURL=index.d.ts.map