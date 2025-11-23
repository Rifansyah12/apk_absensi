"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onsiteController = exports.OnsiteController = void 0;
const client_1 = require("@prisma/client");
const error_handler_1 = require("../utils/error-handler");
const gps_1 = require("../utils/gps");
const prisma = new client_1.PrismaClient();
class OnsiteController {
    async validateGPSCheckIn(req, res) {
        try {
            const { userId, latitude, longitude } = req.body;
            if (!userId || !latitude || !longitude) {
                res.status(400).json({
                    success: false,
                    message: 'userId, latitude, dan longitude diperlukan'
                });
                return;
            }
            const onsiteLocations = await prisma.onsiteLocation.findMany({
                where: {
                    isActive: true
                }
            });
            let isValidLocation = false;
            let validatedLocation = null;
            for (const location of onsiteLocations) {
                const distance = (0, gps_1.calculateDistance)(parseFloat(latitude), parseFloat(longitude), location.latitude, location.longitude);
                if (distance <= location.radius) {
                    isValidLocation = true;
                    validatedLocation = location;
                    break;
                }
            }
            if (!isValidLocation) {
                res.status(400).json({
                    success: false,
                    message: 'Anda tidak berada dalam radius lokasi onsite yang valid',
                    data: { isValid: false }
                });
                return;
            }
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const existingAttendance = await prisma.attendance.findFirst({
                where: {
                    userId: parseInt(userId),
                    date: {
                        gte: today,
                        lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
                    }
                }
            });
            let attendance;
            if (existingAttendance) {
                attendance = await prisma.attendance.update({
                    where: { id: existingAttendance.id },
                    data: {
                        checkIn: new Date(),
                        locationCheckIn: `${validatedLocation?.name} (${latitude}, ${longitude})`,
                        notes: `Validated onsite location: ${validatedLocation?.name}`,
                        status: 'PRESENT'
                    },
                    include: {
                        user: {
                            select: {
                                name: true,
                                division: true
                            }
                        }
                    }
                });
            }
            else {
                attendance = await prisma.attendance.create({
                    data: {
                        userId: parseInt(userId),
                        date: today,
                        checkIn: new Date(),
                        locationCheckIn: `${validatedLocation?.name} (${latitude}, ${longitude})`,
                        notes: `Validated onsite location: ${validatedLocation?.name}`,
                        status: 'PRESENT'
                    },
                    include: {
                        user: {
                            select: {
                                name: true,
                                division: true
                            }
                        }
                    }
                });
            }
            res.json({
                success: true,
                message: 'GPS validation successful',
                data: {
                    isValid: true,
                    location: validatedLocation?.name,
                    attendance,
                    action: existingAttendance ? 'updated' : 'created'
                }
            });
        }
        catch (error) {
            console.error('Validate GPS CheckIn error:', error);
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getFieldMonitoring(_req, res) {
        try {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const onsiteEmployees = await prisma.attendance.findMany({
                where: {
                    date: {
                        gte: today
                    },
                    user: {
                        division: 'ONSITE'
                    },
                    checkIn: {
                        not: null
                    },
                    checkOut: null
                },
                include: {
                    user: {
                        select: {
                            name: true,
                            position: true,
                            phone: true
                        }
                    }
                }
            });
            const activeLocations = await prisma.onsiteLocation.findMany({
                where: {
                    isActive: true
                }
            });
            res.json({
                success: true,
                data: {
                    onsiteEmployees,
                    activeLocations,
                    summary: {
                        totalOnsite: onsiteEmployees.length,
                        totalLocations: activeLocations.length,
                        employeesPerLocation: this.groupEmployeesByLocation(onsiteEmployees)
                    }
                }
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async processOvertimeOnsite(req, res) {
        try {
            const { overtimeId } = req.params;
            const { status, notes } = req.body;
            const overtime = await prisma.overtime.findUnique({
                where: { id: parseInt(overtimeId) },
                include: {
                    user: true
                }
            });
            if (!overtime) {
                res.status(404).json({
                    success: false,
                    message: 'Overtime request not found'
                });
                return;
            }
            if (overtime.user.division !== 'ONSITE') {
                res.status(400).json({
                    success: false,
                    message: 'Can only process overtime for ONSITE division employees'
                });
                return;
            }
            const updatedOvertime = await prisma.overtime.update({
                where: { id: parseInt(overtimeId) },
                data: {
                    status: status,
                    notes: notes || `Processed by Onsite Supervisor: ${status}`
                }
            });
            await prisma.notification.create({
                data: {
                    userId: overtime.userId,
                    title: `Lembur ${status === 'APPROVED' ? 'Disetujui' : 'Ditolak'}`,
                    message: `Permohonan lembur Anda telah ${status === 'APPROVED' ? 'disetujui' : 'ditolak'} oleh Supervisor Onsite. Catatan: ${notes}`,
                    type: status === 'APPROVED' ? 'OVERTIME_APPROVED' : 'OVERTIME_REJECTED'
                }
            });
            res.json({
                success: true,
                message: `Overtime request ${status.toLowerCase()} successfully`,
                data: updatedOvertime
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getOnsiteAttendanceReport(req, res) {
        try {
            const { startDate, endDate, locationId } = req.query;
            const whereClause = {
                date: {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                },
                user: {
                    division: 'ONSITE'
                }
            };
            if (locationId) {
                whereClause.locationCheckIn = {
                    contains: await this.getLocationName(parseInt(locationId))
                };
            }
            const attendances = await prisma.attendance.findMany({
                where: whereClause,
                include: {
                    user: {
                        select: {
                            name: true,
                            position: true
                        }
                    }
                },
                orderBy: {
                    date: 'desc'
                }
            });
            res.json({
                success: true,
                data: attendances
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    groupEmployeesByLocation(employees) {
        const grouped = {};
        employees.forEach(emp => {
            const location = emp.locationCheckIn?.split(' (')[0] || 'Unknown';
            if (!grouped[location]) {
                grouped[location] = [];
            }
            grouped[location].push(emp.user.name);
        });
        return grouped;
    }
    async getLocationName(locationId) {
        const location = await prisma.onsiteLocation.findUnique({
            where: { id: locationId }
        });
        return location?.name || '';
    }
}
exports.OnsiteController = OnsiteController;
exports.onsiteController = new OnsiteController();
//# sourceMappingURL=onsite-controller.js.map