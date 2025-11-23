"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HelpService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class HelpService {
    async getHelpContent(division) {
        const helpContents = await prisma.helpContent.findMany({
            where: {
                isActive: true,
                OR: [
                    { division: null },
                    { division: division || null },
                ],
            },
            orderBy: [
                { type: 'asc' },
                { order: 'asc' },
            ],
        });
        const faqs = helpContents.filter(content => content.type === 'FAQ');
        const contacts = helpContents.filter(content => content.type === 'CONTACT');
        const appInfo = helpContents.filter(content => content.type === 'APP_INFO');
        const general = helpContents.filter(content => content.type === 'GENERAL');
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
    async createHelpContent(data, createdBy) {
        return await prisma.helpContent.create({
            data: {
                ...data,
                createdBy,
            },
        });
    }
    async updateHelpContent(id, data) {
        return await prisma.helpContent.update({
            where: { id },
            data,
        });
    }
    async deleteHelpContent(id) {
        return await prisma.helpContent.delete({
            where: { id },
        });
    }
    async toggleHelpContentStatus(id) {
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
exports.HelpService = HelpService;
//# sourceMappingURL=help-service.js.map