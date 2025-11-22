import { PrismaClient, Division, Role } from '@prisma/client';
import { hashPassword } from '../../src/utils/auth';

export async function seedUsers(prisma: PrismaClient) {
  console.log('👥 Seeding users...');

  // Create Super Admins for each division
  const superAdmins = [
    {
      employeeId: 'ADM001',
      name: 'Super Admin Finance',
      email: 'admin.finance@company.com',
      password: 'admin123',
      division: 'FINANCE' as Division,
      role: 'SUPER_ADMIN' as Role,
      position: 'Finance Manager',
      joinDate: new Date('2023-01-01'),
    },
    {
      employeeId: 'ADM002',
      name: 'Super Admin APO',
      email: 'admin.apo@company.com',
      password: 'admin123',
      division: 'APO' as Division,
      role: 'SUPER_ADMIN' as Role,
      position: 'APO Manager',
      joinDate: new Date('2023-01-01'),
    },
    {
      employeeId: 'ADM003',
      name: 'Super Admin Front Desk',
      email: 'admin.frontdesk@company.com',
      password: 'admin123',
      division: 'FRONT_DESK' as Division,
      role: 'SUPER_ADMIN' as Role,
      position: 'Front Desk Supervisor',
      joinDate: new Date('2023-01-01'),
    },
    {
      employeeId: 'ADM004',
      name: 'Super Admin Onsite',
      email: 'admin.onsite@company.com',
      password: 'admin123',
      division: 'ONSITE' as Division,
      role: 'SUPER_ADMIN' as Role,
      position: 'Onsite Coordinator',
      joinDate: new Date('2023-01-01'),
    }
  ];

  for (const admin of superAdmins) {
    const hashedPassword = await hashPassword(admin.password);
    await prisma.user.upsert({
      where: { email: admin.email },
      update: {},
      create: {
        employeeId: admin.employeeId,
        name: admin.name,
        email: admin.email,
        password: hashedPassword,
        division: admin.division,
        role: admin.role,
        position: admin.position,
        joinDate: admin.joinDate,
      },
    });
    console.log(`✅ Super Admin created: ${admin.name}`);
  }

  // Create regular employees for each division
  const employees = [
    // FINANCE Division Employees
    {
      employeeId: 'FIN001',
      name: 'Budi Santoso',
      email: 'budi.santoso@company.com',
      password: 'password123',
      division: 'FINANCE' as Division,
      role: 'USER' as Role,
      position: 'Finance Staff',
      phone: '081234567890',
      address: 'Jl. Sudirman No. 123, Jakarta',
      joinDate: new Date('2023-01-15'),
    },
    {
      employeeId: 'FIN002',
      name: 'Sari Dewi',
      email: 'sari.dewi@company.com',
      password: 'password123',
      division: 'FINANCE' as Division,
      role: 'USER' as Role,
      position: 'Accounting Staff',
      phone: '081234567891',
      address: 'Jl. Thamrin No. 45, Jakarta',
      joinDate: new Date('2023-02-01'),
    },
    {
      employeeId: 'FIN003',
      name: 'Ahmad Rizki',
      email: 'ahmad.rizki@company.com',
      password: 'password123',
      division: 'FINANCE' as Division,
      role: 'USER' as Role,
      position: 'Financial Analyst',
      phone: '081234567892',
      address: 'Jl. Gatot Subroto No. 67, Jakarta',
      joinDate: new Date('2023-02-15'),
    },

    // APO Division Employees
    {
      employeeId: 'APO001',
      name: 'Dian Permata',
      email: 'dian.permata@company.com',
      password: 'password123',
      division: 'APO' as Division,
      role: 'USER' as Role,
      position: 'APO Specialist',
      phone: '081234567893',
      address: 'Jl. Merdeka No. 89, Jakarta',
      joinDate: new Date('2023-01-20'),
    },
    {
      employeeId: 'APO002',
      name: 'Rizky Pratama',
      email: 'rizky.pratama@company.com',
      password: 'password123',
      division: 'APO' as Division,
      role: 'USER' as Role,
      position: 'APO Coordinator',
      phone: '081234567894',
      address: 'Jl. Asia Afrika No. 12, Jakarta',
      joinDate: new Date('2023-03-01'),
    },
    {
      employeeId: 'APO003',
      name: 'Maya Sari',
      email: 'maya.sari@company.com',
      password: 'password123',
      division: 'APO' as Division,
      role: 'USER' as Role,
      position: 'APO Assistant',
      phone: '081234567895',
      address: 'Jl. Jenderal Sudirman No. 34, Jakarta',
      joinDate: new Date('2023-03-15'),
    },

    // FRONT_DESK Division Employees
    {
      employeeId: 'FDS001',
      name: 'Citra Lestari',
      email: 'citra.lestari@company.com',
      password: 'password123',
      division: 'FRONT_DESK' as Division,
      role: 'USER' as Role,
      position: 'Receptionist',
      phone: '081234567896',
      address: 'Jl. Kebon Sirih No. 56, Jakarta',
      joinDate: new Date('2023-01-10'),
    },
    {
      employeeId: 'FDS002',
      name: 'Kevin Wijaya',
      email: 'kevin.wijaya@company.com',
      password: 'password123',
      division: 'FRONT_DESK' as Division,
      role: 'USER' as Role,
      position: 'Front Desk Officer',
      phone: '081234567897',
      address: 'Jl. Hayam Wuruk No. 78, Jakarta',
      joinDate: new Date('2023-02-10'),
    },
    {
      employeeId: 'FDS003',
      name: 'Nina Hartati',
      email: 'nina.hartati@company.com',
      password: 'password123',
      division: 'FRONT_DESK' as Division,
      role: 'USER' as Role,
      position: 'Customer Service',
      phone: '081234567898',
      address: 'Jl. Gajah Mada No. 90, Jakarta',
      joinDate: new Date('2023-04-01'),
    },

    // ONSITE Division Employees
    {
      employeeId: 'ONS001',
      name: 'Joko Susilo',
      email: 'joko.susilo@company.com',
      password: 'password123',
      division: 'ONSITE' as Division,
      role: 'USER' as Role,
      position: 'Field Technician',
      phone: '081234567899',
      address: 'Jl. Pangeran Antasari No. 11, Jakarta',
      joinDate: new Date('2023-01-05'),
    },
    {
      employeeId: 'ONS002',
      name: 'Rina Marlina',
      email: 'rina.marlina@company.com',
      password: 'password123',
      division: 'ONSITE' as Division,
      role: 'USER' as Role,
      position: 'Site Supervisor',
      phone: '081234567800',
      address: 'Jl. Rasuna Said No. 22, Jakarta',
      joinDate: new Date('2023-02-20'),
    },
    {
      employeeId: 'ONS003',
      name: 'Andi Prabowo',
      email: 'andi.prabowo@company.com',
      password: 'password123',
      division: 'ONSITE' as Division,
      role: 'USER' as Role,
      position: 'Onsite Engineer',
      phone: '081234567811',
      address: 'Jl. Kuningan No. 33, Jakarta',
      joinDate: new Date('2023-03-10'),
    },
    {
      employeeId: 'ONS004',
      name: 'Lisa Anggraeni',
      email: 'lisa.anggraeni@company.com',
      password: 'password123',
      division: 'ONSITE' as Division,
      role: 'USER' as Role,
      position: 'Field Operator',
      phone: '081234567822',
      address: 'Jl. Casablanca No. 44, Jakarta',
      joinDate: new Date('2023-04-15'),
    }
  ];

  for (const employee of employees) {
    const hashedPassword = await hashPassword(employee.password);
    await prisma.user.upsert({
      where: { email: employee.email },
      update: {},
      create: {
        employeeId: employee.employeeId,
        name: employee.name,
        email: employee.email,
        password: hashedPassword,
        division: employee.division,
        role: employee.role,
        position: employee.position,
        phone: employee.phone,
        address: employee.address,
        joinDate: employee.joinDate,
      },
    });
    console.log(`✅ Employee created: ${employee.name} (${employee.division})`);
  }

  console.log('✅ Users seeded');
}