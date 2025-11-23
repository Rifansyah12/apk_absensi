import { NaiveBayesResult } from '../types';
import { Attendance, Overtime } from '@prisma/client';

interface PerformanceData {
  attendances: Attendance[];
  overtimes: Overtime[];
  totalWorkingDays: number;
}

interface NaiveBayesModel {
  features: {
    attendanceRate: { good: number; poor: number };
    punctuality: { good: number; poor: number };
    overtimeEfficiency: { good: number; poor: number };
  };
  prior: { good: number; poor: number };
}

// Training data (dalam implementasi real, ini akan berasal dari data historis)
const model: NaiveBayesModel = {
  features: {
    attendanceRate: { good: 0.8, poor: 0.3 },
    punctuality: { good: 0.7, poor: 0.2 },
    overtimeEfficiency: { good: 0.6, poor: 0.4 }
  },
  prior: { good: 0.6, poor: 0.4 }
};

export const analyzePerformance = (data: PerformanceData): NaiveBayesResult => {
  const { attendances, overtimes, totalWorkingDays } = data;
  
  // Calculate features
  const presentDays = attendances.filter(att => 
    att.status === 'PRESENT' || att.status === 'LATE'
  ).length;
  
  const attendanceRate = presentDays / totalWorkingDays;
  
  const lateDays = attendances.filter(att => att.status === 'LATE').length;
  const punctualityScore = presentDays > 0 ? 1 - (lateDays / presentDays) : 0;
  
  const approvedOvertime = overtimes.filter(ot => ot.status === 'APPROVED');
  const overtimeEfficiency = overtimes.length > 0 ? approvedOvertime.length / overtimes.length : 0;

  // Naïve Bayes Calculation
  const likelihoodGood = 
    (attendanceRate >= model.features.attendanceRate.good ? 1 : 0.1) *
    (punctualityScore >= model.features.punctuality.good ? 1 : 0.1) *
    (overtimeEfficiency >= model.features.overtimeEfficiency.good ? 1 : 0.1) *
    model.prior.good;

  const likelihoodPoor = 
    (attendanceRate <= model.features.attendanceRate.poor ? 1 : 0.1) *
    (punctualityScore <= model.features.punctuality.poor ? 1 : 0.1) *
    (overtimeEfficiency <= model.features.overtimeEfficiency.poor ? 1 : 0.1) *
    model.prior.poor;

  const totalLikelihood = likelihoodGood + likelihoodPoor;
  const performanceScore = totalLikelihood > 0 ? likelihoodGood / totalLikelihood : 0.5;

  // Determine outcomes based on performance score
  const rewardEligibility = performanceScore >= 0.7;
  
  // Calculate overtime cost with performance consideration
  const overtimeHours = approvedOvertime.reduce((sum, ot) => sum + ot.hours, 0);
  const baseOvertimeRate = 50000;
  const performanceMultiplier = 1 + (performanceScore * 0.5); // Better performance = higher rate
  const overtimeCost = overtimeHours * baseOvertimeRate * performanceMultiplier;

  return {
    performanceScore: Math.round(performanceScore * 100),
    rewardEligibility,
    overtimeCost: Math.round(overtimeCost)
  };
};

export const predictPerformance = (employeeData: PerformanceData[]): Map<number, NaiveBayesResult> => {
  const predictions = new Map<number, NaiveBayesResult>();
  
  employeeData.forEach((data, index) => {
    predictions.set(index, analyzePerformance(data));
  });
  
  return predictions;
};