import { PrismaClient, Division } from '@prisma/client';

export async function seedDivisionSettings(prisma: PrismaClient) {
  console.log('🏢 Seeding division settings...');

  const divisionSettings = [
    {
      division: Division.FINANCE,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 5000,
      baseSalary: 8000000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.APO,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      deductionPerMinute: 5000,
      baseSalary: 7500000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.FRONT_DESK,
      workStart: '07:00',
      workEnd: '16:00',
      lateThreshold: 10,
      deductionPerMinute: 3000,
      baseSalary: 6000000,
      overtimeRateMultiplier: 1.5,
      workingDaysPerMonth: 22
    },
    {
      division: Division.ONSITE,
      workStart: '08:30',
      workEnd: '17:30',
      lateThreshold: 30,
      deductionPerMinute: 4000,
      baseSalary: 7000000,
      overtimeRateMultiplier: 1.75,
      workingDaysPerMonth: 20
    },
  ];

  for (const setting of divisionSettings) {
    await prisma.divisionSetting.upsert({
      where: { division: setting.division },
      update: {
        workStart: setting.workStart,
        workEnd: setting.workEnd,
        lateThreshold: setting.lateThreshold,
        deductionPerMinute: setting.deductionPerMinute,
        baseSalary: setting.baseSalary,
        overtimeRateMultiplier: setting.overtimeRateMultiplier,
        workingDaysPerMonth: setting.workingDaysPerMonth,
      },
      create: {
        division: setting.division,
        workStart: setting.workStart,
        workEnd: setting.workEnd,
        lateThreshold: setting.lateThreshold,
        deductionPerMinute: setting.deductionPerMinute,
        baseSalary: setting.baseSalary,
        overtimeRateMultiplier: setting.overtimeRateMultiplier,
        workingDaysPerMonth: setting.workingDaysPerMonth,
      },
    });
    console.log(`✅ Division setting created for: ${setting.division}`);
  }

  console.log('✅ Division settings seeded');
}