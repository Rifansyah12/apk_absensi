"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.financeController = exports.FinanceController = void 0;
const client_1 = require("@prisma/client");
const error_handler_1 = require("../utils/error-handler");
const report_service_1 = require("../services/report-service");
const export_1 = require("../utils/export");
const reportService = new report_service_1.ReportService();
const prisma = new client_1.PrismaClient();
class FinanceController {
    async getFinanceDashboard(req, res) {
        try {
            const { month = new Date().getMonth() + 1, year = new Date().getFullYear() } = req.query;
            const salaryStats = await prisma.salary.aggregate({
                where: {
                    month: parseInt(month),
                    year: parseInt(year)
                },
                _sum: {
                    baseSalary: true,
                    overtimeSalary: true,
                    deduction: true,
                    totalSalary: true
                },
                _count: {
                    id: true
                }
            });
            const lateDeductions = await prisma.attendance.aggregate({
                where: {
                    date: {
                        gte: new Date(parseInt(year), parseInt(month) - 1, 1),
                        lt: new Date(parseInt(year), parseInt(month), 1)
                    },
                    lateMinutes: {
                        gt: 0
                    }
                },
                _sum: {
                    lateMinutes: true
                },
                _count: {
                    id: true
                }
            });
            const overtimeStats = await prisma.overtime.aggregate({
                where: {
                    date: {
                        gte: new Date(parseInt(year), parseInt(month) - 1, 1),
                        lt: new Date(parseInt(year), parseInt(month), 1)
                    },
                    status: 'APPROVED'
                },
                _sum: {
                    hours: true
                },
                _count: {
                    id: true
                }
            });
            res.json({
                success: true,
                data: {
                    salarySummary: {
                        totalEmployees: salaryStats._count.id,
                        totalBaseSalary: salaryStats._sum.baseSalary || 0,
                        totalOvertime: salaryStats._sum.overtimeSalary || 0,
                        totalDeductions: salaryStats._sum.deduction || 0,
                        netSalary: salaryStats._sum.totalSalary || 0
                    },
                    lateSummary: {
                        totalLateIncidents: lateDeductions._count.id,
                        totalLateMinutes: lateDeductions._sum.lateMinutes || 0,
                        estimatedDeduction: (lateDeductions._sum.lateMinutes || 0) * 5000
                    },
                    overtimeSummary: {
                        totalOvertimeHours: overtimeStats._sum.hours || 0,
                        totalOvertimeCases: overtimeStats._count.id
                    }
                }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getFinancialReport(req, res) {
        try {
            const { startDate, endDate, division } = req.query;
            const whereClause = {
                date: {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                }
            };
            if (division) {
                whereClause.user = {
                    division: division
                };
            }
            const salaries = await prisma.salary.findMany({
                where: {
                    month: new Date(startDate).getMonth() + 1,
                    year: new Date(startDate).getFullYear()
                },
                include: {
                    user: {
                        select: {
                            name: true,
                            division: true,
                            position: true
                        }
                    }
                }
            });
            const deductions = await prisma.attendance.findMany({
                where: whereClause,
                include: {
                    user: {
                        select: {
                            name: true,
                            division: true
                        }
                    }
                }
            });
            res.json({
                success: true,
                data: {
                    salaries,
                    deductions: deductions.filter(d => d.lateMinutes > 0),
                    summary: {
                        totalSalary: salaries.reduce((sum, s) => sum + s.totalSalary, 0),
                        totalDeductions: salaries.reduce((sum, s) => sum + s.deduction, 0),
                        totalOvertime: salaries.reduce((sum, s) => sum + s.overtimeSalary, 0)
                    }
                }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async updateDeductionSettings(req, res) {
        try {
            const { division } = req.params;
            const { deductionPerMinute, lateThreshold } = req.body;
            const updatedSetting = await prisma.divisionSetting.update({
                where: { division: division },
                data: {
                    deductionPerMinute,
                    lateThreshold
                }
            });
            res.json({
                success: true,
                message: 'Deduction settings updated successfully',
                data: updatedSetting
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async exportSalaryReport(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { month, year, division } = req.query;
            const format = req.query.format;
            const report = await reportService.generateSalaryReport(parseInt(month) || new Date().getMonth() + 1, parseInt(year) || new Date().getFullYear(), division);
            const columns = [
                { header: 'Nama', key: 'nama', width: 25 },
                { header: 'Jabatan', key: 'jabatan', width: 25 },
                { header: 'Divisi', key: 'divisi', width: 15 },
                { header: 'Gaji Pokok', key: 'gajiPokok', width: 20 },
                { header: 'Lembur', key: 'lembur', width: 15 },
                { header: 'Potongan', key: 'potongan', width: 15 },
                { header: 'Total Gaji', key: 'totalGaji', width: 20 },
            ];
            const monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
            const monthName = monthNames[parseInt(month) - 1] || '';
            const filename = `Laporan_Gaji_${monthName}_${year}`;
            if (format === 'excel') {
                await export_1.ExportUtils.exportToExcel(report, columns, filename, res);
            }
            else if (format === 'pdf') {
                export_1.ExportUtils.exportToPDF(report, columns, filename, res);
            }
            else {
                res.status(400).json({
                    success: false,
                    message: 'Format must be excel or pdf',
                });
            }
        }
        catch (error) {
            console.error('Export salary report error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
}
exports.FinanceController = FinanceController;
exports.financeController = new FinanceController();
//# sourceMappingURL=finance-controller.js.map