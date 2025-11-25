// controllers/onsite-controller.ts
import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';
import { sendErrorResponse } from '../utils/error-handler';
import { calculateDistance } from '../utils/gps';

const prisma = new PrismaClient();

export class OnsiteController {
  // ✅ ENDPOINT BARU: Get all onsite locations
  async getOnsiteLocations(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { division, isActive } = req.query;
      
      const whereClause: any = {};
      
      if (division) {
        whereClause.division = division;
      }
      
      if (isActive !== undefined) {
        whereClause.isActive = isActive === 'true';
      }

      const locations = await prisma.onsiteLocation.findMany({
        where: whereClause,
        orderBy: {
          name: 'asc'
        }
      });

      res.json({
        success: true,
        data: locations,
        count: locations.length
      });
    } catch (error: any) {
      console.error('Get onsite locations error:', error);
      sendErrorResponse(res, error);
    }
  }

  // ✅ ENDPOINT BARU: Get onsite location by ID
  async getOnsiteLocationById(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const location = await prisma.onsiteLocation.findUnique({
        where: { id: parseInt(id) }
      });

      if (!location) {
        res.status(404).json({
          success: false,
          message: 'Lokasi onsite tidak ditemukan'
        });
        return;
      }

      res.json({
        success: true,
        data: location
      });
    } catch (error: any) {
      console.error('Get onsite location by ID error:', error);
      sendErrorResponse(res, error);
    }
  }

  // ✅ ENDPOINT BARU: Create new onsite location
  async createOnsiteLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { 
        name, 
        address, 
        latitude, 
        longitude, 
        radius = 100, 
        division, 
        isActive = true 
      } = req.body;

      // Validasi input
      if (!name || !address || !latitude || !longitude || !division) {
        res.status(400).json({
          success: false,
          message: 'Nama, alamat, latitude, longitude, dan division diperlukan'
        });
        return;
      }

      // Validasi koordinat
      if (typeof latitude !== 'number' || typeof longitude !== 'number') {
        res.status(400).json({
          success: false,
          message: 'Latitude dan longitude harus berupa angka'
        });
        return;
      }

      // Validasi radius
      if (radius < 50 || radius > 5000) {
        res.status(400).json({
          success: false,
          message: 'Radius harus antara 50 - 5000 meter'
        });
        return;
      }

      // Cek apakah nama sudah ada
      const existingLocation = await prisma.onsiteLocation.findUnique({
        where: { name }
      });

      if (existingLocation) {
        res.status(400).json({
          success: false,
          message: 'Nama lokasi sudah digunakan'
        });
        return;
      }

      const newLocation = await prisma.onsiteLocation.create({
        data: {
          name,
          address,
          latitude: parseFloat(latitude.toString()),
          longitude: parseFloat(longitude.toString()),
          radius: parseInt(radius),
          division,
          isActive
        }
      });

      res.status(201).json({
        success: true,
        message: 'Lokasi onsite berhasil dibuat',
        data: newLocation
      });
    } catch (error: any) {
      console.error('Create onsite location error:', error);
      sendErrorResponse(res, error);
    }
  }

  // ✅ ENDPOINT BARU: Update onsite location
  async updateOnsiteLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const { 
        name, 
        address, 
        latitude, 
        longitude, 
        radius, 
        division, 
        isActive 
      } = req.body;

      // Cek apakah lokasi ada
      const existingLocation = await prisma.onsiteLocation.findUnique({
        where: { id: parseInt(id) }
      });

      if (!existingLocation) {
        res.status(404).json({
          success: false,
          message: 'Lokasi onsite tidak ditemukan'
        });
        return;
      }

      // Jika nama diubah, cek apakah nama baru sudah digunakan
      if (name && name !== existingLocation.name) {
        const nameExists = await prisma.onsiteLocation.findUnique({
          where: { name }
        });

        if (nameExists) {
          res.status(400).json({
            success: false,
            message: 'Nama lokasi sudah digunakan'
          });
          return;
        }
      }

      // Validasi koordinat jika diupdate
      if (latitude && typeof latitude !== 'number') {
        res.status(400).json({
          success: false,
          message: 'Latitude harus berupa angka'
        });
        return;
      }

      if (longitude && typeof longitude !== 'number') {
        res.status(400).json({
          success: false,
          message: 'Longitude harus berupa angka'
        });
        return;
      }

      // Validasi radius jika diupdate
      if (radius && (radius < 50 || radius > 5000)) {
        res.status(400).json({
          success: false,
          message: 'Radius harus antara 50 - 5000 meter'
        });
        return;
      }

      const updatedLocation = await prisma.onsiteLocation.update({
        where: { id: parseInt(id) },
        data: {
          ...(name && { name }),
          ...(address && { address }),
          ...(latitude && { latitude: parseFloat(latitude) }),
          ...(longitude && { longitude: parseFloat(longitude) }),
          ...(radius && { radius: parseInt(radius) }),
          ...(division && { division }),
          ...(isActive !== undefined && { isActive })
        }
      });

      res.json({
        success: true,
        message: 'Lokasi onsite berhasil diupdate',
        data: updatedLocation
      });
    } catch (error: any) {
      console.error('Update onsite location error:', error);
      sendErrorResponse(res, error);
    }
  }

  // ✅ ENDPOINT BARU: Delete onsite location (soft delete)
  async deleteOnsiteLocation(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      // Cek apakah lokasi ada
      const existingLocation = await prisma.onsiteLocation.findUnique({
        where: { id: parseInt(id) }
      });

      if (!existingLocation) {
        res.status(404).json({
          success: false,
          message: 'Lokasi onsite tidak ditemukan'
        });
        return;
      }

      // Soft delete dengan mengubah isActive menjadi false
      await prisma.onsiteLocation.update({
        where: { id: parseInt(id) },
        data: { isActive: false }
      });

      res.json({
        success: true,
        message: 'Lokasi onsite berhasil dinonaktifkan'
      });
    } catch (error: any) {
      console.error('Delete onsite location error:', error);
      sendErrorResponse(res, error);
    }
  }

  // ✅ ENDPOINT BARU: Toggle location status
  async toggleLocationStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const existingLocation = await prisma.onsiteLocation.findUnique({
        where: { id: parseInt(id) }
      });

      if (!existingLocation) {
        res.status(404).json({
          success: false,
          message: 'Lokasi onsite tidak ditemukan'
        });
        return;
      }

      const updatedLocation = await prisma.onsiteLocation.update({
        where: { id: parseInt(id) },
        data: { 
          isActive: !existingLocation.isActive 
        }
      });

      res.json({
        success: true,
        message: `Lokasi berhasil ${updatedLocation.isActive ? 'diaktifkan' : 'dinonaktifkan'}`,
        data: updatedLocation
      });
    } catch (error: any) {
      console.error('Toggle location status error:', error);
      sendErrorResponse(res, error);
    }
  }
  
  async validateGPSCheckIn(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { userId, latitude, longitude } = req.body;

      // Validasi input
      if (!userId || !latitude || !longitude) {
        res.status(400).json({
          success: false,
          message: 'userId, latitude, dan longitude diperlukan'
        });
        return;
      }

      // Cari lokasi onsite terdekat
      const onsiteLocations = await prisma.onsiteLocation.findMany({
        where: {
          isActive: true
        }
      });

      let isValidLocation = false;
      let validatedLocation = null;

      for (const location of onsiteLocations) {
        const distance = calculateDistance(
          parseFloat(latitude), 
          parseFloat(longitude),
          location.latitude, 
          location.longitude
        );

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

      // Jika valid, lanjutkan proses check-in
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // CEK APAKAH SUDAH ADA ATTENDANCE UNTUK USER INI HARI INI
      const existingAttendance = await prisma.attendance.findFirst({
        where: {
          userId: parseInt(userId),
          date: {
            gte: today,
            lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) // Besok
          }
        }
      });

      let attendance;

      if (existingAttendance) {
        // UPDATE EXISTING RECORD
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
      } else {
        // CREATE NEW RECORD
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
    } catch (error: any) {
      console.error('Validate GPS CheckIn error:', error);
      sendErrorResponse(res, error);
    }
  }

  // Dashboard monitoring lapangan
  async getFieldMonitoring(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Data karyawan onsite yang sedang bekerja
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

      // Data lokasi aktif
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
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Approve/reject lembur onsite
  async processOvertimeOnsite(req: AuthRequest, res: Response): Promise<void> {
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

      // Validasi: hanya untuk karyawan onsite
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
          status: status as any,
          notes: notes || `Processed by Onsite Supervisor: ${status}`
        }
      });

      // Buat notifikasi
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
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  // Laporan kehadiran onsite
  async getOnsiteAttendanceReport(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { startDate, endDate, locationId } = req.query;

      const whereClause: any = {
        date: {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        },
        user: {
          division: 'ONSITE'
        }
      };

      if (locationId) {
        // Filter berdasarkan lokasi (dengan parsing string location)
        whereClause.locationCheckIn = {
          contains: await this.getLocationName(parseInt(locationId as string))
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
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  private groupEmployeesByLocation(employees: any[]): any {
    const grouped: any = {};
    employees.forEach(emp => {
      const location = emp.locationCheckIn?.split(' (')[0] || 'Unknown';
      if (!grouped[location]) {
        grouped[location] = [];
      }
      grouped[location].push(emp.user.name);
    });
    return grouped;
  }

  private async getLocationName(locationId: number): Promise<string> {
    const location = await prisma.onsiteLocation.findUnique({
      where: { id: locationId }
    });
    return location?.name || '';
  }
}

export const onsiteController = new OnsiteController();