"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.predictPerformance = exports.analyzePerformance = void 0;
const model = {
    features: {
        attendanceRate: { good: 0.8, poor: 0.3 },
        punctuality: { good: 0.7, poor: 0.2 },
        overtimeEfficiency: { good: 0.6, poor: 0.4 }
    },
    prior: { good: 0.6, poor: 0.4 }
};
const analyzePerformance = (data) => {
    const { attendances, overtimes, totalWorkingDays } = data;
    const presentDays = attendances.filter(att => att.status === 'PRESENT' || att.status === 'LATE').length;
    const attendanceRate = presentDays / totalWorkingDays;
    const lateDays = attendances.filter(att => att.status === 'LATE').length;
    const punctualityScore = presentDays > 0 ? 1 - (lateDays / presentDays) : 0;
    const approvedOvertime = overtimes.filter(ot => ot.status === 'APPROVED');
    const overtimeEfficiency = overtimes.length > 0 ? approvedOvertime.length / overtimes.length : 0;
    const likelihoodGood = (attendanceRate >= model.features.attendanceRate.good ? 1 : 0.1) *
        (punctualityScore >= model.features.punctuality.good ? 1 : 0.1) *
        (overtimeEfficiency >= model.features.overtimeEfficiency.good ? 1 : 0.1) *
        model.prior.good;
    const likelihoodPoor = (attendanceRate <= model.features.attendanceRate.poor ? 1 : 0.1) *
        (punctualityScore <= model.features.punctuality.poor ? 1 : 0.1) *
        (overtimeEfficiency <= model.features.overtimeEfficiency.poor ? 1 : 0.1) *
        model.prior.poor;
    const totalLikelihood = likelihoodGood + likelihoodPoor;
    const performanceScore = totalLikelihood > 0 ? likelihoodGood / totalLikelihood : 0.5;
    const rewardEligibility = performanceScore >= 0.7;
    const overtimeHours = approvedOvertime.reduce((sum, ot) => sum + ot.hours, 0);
    const baseOvertimeRate = 50000;
    const performanceMultiplier = 1 + (performanceScore * 0.5);
    const overtimeCost = overtimeHours * baseOvertimeRate * performanceMultiplier;
    return {
        performanceScore: Math.round(performanceScore * 100),
        rewardEligibility,
        overtimeCost: Math.round(overtimeCost)
    };
};
exports.analyzePerformance = analyzePerformance;
const predictPerformance = (employeeData) => {
    const predictions = new Map();
    employeeData.forEach((data, index) => {
        predictions.set(index, (0, exports.analyzePerformance)(data));
    });
    return predictions;
};
exports.predictPerformance = predictPerformance;
//# sourceMappingURL=naive-bayes.js.map