import { PrismaClient, Division } from '@prisma/client';

export async function seedWorkShifts(prisma: PrismaClient) {
  console.log('⏰ Seeding work shifts...');

  // Hapus semua data existing (opsional)
  await prisma.workShift.deleteMany();

  const workShifts = [
    {
      name: 'Shift Pagi',
      startTime: '07:00',
      endTime: '16:00',
      division: Division.FRONT_DESK,
    },
    {
      name: 'Shift Siang',
      startTime: '08:00',
      endTime: '17:00',
      division: Division.FINANCE,
    },
    {
      name: 'Shift Fleksibel',
      startTime: '08:30',
      endTime: '17:30',
      division: Division.ONSITE,
    },
    {
      name: 'Shift Standar',
      startTime: '08:00',
      endTime: '17:00',
      division: Division.APO,
    },
  ];

  await prisma.workShift.createMany({
    data: workShifts,
  });

  console.log(`✅ Work shifts created: ${workShifts.length} records`);
  console.log('✅ Work shifts seeded');
}