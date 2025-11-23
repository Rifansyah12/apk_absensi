"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SalaryController = void 0;
const client_1 = require("@prisma/client");
const decision_tree_1 = require("../utils/decision-tree");
const notification_1 = require("../utils/notification");
const prisma = new client_1.PrismaClient();
class SalaryController {
    async calculateSalary(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { month, year } = req.body;
            if (!month || !year) {
                res.status(400).json({
                    success: false,
                    message: 'Month and year are required',
                });
                return;
            }
            if (month < 1 || month > 12) {
                res.status(400).json({
                    success: false,
                    message: 'Month must be between 1 and 12',
                });
                return;
            }
            if (year < 2020 || year > 2030) {
                res.status(400).json({
                    success: false,
                    message: 'Year must be between 2020 and 2030',
                });
                return;
            }
            const users = await prisma.user.findMany({
                where: { isActive: true },
            });
            const results = [];
            const startDate = new Date(year, month - 1, 1);
            const endDate = new Date(year, month, 0);
            for (const user of users) {
                try {
                    const attendances = await prisma.attendance.findMany({
                        where: {
                            userId: user.id,
                            date: {
                                gte: startDate,
                                lte: endDate,
                            },
                        },
                    });
                    const overtimes = await prisma.overtime.findMany({
                        where: {
                            userId: user.id,
                            date: {
                                gte: startDate,
                                lte: endDate,
                            },
                            status: 'APPROVED',
                        },
                    });
                    const salaryData = {
                        attendances,
                        overtimes,
                        division: user.division,
                        month,
                        year,
                    };
                    const calculatedSalary = await (0, decision_tree_1.calculateSalary)(salaryData);
                    await prisma.salary.upsert({
                        where: {
                            userId_month_year: {
                                userId: user.id,
                                month,
                                year,
                            },
                        },
                        update: {
                            baseSalary: calculatedSalary.baseSalary,
                            overtimeSalary: calculatedSalary.overtimeSalary,
                            deduction: calculatedSalary.lateDeductions,
                            totalSalary: calculatedSalary.totalSalary,
                        },
                        create: {
                            userId: user.id,
                            month,
                            year,
                            baseSalary: calculatedSalary.baseSalary,
                            overtimeSalary: calculatedSalary.overtimeSalary,
                            deduction: calculatedSalary.lateDeductions,
                            totalSalary: calculatedSalary.totalSalary,
                        },
                    });
                    await (0, notification_1.sendNotification)(user.id, 'Gaji Telah Dihitung', `Gaji untuk periode ${month}/${year} telah dihitung. 
             Total: Rp ${calculatedSalary.totalSalary.toLocaleString('id-ID')}
             Detail: 
             - Gaji Pokok: Rp ${calculatedSalary.baseSalary.toLocaleString('id-ID')}
             - Lembur: Rp ${calculatedSalary.overtimeSalary.toLocaleString('id-ID')}
             - Potongan: Rp ${calculatedSalary.lateDeductions.toLocaleString('id-ID')}`, 'SALARY_RELEASED');
                    results.push({
                        userId: user.id,
                        name: user.name,
                        division: user.division,
                        success: true,
                        salary: calculatedSalary.totalSalary,
                        presentDays: calculatedSalary.presentDays,
                        totalLateMinutes: calculatedSalary.totalLateMinutes,
                        approvedOvertimeHours: calculatedSalary.approvedOvertimeHours,
                    });
                }
                catch (error) {
                    console.error(`Error calculating salary for user ${user.id}:`, error);
                    results.push({
                        userId: user.id,
                        name: user.name,
                        division: user.division,
                        success: false,
                        error: error.message,
                    });
                }
            }
            const successful = results.filter(r => r.success).length;
            const failed = results.filter(r => !r.success).length;
            res.json({
                success: true,
                message: `Salary calculation completed. Success: ${successful}, Failed: ${failed}`,
                data: {
                    period: { month, year },
                    processed: results.length,
                    successful,
                    failed,
                    results,
                },
            });
        }
        catch (error) {
            console.error('Calculate salary error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getMySalaries(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const salaries = await prisma.salary.findMany({
                where: { userId: req.user.id },
                orderBy: [{ year: 'desc' }, { month: 'desc' }],
            });
            res.json({
                success: true,
                data: salaries,
            });
        }
        catch (error) {
            console.error('Get salaries error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getSalaryById(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { id } = req.params;
            const salary = await prisma.salary.findUnique({
                where: { id: parseInt(id) },
            });
            if (!salary) {
                res.status(404).json({
                    success: false,
                    message: 'Salary not found',
                });
                return;
            }
            if (req.user.role !== 'SUPER_ADMIN' && req.user.id !== salary.userId) {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            res.json({
                success: true,
                data: salary,
            });
        }
        catch (error) {
            console.error('Get salary by id error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
}
exports.SalaryController = SalaryController;
//# sourceMappingURL=salary-controller.js.map