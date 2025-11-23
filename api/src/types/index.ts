import { Request } from 'express';
import { User, Division } from '@prisma/client';

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

export interface UserCreateData {
  employeeId: string;
  name: string;
  email: string;
  password: string;
  division: string;
  position: string;
  joinDate: string | Date;
  phone?: string; // Ubah dari string | undefined menjadi string
  address?: string; // Ubah dari string | undefined menjadi string
  photo?: string; // Tambahkan photo sebagai optional
}

export interface UserUpdateData {
  name: string;
  email: string;
  division: Division;
  position: string;
  phone?: string | null;
  address?: string | null;
  photo?: string;
  isActive?: boolean;
  employeeId: string;
}

export type UserWithoutPassword = {
  id: number;
  employeeId: string;
  name: string;
  email: string;
  division: Division;
  role: Role;
  position: string;
  joinDate: Date;
  phone?: string | null;
  address?: string | null;
  photo?: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
};

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
  attendances: Array<{
    status: 'PRESENT' | 'LATE' | 'ABSENT' | 'SICK' | 'LEAVE';
    lateMinutes: number;
    date: Date;
  }>;
  overtimes: Array<{
    status: 'APPROVED' | 'REJECTED' | 'PENDING';
    hours: number;
    date: Date;
  }>;
  division: Division; // Ubah dari string ke Division
  month: number;
  year: number;
}

// HAPUS duplikat dan gunakan yang ini saja
export interface DecisionTreeResult {
  baseSalary: number;
  overtimeSalary: number;
  lateDeductions: number; // Ganti deductions menjadi lateDeductions
  totalSalary: number;
  presentDays: number;
  totalLateMinutes: number;
  approvedOvertimeHours: number;
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

export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

export interface UpdateProfileRequest {
  password?: string;
  currentPassword?: string;
  // Photo akan ditangani sebagai file upload
}

// src/types/help.ts
export interface HelpContent {
  id: number;
  division?: Division;
  title: string;
  content: string;
  type: HelpContentType;
  order: number;
  isActive: boolean;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}


export interface HelpResponse {
  faqs: HelpContent[];
  contacts: HelpContent[];
  appInfo: HelpContent[];
  general: HelpContent[];
}

export interface CreateHelpContentRequest {
  division?: Division | null;
  title: string;
  content: string;
  type: HelpContentType;
  order?: number;
  isActive?: boolean;
}

export interface UpdateHelpContentRequest {
  division?: Division | null;
  title?: string;
  content?: string;
  type?: HelpContentType;
  order?: number;
  isActive?: boolean;
}

export enum HelpContentType {
  FAQ = 'FAQ',
  CONTACT = 'CONTACT',
  APP_INFO = 'APP_INFO',
  GENERAL = 'GENERAL'
}

enum Role {
  USER = 'USER',
  SUPER_ADMIN = 'SUPER_ADMIN',
  SUPER_ADMIN_FINANCE = 'SUPER_ADMIN_FINANCE',
  SUPER_ADMIN_APO = 'SUPER_ADMIN_APO',
  SUPER_ADMIN_FRONT_DESK = 'SUPER_ADMIN_FRONT_DESK',
  SUPER_ADMIN_ONSITE = 'SUPER_ADMIN_ONSITE'
}