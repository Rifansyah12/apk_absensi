import { NaiveBayesResult } from '../types';
import { Attendance, Overtime } from '@prisma/client';

interface PerformanceData {
  attendances: Attendance[];
  overtimes: Overtime[];
  totalWorkingDays: number;
}

export const analyzePerformance = (data: PerformanceData): NaiveBayesResult => {
  const { attendances, overtimes, totalWorkingDays } = data;
  
  // Calculate attendance rate
  const presentDays = attendances.filter(att => 
    att.status === 'PRESENT' || att.status === 'LATE'
  ).length;
  
  const attendanceRate = presentDays / totalWorkingDays;
  
  // Calculate punctuality
  const lateDays = attendances.filter(att => att.status === 'LATE').length;
  const punctualityScore = 1 - (lateDays / presentDays);
  
  // Calculate overtime efficiency
  const approvedOvertime = overtimes.filter(ot => ot.status === 'APPROVED');
  const overtimeEfficiency = approvedOvertime.length / Math.max(1, overtimes.length);
  
  // Naive Bayes calculation for performance score
  const weights = {
    attendance: 0.4,
    punctuality: 0.3,
    overtime: 0.3
  };
  
  const performanceScore = 
    (attendanceRate * weights.attendance) +
    (punctualityScore * weights.punctuality) +
    (overtimeEfficiency * weights.overtime);
  
  // Determine reward eligibility
  const rewardEligibility = performanceScore >= 0.8;
  
  // Calculate overtime cost (simplified)
  const overtimeHours = approvedOvertime.reduce((sum, ot) => sum + ot.hours, 0);
  const baseOvertimeRate = 50000; // Base overtime rate per hour
  const overtimeCost = overtimeHours * baseOvertimeRate * (performanceScore + 0.5);

  return {
    performanceScore: Math.round(performanceScore * 100),
    rewardEligibility,
    overtimeCost: Math.round(overtimeCost)
  };
};