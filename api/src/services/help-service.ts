import { PrismaClient, Division  } from '@prisma/client';
import { HelpResponse, CreateHelpContentRequest, UpdateHelpContentRequest, HelpContent } from '../types';

const prisma = new PrismaClient();

export class HelpService {
  async getHelpContent(division?: Division): Promise<HelpResponse> {
    // Ambil konten global (division = null) dan konten khusus divisi
    const helpContents = await prisma.helpContent.findMany({
      where: {
        isActive: true,
        OR: [
          { division: null }, // Konten global
          { division: division || null }, // Konten khusus divisi
        ],
      },
      orderBy: [
        { type: 'asc' },
        { order: 'asc' },
      ],
    });

    // Kelompokkan berdasarkan type
    const faqs = helpContents.filter(content => content.type === 'FAQ') as HelpContent[];
    const contacts = helpContents.filter(content => content.type === 'CONTACT') as HelpContent[];
    const appInfo = helpContents.filter(content => content.type === 'APP_INFO') as HelpContent[];
    const general = helpContents.filter(content => content.type === 'GENERAL') as HelpContent[];

    return {
      faqs,
      contacts,
      appInfo,
      general,
    };
  }

  async getAllHelpContent() {
    return await prisma.helpContent.findMany({
      include: {
        creator: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: [
        { division: 'asc' },
        { type: 'asc' },
        { order: 'asc' },
      ],
    });
  }

  async createHelpContent(data: CreateHelpContentRequest, createdBy: number) {
    return await prisma.helpContent.create({
      data: {
        ...data,
        createdBy,
      },
    });
  }

  async updateHelpContent(id: number, data: UpdateHelpContentRequest) {
    return await prisma.helpContent.update({
      where: { id },
      data,
    });
  }

  async deleteHelpContent(id: number) {
    return await prisma.helpContent.delete({
      where: { id },
    });
  }

  async toggleHelpContentStatus(id: number) {
    const content = await prisma.helpContent.findUnique({
      where: { id },
    });

    if (!content) {
      throw new Error('Help content not found');
    }

    return await prisma.helpContent.update({
      where: { id },
      data: {
        isActive: !content.isActive,
      },
    });
  }
}