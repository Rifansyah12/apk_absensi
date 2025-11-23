import { PrismaClient, AttendanceStatus } from '@prisma/client';

export async function seedAttendances(prisma: PrismaClient) {
  console.log('📊 Seeding attendances...');

  const users = await prisma.user.findMany({
    where: { role: 'USER' }
  });

  let attendanceCount = 0;

  // Create attendance records for the last 30 days
  for (let i = 0; i < 30; i++) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    date.setHours(0, 0, 0, 0);
    
    for (const user of users) {
      // Skip weekends (Sabtu=6, Minggu=0) dengan probability 80%
      const isWeekend = date.getDay() === 0 || date.getDay() === 6;
      if (isWeekend && Math.random() > 0.2) continue;

      // Skip some weekdays randomly to simulate absences (10% probability)
      if (!isWeekend && Math.random() > 0.9) continue;

      const checkIn = new Date(date);
      checkIn.setHours(8, Math.floor(Math.random() * 45), 0, 0); // Between 8:00-8:45
      
      const checkOut = new Date(date);
      checkOut.setHours(16 + Math.floor(Math.random() * 3), Math.floor(Math.random() * 60), 0, 0); // Between 16:00-19:00

      const lateMinutes = checkIn.getHours() === 8 && checkIn.getMinutes() > 0 ? 
        checkIn.getMinutes() : 0;

      const overtimeMinutes = checkOut.getHours() >= 17 ? 
        (checkOut.getHours() - 17) * 60 + checkOut.getMinutes() : 0;

      const status: AttendanceStatus = lateMinutes > 15 ? 'LATE' : 'PRESENT';

      // Check if attendance already exists for this user and date
      const existingAttendance = await prisma.attendance.findFirst({
        where: {
          userId: user.id,
          date: date
        }
      });

      if (!existingAttendance) {
        await prisma.attendance.create({
          data: {
            userId: user.id,
            date: date,
            checkIn: checkIn,
            checkOut: checkOut,
            lateMinutes: lateMinutes,
            overtimeMinutes: overtimeMinutes,
            locationCheckIn: '-6.2088,106.8456',
            locationCheckOut: '-6.2088,106.8456',
            selfieCheckIn: `/public/uploads/selfies/selfie_${user.id}_checkin_${date.getTime()}.jpg`,
            selfieCheckOut: `/public/uploads/selfies/selfie_${user.id}_checkout_${date.getTime()}.jpg`,
            status: status,
          },
        });
        attendanceCount++;
      }
    }
  }

  console.log(`✅ Attendances seeded: ${attendanceCount} records`);
}