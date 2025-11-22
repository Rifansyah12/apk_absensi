"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const client_1 = require("@prisma/client");
const auth_1 = require("../utils/auth");
const prisma = new client_1.PrismaClient();
class UserService {
    async getAllUsers(division) {
        const whereClause = division ? { division, isActive: true } : { isActive: true };
        return await prisma.user.findMany({
            where: whereClause,
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
    async getUserById(id) {
        return await prisma.user.findUnique({
            where: { id },
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
    async createUser(userData) {
        const hashedPassword = await (0, auth_1.hashPassword)(userData.password);
        return await prisma.user.create({
            data: {
                ...userData,
                password: hashedPassword,
            },
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
    async updateUser(id, updateData) {
        return await prisma.user.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
    async deleteUser(id) {
        return await prisma.user.update({
            where: { id },
            data: { isActive: false },
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
    async getUsersByDivision(division) {
        return await prisma.user.findMany({
            where: { division, isActive: true },
            select: {
                id: true,
                employeeId: true,
                name: true,
                email: true,
                division: true,
                role: true,
                position: true,
                joinDate: true,
                phone: true,
                address: true,
                photo: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
            },
        });
    }
}
exports.UserService = UserService;
//# sourceMappingURL=user-service.js.map