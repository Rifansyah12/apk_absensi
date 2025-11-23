"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateSalary = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const calculateSalary = async (data) => {
    const { attendances, overtimes, division } = data;
    try {
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
        const presentDays = attendances.filter(att => att.status === 'PRESENT' || att.status === 'LATE').length;
        const totalLateMinutes = attendances.reduce((sum, att) => sum + (att.lateMinutes || 0), 0);
        const lateDeductions = totalLateMinutes * deductionPerMinute;
        const approvedOvertimeHours = overtimes
            .filter(ot => ot.status === 'APPROVED')
            .reduce((sum, ot) => sum + ot.hours, 0);
        const hoursPerMonth = workingDaysPerMonth * 8;
        const hourlyRate = baseSalary / hoursPerMonth;
        const overtimeSalary = approvedOvertimeHours * hourlyRate * overtimeRateMultiplier;
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
    }
    catch (error) {
        console.error('Salary calculation error:', error);
        throw new Error(`Failed to calculate salary: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
};
exports.calculateSalary = calculateSalary;
//# sourceMappingURL=decision-tree.js.map