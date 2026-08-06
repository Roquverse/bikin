"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const pg_1 = require("pg");
const adapter_pg_1 = require("@prisma/adapter-pg");
const connectionString = process.env.DATABASE_URL;
const pool = new pg_1.Pool({ connectionString });
const adapter = new adapter_pg_1.PrismaPg(pool);
const prisma = new client_1.PrismaClient({ adapter });
async function main() {
    console.log('Starting seed...');
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
//# sourceMappingURL=seed.js.map