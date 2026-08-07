import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const locations = ['Lagos', 'Abuja', 'Ibadan', 'Port Harcourt', 'London'];
  
  console.log('Seeding locations...');
  for (const name of locations) {
    try {
      await prisma.location.upsert({
        where: { name },
        update: {},
        create: { name },
      });
      console.log(`- Created location: ${name}`);
    } catch (e) {
      console.error(`- Failed to create location: ${name}`, e);
    }
  }
  console.log('Finished seeding locations.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
