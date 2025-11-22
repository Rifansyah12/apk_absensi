import { PrismaClient } from '@prisma/client';

export async function seedSalaries(prisma: PrismaClient) {
  console.log('💰 Seeding salaries...');

  const users = await prisma.user.findMany({
    where: { role: 'USER' }
  });

  const currentDate = new Date();
  const currentMonth = currentDate.getMonth() + 1;
  const currentYear = currentDate.getFullYear();

  // Base salary berdasarkan divisi
  const baseSalaries = {
    'FINANCE': 8000000,
    'APO': 7500000,
    'FRONT_DESK': 6000000,
    'ONSITE': 7000000
  };

  for (const user of users) {
    const baseSalary = baseSalaries[user.division] || 6000000;
    
    // Hitung lembur (random 0-20 jam)
    const overtimeHours = Math.floor(Math.random() * 20);
    const overtimeSalary = overtimeHours * 50000; // Rp 50,000 per jam
    
    // Hitung potongan (random 0-200,000)
    const deduction = Math.floor(Math.random() * 200000);
    
    const totalSalary = baseSalary + overtimeSalary - deduction;

    await prisma.salary.upsert({
      where: {
        userId_month_year: {
          userId: user.id,
          month: currentMonth,
          year: currentYear
        }
      },
      update: {},
      create: {
        userId: user.id,
        month: currentMonth,
        year: currentYear,
        baseSalary: baseSalary,
        overtimeSalary: overtimeSalary,
        deduction: deduction,
        totalSalary: totalSalary,
      },
    });
    console.log(`✅ Salary created for ${user.name}: Rp ${totalSalary.toLocaleString('id-ID')}`);
  }

  console.log('✅ Salaries seeded');
}