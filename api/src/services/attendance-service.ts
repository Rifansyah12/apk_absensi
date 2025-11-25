import { PrismaClient, Attendance, AttendanceStatus, Division } from '@prisma/client';
import { calculateDistance } from '../utils/gps'; // Ganti validateGPSLocation dengan calculateDistance
import { verifyFace } from '../utils/face-recognition';
import { sendNotification } from '../utils/notification';
import { saveImageToFile, deleteImageFile } from '../utils/file-storage';

const prisma = new PrismaClient();

export class AttendanceService {
  async checkIn(
    userId: number,
    data: {
      date: Date;
      location: string;
      selfie: Buffer;
      note: string;
    }
  ): Promise<Attendance> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new Error('User not found');
      }

      console.log('Checking in user:', userId, 'location', data.location);

      // ✅ PERBAIKAN: Validasi GPS menggunakan lokasi dari database
      const [lat, lng] = data.location.split(',').map(coord => parseFloat(coord.trim()));

      // Cari semua lokasi aktif untuk divisi user
      const onsiteLocations = await prisma.onsiteLocation.findMany({
        where: {
          isActive: true,
          division: user.division // Filter berdasarkan divisi user
        }
      });

      console.log('Available locations for division:', user.division, onsiteLocations);

      let isValidLocation = false;
      let validatedLocation = null;

      // Validasi terhadap semua lokasi yang tersedia
      for (const location of onsiteLocations) {
        const distance = calculateDistance(
          lat,
          lng,
          location.latitude,
          location.longitude
        );

        console.log(`Distance to ${location.name}: ${distance}m (radius: ${location.radius}m)`);

        if (distance <= location.radius) {
          isValidLocation = true;
          validatedLocation = location;
          break;
        }
      }

      if (!isValidLocation) {
        await sendNotification(
          userId,
          'Absen Gagal - Lokasi Tidak Valid',
          `Absen masuk gagal: Anda tidak berada dalam radius lokasi yang valid untuk divisi ${user.division}`,
          'ATTENDANCE_FAILED'
        );
        throw new Error(`Anda tidak berada dalam radius lokasi yang valid untuk divisi ${user.division}`);
      }

      // Simpan gambar sebagai file
      const selfiePath = saveImageToFile(data.selfie, userId, 'checkin');

      // Face Recognition (mock implementation)
      if (user.photo) {
        const selfieBase64 = data.selfie.toString('base64');
        const faceVerification = await verifyFace(selfieBase64, user.photo);
        if (!faceVerification.isMatch) {
          deleteImageFile(selfiePath);

          await sendNotification(
            userId,
            'Absen Gagal - Wajah Tidak Cocok',
            `Absen masuk gagal: ${faceVerification.message}. Confidence: ${(faceVerification.confidence * 100).toFixed(2)}%`,
            'ATTENDANCE_FAILED'
          );
          throw new Error(faceVerification.message);
        }
      }

      // Check if already checked in today
      const today = new Date(data.date);
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const existingAttendance = await prisma.attendance.findFirst({
        where: {
          userId,
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      });

      if (existingAttendance && existingAttendance.checkIn) {
        deleteImageFile(selfiePath);
        throw new Error('Already checked in today');
      }

      // Calculate late minutes
      const divisionSetting = await prisma.divisionSetting.findUnique({
        where: { division: user.division },
      });

      const workStart = divisionSetting?.workStart || '08:00';
      const [workHours, workMinutes] = workStart.split(':').map(Number);
      const workStartTime = new Date(data.date);
      workStartTime.setHours(workHours, workMinutes, 0, 0);

      const checkInTime = new Date(data.date);
      const lateMinutes = checkInTime > workStartTime
        ? Math.floor((checkInTime.getTime() - workStartTime.getTime()) / (1000 * 60))
        : 0;

      const status: AttendanceStatus = lateMinutes > 0 ? 'LATE' : 'PRESENT';

      // ✅ PERBAIKAN: Simpan nama lokasi yang divalidasi
      const locationInfo = validatedLocation
        ? `${validatedLocation.name} (${lat}, ${lng})`
        : data.location;

      if (existingAttendance) {
        return await prisma.attendance.update({
          where: { id: existingAttendance.id },
          data: {
            checkIn: new Date(data.date),
            locationCheckIn: locationInfo,
            selfieCheckIn: selfiePath,
            lateMinutes,
            status,
            notes: data.note,
          },
        });
      }

      return await prisma.attendance.create({
        data: {
          userId,
          date: today,
          checkIn: new Date(data.date),
          locationCheckIn: locationInfo,
          selfieCheckIn: selfiePath,
          lateMinutes,
          status,
          notes: data.note,
        },
      });
    } catch (error) {
      console.error('Error in checkIn service:', error);
      throw error;
    }
  }

  async checkOut(
    userId: number,
    data: {
      date: Date;
      location: string;
      selfie: Buffer;
    }
  ): Promise<Attendance> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new Error('User not found');
      }

      // ✅ PERBAIKAN: Validasi GPS menggunakan lokasi dari database
      const [lat, lng] = data.location.split(',').map(coord => parseFloat(coord.trim()));

      // Cari semua lokasi aktif untuk divisi user
      const onsiteLocations = await prisma.onsiteLocation.findMany({
        where: {
          isActive: true,
          division: user.division
        }
      });

      let isValidLocation = false;
      let validatedLocation = null;

      for (const location of onsiteLocations) {
        const distance = calculateDistance(
          lat,
          lng,
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
        await sendNotification(
          userId,
          'Absen Pulang Gagal - Lokasi Tidak Valid',
          `Absen pulang gagal: Anda tidak berada dalam radius lokasi yang valid untuk divisi ${user.division}`,
          'ATTENDANCE_FAILED'
        );
        throw new Error(`Anda tidak berada dalam radius lokasi yang valid untuk divisi ${user.division}`);
      }

      // Get today's attendance
      const today = new Date(data.date);
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const attendance = await prisma.attendance.findFirst({
        where: {
          userId,
          date: {
            gte: today,
            lt: tomorrow,
          },
        },
      });

      if (!attendance || !attendance.checkIn) {
        throw new Error('Please check in first');
      }

      if (attendance.checkOut) {
        throw new Error('Already checked out today');
      }

      // Simpan gambar sebagai file
      const selfiePath = saveImageToFile(data.selfie, userId, 'checkout');

      // Face Recognition
      if (user.photo) {
        const selfieBase64 = data.selfie.toString('base64');
        const faceVerification = await verifyFace(selfieBase64, user.photo);
        if (!faceVerification.isMatch) {
          deleteImageFile(selfiePath);

          await sendNotification(
            userId,
            'Absen Pulang Gagal - Wajah Tidak Cocok',
            `Absen pulang gagal: ${faceVerification.message}`,
            'ATTENDANCE_FAILED'
          );
          throw new Error(faceVerification.message);
        }
      }

      // Calculate overtime
      const divisionSetting = await prisma.divisionSetting.findUnique({
        where: { division: user.division },
      });

      const workEnd = divisionSetting?.workEnd || '17:00';
      const [workHours, workMinutes] = workEnd.split(':').map(Number);
      const workEndTime = new Date(data.date);
      workEndTime.setHours(workHours, workMinutes, 0, 0);

      const checkOutTime = new Date(data.date);
      const overtimeMinutes = checkOutTime > workEndTime
        ? Math.floor((checkOutTime.getTime() - workEndTime.getTime()) / (1000 * 60))
        : 0;

      // ✅ PERBAIKAN: Simpan nama lokasi yang divalidasi
      const locationInfo = validatedLocation
        ? `${validatedLocation.name} (${lat}, ${lng})`
        : data.location;

      return await prisma.attendance.update({
        where: { id: attendance.id },
        data: {
          checkOut: new Date(data.date),
          locationCheckOut: locationInfo,
          selfieCheckOut: selfiePath,
          overtimeMinutes,
        },
      });
    } catch (error) {
      console.error('Error in checkOut service:', error);
      throw error;
    }
  }

  // ✅ PERBAIKAN: Method untuk validasi GPS saja (tanpa create/update attendance)
  async validateGPSLocation(
    userId: number,
    latitude: number,
    longitude: number
  ): Promise<{ isValid: boolean; location?: any; message: string }> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        return { isValid: false, message: 'User not found' };
      }

      // Cari semua lokasi aktif untuk divisi user
      const onsiteLocations = await prisma.onsiteLocation.findMany({
        where: {
          isActive: true,
          division: user.division
        }
      });

      if (onsiteLocations.length === 0) {
        return {
          isValid: false,
          message: `Tidak ada lokasi yang dikonfigurasi untuk divisi ${user.division}`
        };
      }

      let isValidLocation = false;
      let validatedLocation = null;

      for (const location of onsiteLocations) {
        const distance = calculateDistance(
          latitude,
          longitude,
          location.latitude,
          location.longitude
        );

        console.log(`Distance to ${location.name}: ${distance}m (radius: ${location.radius}m)`);

        if (distance <= location.radius) {
          isValidLocation = true;
          validatedLocation = location;
          break;
        }
      }

      if (!isValidLocation) {
        return {
          isValid: false,
          message: `Anda tidak berada dalam radius lokasi yang valid untuk divisi ${user.division}.`
        };
      }

      return {
        isValid: true,
        location: validatedLocation,
        message: `Lokasi valid: ${validatedLocation!.name}`
      };

    } catch (error) {
      console.error('Error in validateGPSLocation service:', error);
      return { isValid: false, message: 'Error validating location' };
    }
  }

  async getAttendanceHistory(
    userId: number,
    startDate: Date,
    endDate: Date
  ): Promise<Attendance[]> {
    return await prisma.attendance.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: {
        date: 'desc',
      },
    });
  }

  async getAttendanceSummary(userId: number, month: number, year: number): Promise<{
    totalPresent: number;
    totalLate: number;
    totalAbsent: number;
    totalLeave: number;
    totalOvertime: number;
  }> {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    const attendances = await prisma.attendance.findMany({
      where: {
        userId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    const totalPresent = attendances.filter(a => a.status === 'PRESENT').length;
    const totalLate = attendances.filter(a => a.status === 'LATE').length;
    const totalAbsent = attendances.filter(a => a.status === 'ABSENT').length;
    const totalLeave = attendances.filter(a => a.status === 'LEAVE' || a.status === 'SICK').length;
    const totalOvertime = attendances.reduce((sum, a) => sum + a.overtimeMinutes, 0) / 60;

    return {
      totalPresent,
      totalLate,
      totalAbsent,
      totalLeave,
      totalOvertime: Math.round(totalOvertime * 100) / 100,
    };
  }

  async getAttendanceHistoryByDivision(
    division: string,
    startDate: Date,
    endDate: Date
  ): Promise<Attendance[]> {
    return prisma.attendance.findMany({
      where: {
        user: {
          division: division as Division
        },
        date: {
          gte: startDate,
          lte: endDate
        }
      },
      orderBy: {
        date: 'desc'
      },
      include: {
        user: {
          select: {
            id: true,
            employeeId: true,
            name: true,
            email: true,
            division: true,
            role: true,
            position: true,
            photo: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
          }
        }
      }
    });
  }

  async deleteAttendance(attendanceId: number): Promise<void> {
    try {
      const existingAttendance = await prisma.attendance.findUnique({
        where: { id: attendanceId }
      });

      if (!existingAttendance) {
        throw new Error(`Attendance record with ID ${attendanceId} not found`);
      }

      await prisma.attendance.delete({
        where: { id: attendanceId }
      });
    } catch (error: any) {
      console.error('Delete attendance service error:', error);

      if (error.code === 'P2025') {
        throw new Error(`Attendance record with ID ${attendanceId} not found`);
      }

      throw error;
    }
  }
}