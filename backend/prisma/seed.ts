import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';

const connectionString = process.env.DATABASE_URL;
const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Starting seed...');

  // 1. Create a dummy organizer
  const password = await bcrypt.hash('password123', 10);
  const organizer = await prisma.user.upsert({
    where: { email: 'organizer@bikin.app' },
    update: {},
    create: {
      email: 'organizer@bikin.app',
      password,
      name: 'Bikin Official Events',
      role: 'ORGANIZER',
    },
  });

  console.log('Organizer created:', organizer.id);

  // 2. Create some sample events with flutter mock videos
  const eventsData = [
    {
      title: 'Butterfly Exhibition',
      description: 'Beautiful butterflies! 🦋 Come see them live this weekend.',
      date: new Date(Date.now() + 86400000 * 5),
      location: 'Lagos Nature Park',
      mediaUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      price: 5000,
      organizerId: organizer.id,
    },
    {
      title: 'Bee Keeping Workshop',
      description: 'Bees are amazing creatures 🐝',
      date: new Date(Date.now() + 86400000 * 10),
      location: 'Eco Tours Center',
      mediaUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      price: 15000,
      organizerId: organizer.id,
    },
  ];

  for (const event of eventsData) {
    const created = await prisma.event.create({
      data: event,
    });
    console.log(`Created event: ${created.title}`);
  }

  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
