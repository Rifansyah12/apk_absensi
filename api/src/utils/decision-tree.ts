import { PrismaClient } from '@prisma/client';
import { DecisionTreeResult, SalaryCalculationData } from '../types';

const prisma = new PrismaClient();

export const calculateSalary = async (data: SalaryCalculationData): Promise<DecisionTreeResult> => {
  const { attendances, overtimes, division } = data; // Hapus month dan year yang tidak digunakan
  
  try {
    // Ambil pengaturan divisi dari database
    const divisionSetting = await prisma.divisionSetting.findUnique({
      where: { division }
    });

    if (!divisionSetting) {
      throw new Error(`Division setting not found for division: ${division}`);
    }

    const baseSalary = divisionSetting.baseSalary;
    const deductionPerMinute = divisionSetting.deductionPerMinute;
    const overtimeRateMultiplier = divisionSetting.overtimeRateMultiplier;
    const workingDaysPerMonth = divisionSetting.workingDaysPerMonth;

    // Calculate actual present days
    const presentDays = attendances.filter(att => 
      att.status === 'PRESENT' || att.status === 'LATE'
    ).length;

    // Calculate late deductions
    const totalLateMinutes = attendances.reduce((sum, att) => sum + (att.lateMinutes || 0), 0);
    const lateDeductions = totalLateMinutes * deductionPerMinute;

    // Calculate overtime salary
    const approvedOvertimeHours = overtimes
      .filter(ot => ot.status === 'APPROVED')
      .reduce((sum, ot) => sum + ot.hours, 0);
    
    // Hitung rate per jam: gaji pokok / (hari kerja × 8 jam)
    const hoursPerMonth = workingDaysPerMonth * 8;
    const hourlyRate = baseSalary / hoursPerMonth;
    const overtimeSalary = approvedOvertimeHours * hourlyRate * overtimeRateMultiplier;

    // Hitung gaji total
    const totalSalary = baseSalary + overtimeSalary - lateDeductions;

    return {
      baseSalary,
      overtimeSalary,
      lateDeductions,
      totalSalary: Math.max(0, totalSalary),
      presentDays,
      totalLateMinutes,
      approvedOvertimeHours
    };
  } catch (error) {
    console.error('Salary calculation error:', error);
    throw new Error(`Failed to calculate salary: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
};