import { PrismaClient, Division } from '@prisma/client';

export async function seedOnsiteLocations(prisma: PrismaClient) {
  console.log('📍 Seeding onsite locations...');

  const onsiteLocations = [
    {
      name: 'Kantor Pusat',
      address: 'Jl. Sudirman No. 123, Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      radius: 100,
      division: Division.ONSITE,
    },
    {
      name: 'Site Project A',
      address: 'Jl. Thamrin No. 45, Jakarta',
      latitude: -6.1865,
      longitude: 106.8235,
      radius: 150,
      division: Division.ONSITE,
    },
    {
      name: 'Site Project B',
      address: 'Jl. Gatot Subroto No. 67, Jakarta',
      latitude: -6.2214,
      longitude: 106.8123,
      radius: 200,
      division: Division.ONSITE,
    }
  ];

  for (const location of onsiteLocations) {
    // Cek apakah location sudah ada
    const existingLocation = await prisma.onsiteLocation.findFirst({
      where: { name: location.name }
    });

    if (existingLocation) {
      // Update existing location
      await prisma.onsiteLocation.update({
        where: { id: existingLocation.id },
        data: {
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          radius: location.radius,
          division: location.division,
        },
      });
      console.log(`✅ Onsite location updated: ${location.name}`);
    } else {
      // Create new location
      await prisma.onsiteLocation.create({
        data: {
          name: location.name,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          radius: location.radius,
          division: location.division,
        },
      });
      console.log(`✅ Onsite location created: ${location.name}`);
    }
  }

  console.log('✅ Onsite locations seeded');
}