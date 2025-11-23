"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportController = void 0;
const report_service_1 = require("../services/report-service");
const export_1 = require("../utils/export");
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
            const report = await reportService.generateAttendanceReport(req.user.division, filters);
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
    async exportAttendanceReport(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const filters = {
                startDate: req.query.startDate,
                endDate: req.query.endDate,
                division: req.query.division,
                employeeId: req.query.employeeId,
                type: req.query.type,
            };
            const format = req.query.format;
            const report = await reportService.generateAttendanceReport(req.user.division, filters);
            const columns = [
                { header: 'Nama', key: 'nama', width: 20 },
                { header: 'Jabatan', key: 'jabatan', width: 20 },
                { header: 'Tanggal', key: 'tanggal', width: 15 },
                { header: 'Jam Masuk', key: 'jamMasuk', width: 15 },
                { header: 'Jam Pulang', key: 'jamPulang', width: 15 },
                { header: 'Terlambat (menit)', key: 'terlambat', width: 15 },
                { header: 'Lembur (jam)', key: 'lembur', width: 15 },
                { header: 'Potongan', key: 'potongan', width: 15 },
                { header: 'Total Gaji', key: 'totalGaji', width: 15 },
                { header: 'Lokasi', key: 'lokasi', width: 20 },
            ];
            const filename = `Laporan_Absensi_${filters.startDate}_to_${filters.endDate}`;
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
            console.error('Export attendance report error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
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
exports.ReportController = ReportController;
//# sourceMappingURL=report-controller.js.map