import { PrismaClient, NotificationType } from '@prisma/client';

export async function seedNotifications(prisma: PrismaClient) {
  console.log('🔔 Seeding notifications...');

  const users = await prisma.user.findMany();

  const sampleNotifications = [
    {
      userId: users[0].id,
      title: 'Absensi Berhasil',
      message: 'Anda telah berhasil melakukan check-in pada 08:15',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      isRead: true
    },
    {
      userId: users[1].id,
      title: 'Cuti Disetujui',
      message: 'Permohonan cuti tanggal 2023-11-01 hingga 2023-11-03 telah disetujui',
      type: NotificationType.LEAVE_APPROVED,
      isRead: true
    },
    {
      userId: users[2].id,
      title: 'Lembur Ditolak',
      message: 'Permohonan lembur tanggal 2023-11-05 telah ditolak',
      type: NotificationType.OVERTIME_REJECTED,
      isRead: false
    },
    {
      userId: users[3].id,
      title: 'Gaji Telah Dibayar',
      message: 'Gaji bulan November 2023 telah ditransfer ke rekening Anda',
      type: NotificationType.SALARY_RELEASED,
      isRead: false
    },
    {
      userId: users[4].id,
      title: 'Absensi Gagal',
      message: 'Check-in gagal: Lokasi tidak valid',
      type: NotificationType.ATTENDANCE_FAILED,
      isRead: true
    },
    {
      userId: users[5].id,
      title: 'Pengumuman Sistem',
      message: 'Akan ada maintenance sistem pada Minggu, 12 November 2023 pukul 00:00-04:00',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      isRead: false
    },
    {
      userId: users[0].id,
      title: 'Lembur Disetujui',
      message: 'Permohonan lembur 2 jam pada 2023-11-10 telah disetujui',
      type: NotificationType.OVERTIME_APPROVED,
      isRead: false
    },
    {
      userId: users[1].id,
      title: 'Cuti Ditolak',
      message: 'Permohonan cuti tanggal 2023-11-15 telah ditolak dengan alasan: Kuota cuti habis',
      type: NotificationType.LEAVE_REJECTED,
      isRead: true
    },
    {
      userId: users[2].id,
      title: 'Pengumuman Libur',
      message: 'Perusahaan akan libur pada tanggal 25 Desember 2023 menyambut Natal',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      isRead: false
    },
    {
      userId: users[3].id,
      title: 'Absensi Berhasil',
      message: 'Anda telah berhasil melakukan check-out pada 17:30',
      type: NotificationType.SYSTEM_ANNOUNCEMENT,
      isRead: true
    },
    {
      userId: users[4].id,
      title: 'Peringatan Keterlambatan',
      message: 'Anda telah terlambat 3 kali dalam seminggu terakhir',
      type: NotificationType.ATTENDANCE_FAILED,
      isRead: false
    },
    {
      userId: users[5].id,
      title: 'Gaji Telah Dibayar',
      message: 'Gaji bulan Oktober 2023 telah ditransfer ke rekening Anda',
      type: NotificationType.SALARY_RELEASED,
      isRead: true
    }
  ];

  for (const notification of sampleNotifications) {
    await prisma.notification.create({
      data: notification
    });
    console.log(`✅ Notification created: ${notification.title}`);
  }

  console.log('✅ Notifications seeded');
}