import { Response } from 'express';
import { AuthRequest } from '../types';
import { UserService } from '../services/user-service';

const userService = new UserService();

export class UserController {
  async getAllUsers(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { division } = req.query;
      const users = await userService.getAllUsers(division as any);

      res.json({
        success: true,
        data: users,
      });
    } catch (error: any) {
      console.error('Get all users error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getUserById(req: AuthRequest, res: Response): Promise<void> {
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

      // Jika bukan super admin, hanya bisa melihat data sendiri
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
    } catch (error: any) {
      console.error('Get user by id error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async createUser(req: AuthRequest, res: Response): Promise<void> {
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
    } catch (error: any) {
      console.error('Create user error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to create user',
      });
    }
  }

  async updateUser(req: AuthRequest, res: Response): Promise<void> {
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
    } catch (error: any) {
      console.error('Update user error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to update user',
      });
    }
  }

  async deleteUser(req: AuthRequest, res: Response): Promise<void> {
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
    } catch (error: any) {
      console.error('Delete user error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to delete user',
      });
    }
  }
}