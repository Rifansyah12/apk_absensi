"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportController = void 0;
const report_service_1 = require("../services/report-service");
const reportService = new report_service_1.ReportService();
class ReportController {
    async getAttendanceReport(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const filters = {
                startDate: req.query.startDate,
                endDate: req.query.endDate,
                division: req.query.division,
                employeeId: req.query.employeeId,
                type: req.query.type || 'monthly',
            };
            const report = await reportService.generateAttendanceReport(filters);
            res.json({
                success: true,
                data: report,
            });
        }
        catch (error) {
            console.error('Get attendance report error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getSalaryReport(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { month, year, division } = req.query;
            const report = await reportService.generateSalaryReport(parseInt(month) || new Date().getMonth() + 1, parseInt(year) || new Date().getFullYear(), division);
            res.json({
                success: true,
                data: report,
            });
        }
        catch (error) {
            console.error('Get salary report error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getDashboardStats(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { division } = req.query;
            const userDivision = req.user.role === 'SUPER_ADMIN' ? division : req.user.division;
            const stats = await reportService.getDashboardStats(userDivision);
            res.json({
                success: true,
                data: stats,
            });
        }
        catch (error) {
            console.error('Get dashboard stats error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getPersonalReport(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { month, year } = req.query;
            const targetMonth = parseInt(month) || new Date().getMonth() + 1;
            const targetYear = parseInt(year) || new Date().getFullYear();
            const summary = await reportService.getPersonalAttendanceSummary(req.user.id, targetMonth, targetYear);
            res.json({
                success: true,
                data: summary,
            });
        }
        catch (error) {
            console.error('Get personal report error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
}
exports.ReportController = ReportController;
//# sourceMappingURL=report-controller.js.map