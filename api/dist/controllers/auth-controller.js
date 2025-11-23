"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const user_service_1 = require("../services/user-service");
const auth_1 = require("../utils/auth");
const client_1 = require("@prisma/client");
const file_storage_1 = require("../utils/file-storage");
const prisma = new client_1.PrismaClient();
const userService = new user_service_1.UserService();
class AuthController {
    async login(req, res) {
        try {
            const { email, password } = req.body;
            const user = await prisma.user.findUnique({
                where: { email },
            });
            if (!user || !user.isActive) {
                res.status(401).json({
                    success: false,
                    message: 'Invalid email or password',
                });
                return;
            }
            const isPasswordValid = await (0, auth_1.comparePassword)(password, user.password);
            if (!isPasswordValid) {
                res.status(401).json({
                    success: false,
                    message: 'Invalid email or password',
                });
                return;
            }
            const token = (0, auth_1.generateToken)(user);
            res.json({
                success: true,
                message: 'Login successful',
                data: {
                    token,
                    user: {
                        id: user.id,
                        employeeId: user.employeeId,
                        name: user.name,
                        email: user.email,
                        division: user.division,
                        role: user.role,
                        position: user.position,
                        photo: user.photo,
                    },
                },
            });
        }
        catch (error) {
            console.error('Login error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async getProfile(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const user = await userService.getUserById(req.user.id);
            res.json({
                success: true,
                data: user,
            });
        }
        catch (error) {
            console.error('Get profile error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async changePassword(req, res) {
        try {
            const { currentPassword, newPassword } = req.body;
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            if (!currentPassword || !newPassword) {
                res.status(400).json({
                    success: false,
                    message: 'Current password and new password are required',
                });
                return;
            }
            if (newPassword.length < 6) {
                res.status(400).json({
                    success: false,
                    message: 'New password must be at least 6 characters long',
                });
                return;
            }
            const user = await prisma.user.findUnique({
                where: { id: req.user.id },
            });
            if (!user) {
                res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
                return;
            }
            const isCurrentPasswordValid = await (0, auth_1.comparePassword)(currentPassword, user.password);
            if (!isCurrentPasswordValid) {
                res.status(400).json({
                    success: false,
                    message: 'Current password is incorrect',
                });
                return;
            }
            const hashedNewPassword = await (0, auth_1.hashPassword)(newPassword);
            await prisma.user.update({
                where: { id: req.user.id },
                data: { password: hashedNewPassword },
            });
            res.json({
                success: true,
                message: 'Password changed successfully',
            });
        }
        catch (error) {
            console.error('Change password error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async updateProfile(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { password, currentPassword } = req.body;
            const file = req.file;
            if (!file && !password) {
                res.status(400).json({
                    success: false,
                    message: 'No data to update. Provide either photo or password',
                });
                return;
            }
            const user = await prisma.user.findUnique({
                where: { id: req.user.id },
            });
            if (!user) {
                res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
                return;
            }
            const updateData = {};
            if (file) {
                if (user.photo) {
                    (0, file_storage_1.deleteImageFile)(user.photo);
                }
                const photoPath = (0, file_storage_1.saveImageToFile)(file.buffer, req.user.id, 'profile');
                updateData.photo = photoPath;
            }
            if (password) {
                if (!currentPassword) {
                    res.status(400).json({
                        success: false,
                        message: 'Current password is required to change password',
                    });
                    return;
                }
                const isCurrentPasswordValid = await (0, auth_1.comparePassword)(currentPassword, user.password);
                if (!isCurrentPasswordValid) {
                    res.status(400).json({
                        success: false,
                        message: 'Current password is incorrect',
                    });
                    return;
                }
                if (password.length < 6) {
                    res.status(400).json({
                        success: false,
                        message: 'New password must be at least 6 characters long',
                    });
                    return;
                }
                updateData.password = await (0, auth_1.hashPassword)(password);
            }
            const updatedUser = await prisma.user.update({
                where: { id: req.user.id },
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
            res.json({
                success: true,
                message: 'Profile updated successfully',
                data: updatedUser,
            });
        }
        catch (error) {
            console.error('Update profile error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth-controller.js.map