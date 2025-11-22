"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyzePerformance = void 0;
const analyzePerformance = (data) => {
    const { attendances, overtimes, totalWorkingDays } = data;
    const presentDays = attendances.filter(att => att.status === 'PRESENT' || att.status === 'LATE').length;
    const attendanceRate = presentDays / totalWorkingDays;
    const lateDays = attendances.filter(att => att.status === 'LATE').length;
    const punctualityScore = 1 - (lateDays / presentDays);
    const approvedOvertime = overtimes.filter(ot => ot.status === 'APPROVED');
    const overtimeEfficiency = approvedOvertime.length / Math.max(1, overtimes.length);
    const weights = {
        attendance: 0.4,
        punctuality: 0.3,
        overtime: 0.3
    };
    const performanceScore = (attendanceRate * weights.attendance) +
        (punctualityScore * weights.punctuality) +
        (overtimeEfficiency * weights.overtime);
    const rewardEligibility = performanceScore >= 0.8;
    const overtimeHours = approvedOvertime.reduce((sum, ot) => sum + ot.hours, 0);
    const baseOvertimeRate = 50000;
    const overtimeCost = overtimeHours * baseOvertimeRate * (performanceScore + 0.5);
    return {
        performanceScore: Math.round(performanceScore * 100),
        rewardEligibility,
        overtimeCost: Math.round(overtimeCost)
    };
};
exports.analyzePerformance = analyzePerformance;
//# sourceMappingURL=naive-bayes.js.map