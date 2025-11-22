import { PrismaClient, OvertimeStatus } from '@prisma/client';

export async function seedOvertimes(prisma: PrismaClient) {
  console.log('💼 Seeding overtimes...');

  const users = await prisma.user.findMany({
    where: { role: 'USER' }
  });

  const superAdmins = await prisma.user.findMany({
    where: { role: 'SUPER_ADMIN' }
  });

  const sampleOvertime = [
    {
      userId: users[0].id,
      date: new Date('2023-11-01'),
      hours: 2,
      reason: 'Menyelesaikan laporan bulanan',
      status: OvertimeStatus.APPROVED,
      approvedBy: superAdmins[0].id,
      notes: 'Disetujui, kerja bagus'
    },
    {
      userId: users[1].id,
      date: new Date('2023-11-02'),
      hours: 3,
      reason: 'Project deadline mendesak',
      status: OvertimeStatus.APPROVED,
      approvedBy: superAdmins[1].id,
      notes: 'Disetujui, harap perhatikan kesehatan'
    },
    {
      userId: users[2].id,
      date: new Date('2023-11-03'),
      hours: 1.5,
      reason: 'Meeting client sampai malam',
      status: OvertimeStatus.PENDING
    },
    {
      userId: users[3].id,
      date: new Date('2023-11-04'),
      hours: 4,
      reason: 'Server maintenance',
      status: OvertimeStatus.APPROVED,
      approvedBy: superAdmins[2].id,
      notes: 'Disetujui, penting untuk bisnis'
    },
    {
      userId: users[4].id,
      date: new Date('2023-11-05'),
      hours: 2.5,
      reason: 'Training new team member',
      status: OvertimeStatus.REJECTED,
      approvedBy: superAdmins[3].id,
      notes: 'Ditolak, training bisa dilakukan dalam jam kerja'
    },
    {
      userId: users[5].id,
      date: new Date('2023-11-06'),
      hours: 3,
      reason: 'Bug fixing production',
      status: OvertimeStatus.APPROVED,
      approvedBy: superAdmins[0].id
    },
    {
      userId: users[6].id,
      date: new Date('2023-11-07'),
      hours: 2,
      reason: 'Documentation update',
      status: OvertimeStatus.PENDING
    },
    {
      userId: users[7].id,
      date: new Date('2023-11-08'),
      hours: 1,
      reason: 'Client support emergency',
      status: OvertimeStatus.APPROVED,
      approvedBy: superAdmins[1].id
    }
  ];

  for (const overtime of sampleOvertime) {
    await prisma.overtime.create({
      data: overtime
    });
    console.log(`✅ Overtime created: ${overtime.hours} hours`);
  }

  console.log('✅ Overtimes seeded');
}