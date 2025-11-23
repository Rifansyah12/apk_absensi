import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { analyzePerformance } from '../utils/naive-bayes'; // Hapus predictPerformance

const prisma = new PrismaClient();

export class AnalysisController {
  async getPerformanceAnalysis(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { month, year } = req.query;
      const targetMonth = month ? parseInt(month as string) : new Date().getMonth() + 1;
      const targetYear = year ? parseInt(year as string) : new Date().getFullYear();

      // Get all active users
      const users = await prisma.user.findMany({
        where: { 
          isActive: true,
          role: 'USER' // Only analyze regular employees, not admins
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
      const totalWorkingDays = 22; // Assume 22 working days per month

      for (const user of users) {
        const performanceData = {
          attendances: user.attendances,
          overtimes: user.overtimes,
          totalWorkingDays,
        };

        const result = analyzePerformance(performanceData);
        
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

      // Sort by performance score (descending)
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
    } catch (error: any) {
      console.error('Get performance analysis error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  private generateRecommendations(result: any): string[] {
    const recommendations = [];

    if (result.performanceScore >= 80) {
      recommendations.push('Eligible for performance bonus');
      recommendations.push('Consider for promotion');
      recommendations.push('Assign to leadership training');
    } else if (result.performanceScore >= 60) {
      recommendations.push('Good performance, maintain current level');
      recommendations.push('Provide additional skills training');
    } else {
      recommendations.push('Needs performance improvement plan');
      recommendations.push('Schedule mentoring sessions');
      recommendations.push('Review attendance patterns');
    }

    if (result.rewardEligibility) {
      recommendations.push('Qualified for quarterly reward');
    }

    return recommendations;
  }

  private generateSummary(analysis: any[]): any {
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