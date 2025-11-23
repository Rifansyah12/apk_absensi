import { Response } from 'express';
import { AuthRequest, LoginRequest } from '../types';
import { UserService } from '../services/user-service';
import { comparePassword, generateToken, hashPassword } from '../utils/auth';
import { PrismaClient } from '@prisma/client';
import { saveImageToFile, deleteImageFile } from '../utils/file-storage';

const prisma = new PrismaClient();
const userService = new UserService();

export class AuthController {
  async login(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { email, password }: LoginRequest = req.body;

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

      const isPasswordValid = await comparePassword(password, user.password);
      if (!isPasswordValid) {
        res.status(401).json({
          success: false,
          message: 'Invalid email or password',
        });
        return;
      }

      const token = generateToken(user);

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
            photo: user.photo, // Tambahkan photo di response login
          },
        },
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async getProfile(req: AuthRequest, res: Response): Promise<void> {
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
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async changePassword(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { currentPassword, newPassword } = req.body;

      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      // Validasi input
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

      const isCurrentPasswordValid = await comparePassword(currentPassword, user.password);
      if (!isCurrentPasswordValid) {
        res.status(400).json({
          success: false,
          message: 'Current password is incorrect',
        });
        return;
      }

      const hashedNewPassword = await hashPassword(newPassword);

      await prisma.user.update({
        where: { id: req.user.id },
        data: { password: hashedNewPassword },
      });

      res.json({
        success: true,
        message: 'Password changed successfully',
      });
    } catch (error) {
      console.error('Change password error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async updateProfile(req: AuthRequest, res: Response): Promise<void> {
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

      // Validasi: minimal ada satu yang diupdate (foto atau password)
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

      const updateData: any = {};

      // Handle photo update
      if (file) {
        // Hapus foto lama jika ada
        if (user.photo) {
          deleteImageFile(user.photo);
        }

        // Simpan foto baru
        const photoPath = saveImageToFile(file.buffer, req.user.id, 'profile');
        updateData.photo = photoPath;
      }

      // Handle password update
      if (password) {
        if (!currentPassword) {
          res.status(400).json({
            success: false,
            message: 'Current password is required to change password',
          });
          return;
        }

        const isCurrentPasswordValid = await comparePassword(currentPassword, user.password);
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

        updateData.password = await hashPassword(password);
      }

      // Update user data
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
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }
}