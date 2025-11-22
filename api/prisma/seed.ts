import { PrismaClient } from '@prisma/client';
import {
  seedDivisionSettings,
  seedSystemSettings,
  seedUsers,
  seedAttendances,
  seedLeaves,
  seedOvertimes,
  seedSalaries,
  seedNotifications
} from './seeders';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  try {
    // Seed dalam urutan yang benar untuk menghindari constraint violation
    await seedDivisionSettings(prisma);
    await seedSystemSettings(prisma);
    await seedUsers(prisma);
    await seedAttendances(prisma);
    await seedLeaves(prisma);
    await seedOvertimes(prisma);
    await seedSalaries(prisma);
    await seedNotifications(prisma);

    console.log('🎉 Database seeding completed successfully!');
    console.log('');
    console.log('📋 Login Credentials:');
    console.log('=====================');
    console.log('Super Admin Finance: admin.finance@company.com / admin123');
    console.log('Super Admin APO: admin.apo@company.com / admin123');
    console.log('Super Admin Front Desk: admin.frontdesk@company.com / admin123');
    console.log('Super Admin Onsite: admin.onsite@company.com / admin123');
    console.log('');
    console.log('Regular Employees: password123 untuk semua akun');
    console.log('');
    console.log('📊 Sample Data Created:');
    console.log('- Division Settings: 4 records');
    console.log('- System Settings: 6 records');
    console.log('- Users: 18 records (4 Super Admin + 14 Employees)');
    console.log('- Attendances: ~100 records (30 hari terakhir)');
    console.log('- Leaves: 6 records');
    console.log('- Overtimes: 8 records');
    console.log('- Salaries: 14 records');
    console.log('- Notifications: 12 records');
    
  } catch (error) {
    console.error('❌ Seeding error:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });