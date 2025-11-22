import { PrismaClient } from '@prisma/client';

export async function seedSystemSettings(prisma: PrismaClient) {
  console.log('⚙️ Seeding system settings...');

  const systemSettings = [
    {
      key: 'COMPANY_NAME',
      value: 'PT. Perusahaan Contoh'
    },
    {
      key: 'COMPANY_ADDRESS',
      value: 'Jl. Contoh No. 123, Jakarta Pusat'
    },
    {
      key: 'OFFICE_LATITUDE',
      value: '-6.2088'
    },
    {
      key: 'OFFICE_LONGITUDE',
      value: '106.8456'
    },
    {
      key: 'GPS_RADIUS',
      value: '100'
    },
    {
      key: 'FACE_RECOGNITION_THRESHOLD',
      value: '0.8'
    }
  ];

  for (const setting of systemSettings) {
    await prisma.systemSetting.upsert({
      where: { key: setting.key },
      update: {},
      create: setting,
    });
    console.log(`✅ System setting created: ${setting.key}`);
  }

  console.log('✅ System settings seeded');
}