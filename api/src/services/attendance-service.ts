import { PrismaClient, Attendance, AttendanceStatus, Division } from '@prisma/client';
import { validateGPSLocation } from '../utils/gps';
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
      selfie: Buffer; // Buffer dari file
      note: string;
    }
  ): Promise<Attendance> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new Error('User not found');
      }
console.log('Checking in user:', userId, 'location', data.location);
      // GPS Validation
      const [lat, lng] = data.location.split(',').map(coord => parseFloat(coord.trim()));
      const gpsValidation = validateGPSLocation(
        lat,
        lng,
        parseFloat(process.env.OFFICE_LATITUDE!),
        parseFloat(process.env.OFFICE_LONGITUDE!),
        parseFloat(process.env.GPS_RADIUS || '100')
      );
console.log('GPS office:', process.env.OFFICE_LATITUDE, process.env.OFFICE_LONGITUDE);
      if (!gpsValidation.isValid) {
        await sendNotification(
          userId,
          'Absen Gagal - Lokasi Tidak Valid',
          `Absen masuk gagal: ${gpsValidation.message}`,
          'ATTENDANCE_FAILED'
        );
        throw new Error(gpsValidation.message);
      }

      // Simpan gambar sebagai file
      const selfiePath = saveImageToFile(data.selfie, userId, 'checkin');

      // Face Recognition (mock implementation)
      if (user.photo) {
        // Untuk face recognition, kita perlu convert buffer ke base64
        const selfieBase64 = data.selfie.toString('base64');
        const faceVerification = await verifyFace(selfieBase64, user.photo);
        if (!faceVerification.isMatch) {
          // Hapus file yang sudah disimpan karena face recognition gagal
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
        // Hapus file yang sudah disimpan karena sudah check in
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

      if (existingAttendance) {
        return await prisma.attendance.update({
          where: { id: existingAttendance.id },
          data: {
            checkIn: new Date(data.date),
            locationCheckIn: data.location,
            selfieCheckIn: selfiePath, // Simpan path file
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
          locationCheckIn: data.location,
          selfieCheckIn: selfiePath, // Simpan path file
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
      selfie: Buffer; // Buffer dari file
    }
  ): Promise<Attendance> {
    try {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new Error('User not found');
      }

      // GPS Validation
      const [lat, lng] = data.location.split(',').map(coord => parseFloat(coord.trim()));
      const gpsValidation = validateGPSLocation(
        lat,
        lng,
        parseFloat(process.env.OFFICE_LATITUDE!),
        parseFloat(process.env.OFFICE_LONGITUDE!),
        parseFloat(process.env.GPS_RADIUS || '100')
      );

      if (!gpsValidation.isValid) {
        await sendNotification(
          userId,
          'Absen Pulang Gagal - Lokasi Tidak Valid',
          `Absen pulang gagal: ${gpsValidation.message}`,
          'ATTENDANCE_FAILED'
        );
        throw new Error(gpsValidation.message);
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
        // Untuk face recognition, convert buffer ke base64
        const selfieBase64 = data.selfie.toString('base64');
        const faceVerification = await verifyFace(selfieBase64, user.photo);
        if (!faceVerification.isMatch) {
          // Hapus file yang sudah disimpan karena face recognition gagal
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

      return await prisma.attendance.update({
        where: { id: attendance.id },
        data: {
          checkOut: new Date(data.date),
          locationCheckOut: data.location,
          selfieCheckOut: selfiePath, // Simpan path file
          overtimeMinutes,
        },
      });
    } catch (error) {
      console.error('Error in checkOut service:', error);
      throw error;
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
          // salaries: true
        }
      }
    }
  });
}

  async deleteAttendance(attendanceId: number): Promise<void> {
    try {
      // Cek dulu apakah attendance exists
      const existingAttendance = await prisma.attendance.findUnique({
        where: { id: attendanceId }
      });

      if (!existingAttendance) {
        throw new Error(`Attendance record with ID ${attendanceId} not found`);
      }

      // Jika ada, baru hapus
      await prisma.attendance.delete({
        where: { id: attendanceId }
      });
    } catch (error: any) {
      console.error('Delete attendance service error:', error);
      
      // Handle Prisma specific errors
      if (error.code === 'P2025') {
        throw new Error(`Attendance record with ID ${attendanceId} not found`);
      }
      
      // Re-throw other errors
      throw error;
    }
  }
}