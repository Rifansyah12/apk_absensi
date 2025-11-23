"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const client_1 = require("@prisma/client");
const auth_1 = require("../utils/auth");
const error_handler_1 = require("../utils/error-handler");
const file_storage_1 = require("../utils/file-storage");
const prisma = new client_1.PrismaClient();
class UserService {
    async getAllUsers(division) {
        try {
            const whereClause = division ? { division, isActive: true } : { isActive: true };
            const users = await prisma.user.findMany({
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
            return users;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async getUserById(id) {
        try {
            const user = await prisma.user.findUnique({
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
            if (!user) {
                (0, error_handler_1.throwNotFoundError)('User not found');
            }
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async createUser(userData) {
        try {
            const requiredFields = ['employeeId', 'name', 'email', 'password', 'division', 'position', 'joinDate'];
            const missingFields = requiredFields.filter(field => !userData[field]);
            if (missingFields.length > 0) {
                (0, error_handler_1.throwValidationError)(`Missing required fields: ${missingFields.join(', ')}`);
            }
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(userData.email)) {
                (0, error_handler_1.throwValidationError)('Invalid email format');
            }
            const existingUser = await prisma.user.findUnique({
                where: { email: userData.email }
            });
            if (existingUser) {
                (0, error_handler_1.throwConflictError)('Email already exists');
            }
            const existingEmployee = await prisma.user.findUnique({
                where: { employeeId: userData.employeeId }
            });
            if (existingEmployee) {
                (0, error_handler_1.throwConflictError)('Employee ID already exists');
            }
            const validDivisions = Object.values(client_1.Division);
            if (!validDivisions.includes(userData.division)) {
                (0, error_handler_1.throwValidationError)(`Invalid division. Must be one of: ${validDivisions.join(', ')}`);
            }
            const hashedPassword = await (0, auth_1.hashPassword)(userData.password);
            const user = await prisma.user.create({
                data: {
                    employeeId: userData.employeeId,
                    name: userData.name,
                    email: userData.email,
                    password: hashedPassword,
                    division: userData.division,
                    position: userData.position,
                    joinDate: new Date(userData.joinDate),
                    phone: userData.phone ?? null,
                    address: userData.address ?? null,
                    photo: userData.photo ?? null,
                    role: client_1.Role.USER,
                    isActive: true,
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
                }
            });
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async deleteUser(id) {
        try {
            const existingUser = await prisma.user.findUnique({
                where: { id }
            });
            if (!existingUser) {
                (0, error_handler_1.throwNotFoundError)('User not found');
            }
            const user = await this.updateUser(id, {
                isActive: false,
                email: `deleted_${Date.now()}_${existingUser.email}`,
                employeeId: `deleted_${Date.now()}_${existingUser.employeeId}`,
            });
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async hardDeleteUser(id) {
        try {
            const existingUser = await prisma.user.findUnique({
                where: { id }
            });
            if (!existingUser) {
                (0, error_handler_1.throwNotFoundError)('User not found');
            }
            if (existingUser.photo) {
                (0, file_storage_1.deleteImageFile)(existingUser.photo);
            }
            const user = await prisma.user.delete({
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
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async updateUser(id, updateData) {
        try {
            const existingUser = await prisma.user.findUnique({
                where: { id }
            });
            if (!existingUser) {
                (0, error_handler_1.throwNotFoundError)('User not found');
            }
            if (updateData.photo && existingUser.photo && updateData.photo !== existingUser.photo) {
                (0, file_storage_1.deleteImageFile)(existingUser.photo);
            }
            if (updateData.email && updateData.email !== existingUser.email) {
                const emailExists = await prisma.user.findUnique({
                    where: { email: updateData.email }
                });
                if (emailExists) {
                    (0, error_handler_1.throwConflictError)('Email already exists');
                }
            }
            if (updateData.employeeId && updateData.employeeId !== existingUser.employeeId) {
                const employeeIdExists = await prisma.user.findUnique({
                    where: { employeeId: updateData.employeeId }
                });
                if (employeeIdExists) {
                    (0, error_handler_1.throwConflictError)('Employee ID already exists');
                }
            }
            const user = await prisma.user.update({
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
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async restoreUser(id) {
        try {
            const existingUser = await prisma.user.findUnique({
                where: { id }
            });
            if (!existingUser) {
                (0, error_handler_1.throwNotFoundError)('User not found');
            }
            const cleanEmail = existingUser.email.replace(/^deleted_\d+_/, '');
            const cleanEmployeeId = existingUser.employeeId.replace(/^deleted_\d+_/, '');
            const user = await this.updateUser(id, {
                isActive: true,
                email: cleanEmail,
                employeeId: cleanEmployeeId
            });
            return user;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async getUsersByDivision(division) {
        try {
            const users = await prisma.user.findMany({
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
            return users;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
    async getInactiveUsers() {
        try {
            const users = await prisma.user.findMany({
                where: { isActive: false },
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
            return users;
        }
        catch (error) {
            throw (0, error_handler_1.handleServiceError)(error);
        }
    }
}
exports.UserService = UserService;
//# sourceMappingURL=user-service.js.map