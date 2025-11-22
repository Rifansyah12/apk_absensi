import { NaiveBayesResult } from '../types';
import { Attendance, Overtime } from '@prisma/client';
interface PerformanceData {
    attendances: Attendance[];
    overtimes: Overtime[];
    totalWorkingDays: number;
}
export declare const analyzePerformance: (data: PerformanceData) => NaiveBayesResult;
export {};
//# sourceMappingURL=naive-bayes.d.ts.map