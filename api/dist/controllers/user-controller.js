"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const user_service_1 = require("../services/user-service");
const file_storage_1 = require("../utils/file-storage");
const client_1 = require("@prisma/client");
const error_handler_1 = require("../utils/error-handler");
const prisma = new client_1.PrismaClient();
const userService = new user_service_1.UserService();
class UserController {
    async getAllUsers(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const { division, isActive } = req.user;
            let users;
            if (isActive === true) {
                users = await prisma.user.findMany({
                    where: division ? { division: division } : {},
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
                    orderBy: { createdAt: 'desc' }
                });
            }
            else {
                users = await userService.getAllUsers(division);
            }
            res.json({
                success: true,
                data: users,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getUserById(req, res) {
        try {
            if (!req.user) {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.UNAUTHORIZED, 'Unauthorized');
            }
            const { id } = req.params;
            const user = await userService.getUserById(parseInt(id));
            if (!user) {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.NOT_FOUND, 'User not found');
            }
            if (req.user.role !== 'SUPER_ADMIN' && req.user.id !== user.id) {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            res.json({
                success: true,
                data: user,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async createUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const requiredFields = ['employeeId', 'name', 'email', 'password', 'position', 'joinDate'];
            const missingFields = requiredFields.filter(field => !req.body[field]);
            if (missingFields.length > 0) {
                (0, error_handler_1.throwValidationError)(`Missing required fields: ${missingFields.join(', ')}`);
            }
            const userData = {
                employeeId: req.body.employeeId,
                name: req.body.name,
                email: req.body.email,
                password: req.body.password,
                division: req.user.division,
                position: req.body.position,
                joinDate: req.body.joinDate,
                phone: req.body.phone || undefined,
                address: req.body.address || undefined,
            };
            const user = await userService.createUser(userData);
            if (req.file) {
                try {
                    const photoPath = (0, file_storage_1.saveImageToFile)(req.file.buffer, user.id, 'profile');
                    const updatedUser = await userService.updateUser(user.id, { photo: photoPath });
                    res.status(201).json({
                        success: true,
                        message: 'User created successfully',
                        data: updatedUser,
                    });
                    return;
                }
                catch (updateError) {
                    console.error('Failed to update user photo:', updateError);
                    res.status(201).json({
                        success: true,
                        message: 'User created successfully but failed to save photo',
                        data: user,
                    });
                    return;
                }
            }
            res.status(201).json({
                success: true,
                message: 'User created successfully',
                data: user,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async updateUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const { id } = req.params;
            const userId = parseInt(id);
            console.log('Update user body:', req.body);
            console.log('Update user file:', req.file ? 'File received' : 'No file');
            const updateData = {};
            if (req.body.name)
                updateData.name = req.body.name;
            if (req.body.email)
                updateData.email = req.body.email;
            if (req.body.division)
                updateData.division = req.body.division;
            if (req.body.position)
                updateData.position = req.body.position;
            if (req.body.phone !== undefined)
                updateData.phone = req.body.phone || null;
            if (req.body.address !== undefined)
                updateData.address = req.body.address || null;
            if (req.body.isActive !== undefined)
                updateData.isActive = req.body.isActive === 'true';
            if (req.body.employeeId)
                updateData.employeeId = req.body.employeeId;
            if (req.file) {
                const photoPath = (0, file_storage_1.saveImageToFile)(req.file.buffer, userId, 'profile');
                updateData.photo = photoPath;
            }
            if (Object.keys(updateData).length > 0) {
                const user = await userService.updateUser(userId, updateData);
                res.json({
                    success: true,
                    message: 'User updated successfully',
                    data: user,
                });
            }
            else {
                (0, error_handler_1.throwValidationError)('No data provided for update');
            }
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async deleteUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const { id } = req.params;
            const { hardDelete } = req.query;
            let user;
            if (hardDelete === 'true') {
                user = await userService.hardDeleteUser(parseInt(id));
            }
            else {
                user = await userService.deleteUser(parseInt(id));
            }
            res.json({
                success: true,
                message: hardDelete === 'true' ? 'User permanently deleted' : 'User deleted successfully',
                data: user,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async restoreUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const { id } = req.params;
            const user = await userService.restoreUser(parseInt(id));
            res.json({
                success: true,
                message: 'User restored successfully',
                data: user,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
    async getInactiveUsers(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                throw new error_handler_1.AppError(error_handler_1.ErrorType.FORBIDDEN, 'Insufficient permissions');
            }
            const users = await userService.getInactiveUsers();
            res.json({
                success: true,
                data: users,
            });
        }
        catch (error) {
            (0, error_handler_1.sendErrorResponse)(res, error);
        }
    }
}
exports.UserController = UserController;
//# sourceMappingURL=user-controller.js.map