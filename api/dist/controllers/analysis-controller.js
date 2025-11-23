"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalysisController = void 0;
const client_1 = require("@prisma/client");
const naive_bayes_1 = require("../utils/naive-bayes");
const prisma = new client_1.PrismaClient();
class AnalysisController {
    async getPerformanceAnalysis(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { month, year } = req.query;
            const targetMonth = month ? parseInt(month) : new Date().getMonth() + 1;
            const targetYear = year ? parseInt(year) : new Date().getFullYear();
            const users = await prisma.user.findMany({
                where: {
                    isActive: true,
                    role: 'USER'
                },
                include: {
                    attendances: {
                        where: {
                            date: {
                                gte: new Date(targetYear, targetMonth - 1, 1),
                                lte: new Date(targetYear, targetMonth, 0),
                            },
                        },
                    },
                    overtimes: {
                        where: {
                            date: {
                                gte: new Date(targetYear, targetMonth - 1, 1),
                                lte: new Date(targetYear, targetMonth, 0),
                            },
                        },
                    },
                },
            });
            const analysisResults = [];
            const totalWorkingDays = 22;
            for (const user of users) {
                const performanceData = {
                    attendances: user.attendances,
                    overtimes: user.overtimes,
                    totalWorkingDays,
                };
                const result = (0, naive_bayes_1.analyzePerformance)(performanceData);
                analysisResults.push({
                    userId: user.id,
                    employeeId: user.employeeId,
                    name: user.name,
                    division: user.division,
                    position: user.position,
                    ...result,
                    recommendations: this.generateRecommendations(result),
                });
            }
            analysisResults.sort((a, b) => b.performanceScore - a.performanceScore);
            res.json({
                success: true,
                data: {
                    month: targetMonth,
                    year: targetYear,
                    analysis: analysisResults,
                    summary: this.generateSummary(analysisResults),
                },
            });
        }
        catch (error) {
            console.error('Get performance analysis error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    generateRecommendations(result) {
        const recommendations = [];
        if (result.performanceScore >= 80) {
            recommendations.push('Eligible for performance bonus');
            recommendations.push('Consider for promotion');
            recommendations.push('Assign to leadership training');
        }
        else if (result.performanceScore >= 60) {
            recommendations.push('Good performance, maintain current level');
            recommendations.push('Provide additional skills training');
        }
        else {
            recommendations.push('Needs performance improvement plan');
            recommendations.push('Schedule mentoring sessions');
            recommendations.push('Review attendance patterns');
        }
        if (result.rewardEligibility) {
            recommendations.push('Qualified for quarterly reward');
        }
        return recommendations;
    }
    generateSummary(analysis) {
        const totalEmployees = analysis.length;
        const highPerformers = analysis.filter(a => a.performanceScore >= 80).length;
        const mediumPerformers = analysis.filter(a => a.performanceScore >= 60 && a.performanceScore < 80).length;
        const lowPerformers = analysis.filter(a => a.performanceScore < 60).length;
        const totalOvertimeCost = analysis.reduce((sum, a) => sum + a.overtimeCost, 0);
        const avgPerformanceScore = analysis.reduce((sum, a) => sum + a.performanceScore, 0) / totalEmployees;
        return {
            totalEmployees,
            highPerformers,
            mediumPerformers,
            lowPerformers,
            totalOvertimeCost,
            avgPerformanceScore: Math.round(avgPerformanceScore),
            rewardEligible: analysis.filter(a => a.rewardEligibility).length,
        };
    }
}
exports.AnalysisController = AnalysisController;
//# sourceMappingURL=analysis-controller.js.map