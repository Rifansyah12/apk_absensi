import { PrismaClient, Division } from '@prisma/client';

export async function seedDivisionSettings(prisma: PrismaClient) {
  console.log('🏢 Seeding division settings...');

  const divisions: Division[] = ['FINANCE', 'APO', 'FRONT_DESK', 'ONSITE'];
  
  for (const division of divisions) {
    await prisma.divisionSetting.upsert({
      where: { division },
      update: {},
      create: {
        division,
        workStart: '08:00',
        workEnd: '17:00',
        lateThreshold: 15,
        deductionPerMinute: 1000,
      },
    });
    console.log(`✅ Division setting created for: ${division}`);
  }

  console.log('✅ Division settings seeded');
}