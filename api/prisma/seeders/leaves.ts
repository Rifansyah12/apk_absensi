import { PrismaClient, LeaveType, LeaveStatus } from '@prisma/client';

export async function seedLeaves(prisma: PrismaClient) {
  console.log('🏖️ Seeding leaves...');

  const users = await prisma.user.findMany({
    where: { role: 'USER' }
  });

  const superAdmins = await prisma.user.findMany({
    where: { role: 'SUPER_ADMIN' }
  });

  const sampleLeaves = [
    {
      userId: users[0].id,
      startDate: new Date('2023-11-01'),
      endDate: new Date('2023-11-03'),
      type: LeaveType.CUTI_TAHUNAN,
      reason: 'Liburan keluarga ke Bali',
      status: LeaveStatus.APPROVED,
      approvedBy: superAdmins[0].id,
      notes: 'Disetujui, harap selesaikan pekerjaan sebelum cuti'
    },
    {
      userId: users[1].id,
      startDate: new Date('2023-11-05'),
      endDate: new Date('2023-11-05'),
      type: LeaveType.CUTI_SAKIT,
      reason: 'Flu berat dan demam tinggi',
      status: LeaveStatus.APPROVED,
      approvedBy: superAdmins[1].id,
      notes: 'Disetujui, semoga cepat sembuh'
    },
    {
      userId: users[2].id,
      startDate: new Date('2023-11-10'),
      endDate: new Date('2023-11-12'),
      type: LeaveType.CUTI_ALASAN_PENTING,
      reason: 'Urusan keluarga penting',
      status: LeaveStatus.PENDING
    },
    {
      userId: users[3].id,
      startDate: new Date('2023-11-15'),
      endDate: new Date('2023-11-20'),
      type: LeaveType.CUTI_TAHUNAN,
      reason: 'Melakukan ibadah haji',
      status: LeaveStatus.APPROVED,
      approvedBy: superAdmins[2].id,
      notes: 'Disetujui, selamat menunaikan ibadah'
    },
    {
      userId: users[4].id,
      startDate: new Date('2023-11-25'),
      endDate: new Date('2023-11-25'),
      type: LeaveType.CUTI_SAKIT,
      reason: 'Kontrol rutin ke dokter',
      status: LeaveStatus.REJECTED,
      approvedBy: superAdmins[3].id,
      notes: 'Ditolak, harap jadwalkan di hari lain'
    },
    {
      userId: users[5].id,
      startDate: new Date('2023-12-01'),
      endDate: new Date('2023-12-05'),
      type: LeaveType.CUTI_ALASAN_PENTING,
      reason: 'Perbaikan rumah',
      status: LeaveStatus.PENDING
    }
  ];

  for (const leave of sampleLeaves) {
    await prisma.leave.create({
      data: leave
    });
    console.log(`✅ Leave created for ${leave.type}`);
  }

  console.log('✅ Leaves seeded');
}