import { DecisionTreeResult, SalaryCalculationData } from '../types';

export const calculateSalary = (data: SalaryCalculationData): DecisionTreeResult => {
  const { attendances, overtimes, division } = data;
  
  // Base salary based on division
  const baseSalaries: Record<string, number> = {
    'FINANCE': 8000000,
    'APO': 7500000,
    'FRONT_DESK': 6000000,
    'ONSITE': 7000000
  };

  const baseSalary = baseSalaries[division] || 6000000;
  
  // Calculate working days (for information, but not used in calculation)
  // const _workingDays = attendances.filter(att => 
  //   att.status === 'PRESENT' || att.status === 'LATE'
  // ).length;

  // Calculate deductions for lateness
  const totalLateMinutes = attendances.reduce((sum, att) => sum + att.lateMinutes, 0);
  
  // Get division settings for deduction rate
  const deductionRates: Record<string, number> = {
    'FINANCE': 1000,
    'APO': 900,
    'FRONT_DESK': 800,
    'ONSITE': 850
  };
  
  const deductionPerMinute = deductionRates[division] || 1000;
  const deductions = totalLateMinutes * deductionPerMinute;

  // Calculate overtime salary
  const approvedOvertimeHours = overtimes
    .filter(ot => ot.status === 'APPROVED')
    .reduce((sum, ot) => sum + ot.hours, 0);
  
  const overtimeRate = baseSalary / 173; // Hourly rate
  const overtimeSalary = approvedOvertimeHours * overtimeRate * 1.5; // 1.5x for overtime

  const totalSalary = baseSalary + overtimeSalary - deductions;

  return {
    baseSalary,
    overtimeSalary,
    deductions,
    totalSalary: Math.max(0, totalSalary)
  };
};