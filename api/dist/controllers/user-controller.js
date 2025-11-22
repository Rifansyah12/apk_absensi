"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserController = void 0;
const user_service_1 = require("../services/user-service");
const userService = new user_service_1.UserService();
class UserController {
    async getAllUsers(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { division } = req.query;
            const users = await userService.getAllUsers(division);
            res.json({
                success: true,
                data: users,
            });
        }
        catch (error) {
            console.error('Get all users error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async getUserById(req, res) {
        try {
            if (!req.user) {
                res.status(401).json({
                    success: false,
                    message: 'Unauthorized',
                });
                return;
            }
            const { id } = req.params;
            const user = await userService.getUserById(parseInt(id));
            if (!user) {
                res.status(404).json({
                    success: false,
                    message: 'User not found',
                });
                return;
            }
            if (req.user.role !== 'SUPER_ADMIN' && req.user.id !== user.id) {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            res.json({
                success: true,
                data: user,
            });
        }
        catch (error) {
            console.error('Get user by id error:', error);
            res.status(500).json({
                success: false,
                message: error.message || 'Internal server error',
            });
        }
    }
    async createUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const user = await userService.createUser(req.body);
            res.status(201).json({
                success: true,
                message: 'User created successfully',
                data: user,
            });
        }
        catch (error) {
            console.error('Create user error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to create user',
            });
        }
    }
    async updateUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { id } = req.params;
            const user = await userService.updateUser(parseInt(id), req.body);
            res.json({
                success: true,
                message: 'User updated successfully',
                data: user,
            });
        }
        catch (error) {
            console.error('Update user error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to update user',
            });
        }
    }
    async deleteUser(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Insufficient permissions',
                });
                return;
            }
            const { id } = req.params;
            const user = await userService.deleteUser(parseInt(id));
            res.json({
                success: true,
                message: 'User deleted successfully',
                data: user,
            });
        }
        catch (error) {
            console.error('Delete user error:', error);
            res.status(400).json({
                success: false,
                message: error.message || 'Failed to delete user',
            });
        }
    }
}
exports.UserController = UserController;
//# sourceMappingURL=user-controller.js.map