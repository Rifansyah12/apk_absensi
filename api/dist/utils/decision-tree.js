"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateSalary = void 0;
const calculateSalary = (data) => {
    const { attendances, overtimes, division } = data;
    const baseSalaries = {
        'FINANCE': 8000000,
        'APO': 7500000,
        'FRONT_DESK': 6000000,
        'ONSITE': 7000000
    };
    const baseSalary = baseSalaries[division] || 6000000;
    const totalLateMinutes = attendances.reduce((sum, att) => sum + att.lateMinutes, 0);
    const deductionRates = {
        'FINANCE': 1000,
        'APO': 900,
        'FRONT_DESK': 800,
        'ONSITE': 850
    };
    const deductionPerMinute = deductionRates[division] || 1000;
    const deductions = totalLateMinutes * deductionPerMinute;
    const approvedOvertimeHours = overtimes
        .filter(ot => ot.status === 'APPROVED')
        .reduce((sum, ot) => sum + ot.hours, 0);
    const overtimeRate = baseSalary / 173;
    const overtimeSalary = approvedOvertimeHours * overtimeRate * 1.5;
    const totalSalary = baseSalary + overtimeSalary - deductions;
    return {
        baseSalary,
        overtimeSalary,
        deductions,
        totalSalary: Math.max(0, totalSalary)
    };
};
exports.calculateSalary = calculateSalary;
//# sourceMappingURL=decision-tree.js.map