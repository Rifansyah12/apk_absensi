import { Response } from 'express';
import { AuthRequest } from '../types';
import { UserService } from '../services/user-service';
import { saveImageToFile } from '../utils/file-storage';
import { PrismaClient, Division } from '@prisma/client';
import { sendErrorResponse, AppError, ErrorType, throwValidationError } from '../utils/error-handler';

const prisma = new PrismaClient();
const userService = new UserService();

export class UserController {
  async getAllUsers(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      const { division, isActive } = req.user;
      
      let users;
      if (isActive === true) {
        // Get all users including inactive ones
        users = await prisma.user.findMany({
          where: division ? { division: division as Division } : {},
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
      } else {
        // Get only active users (default behavior)
        users = await userService.getAllUsers(division as Division);
      }

      res.json({
        success: true,
        data: users,
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async getUserById(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        throw new AppError(ErrorType.UNAUTHORIZED, 'Unauthorized');
      }

      const { id } = req.params;
      const user = await userService.getUserById(parseInt(id));

      // PERBAIKAN: Pastikan user tidak null sebelum mengakses propertinya
      if (!user) {
        throw new AppError(ErrorType.NOT_FOUND, 'User not found');
      }

      // Jika bukan super admin, hanya bisa melihat data sendiri
      if (req.user.role !== 'SUPER_ADMIN' && req.user.id !== user.id) {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async createUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      // Validasi field required
      const requiredFields = ['employeeId', 'name', 'email', 'password', 'position', 'joinDate'];
      const missingFields = requiredFields.filter(field => !req.body[field]);
      
      if (missingFields.length > 0) {
        throwValidationError(`Missing required fields: ${missingFields.join(', ')}`);
      }

      // Buat user data object dari form-data
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

      // Buat user tanpa foto dulu
      const user = await userService.createUser(userData);

      // Jika ada file foto, simpan dan update user
      if (req.file) {
        try {
          const photoPath = saveImageToFile(req.file.buffer, user.id, 'profile');
          const updatedUser = await userService.updateUser(user.id, { photo: photoPath });
          
          res.status(201).json({
            success: true,
            message: 'User created successfully',
            data: updatedUser,
          });
          return;
        } catch (updateError: any) {
          console.error('Failed to update user photo:', updateError);
          // Jika update photo gagal, tetap return user tanpa foto
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
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async updateUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      const { id } = req.params;
      const userId = parseInt(id);

      console.log('Update user body:', req.body);
      console.log('Update user file:', req.file ? 'File received' : 'No file');

      // Buat update data object
      const updateData: any = {};

      // Hanya update field yang ada di request
      if (req.body.name) updateData.name = req.body.name;
      if (req.body.email) updateData.email = req.body.email;
      if (req.body.division) updateData.division = req.body.division as Division;
      if (req.body.position) updateData.position = req.body.position;
      if (req.body.phone !== undefined) updateData.phone = req.body.phone || null;
      if (req.body.address !== undefined) updateData.address = req.body.address || null;
      if (req.body.isActive !== undefined) updateData.isActive = req.body.isActive === 'true';
      if (req.body.employeeId) updateData.employeeId = req.body.employeeId;

      // Jika ada file foto, proses foto
      if (req.file) {
        // Tidak perlu hapus foto lama di sini karena sudah ditangani di service
        const photoPath = saveImageToFile(req.file.buffer, userId, 'profile');
        updateData.photo = photoPath;
      }

      // Update user hanya jika ada data yang diubah
      if (Object.keys(updateData).length > 0) {
        const user = await userService.updateUser(userId, updateData);
        res.json({
          success: true,
          message: 'User updated successfully',
          data: user,
        });
      } else {
        throwValidationError('No data provided for update');
      }
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async deleteUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      const { id } = req.params;
      const { hardDelete } = req.query; // Optional parameter for hard delete

      let user;
      if (hardDelete === 'true') {
        // Hard delete - completely remove user (use with caution)
        user = await userService.hardDeleteUser(parseInt(id));
      } else {
        // Soft delete - default behavior
        user = await userService.deleteUser(parseInt(id));
      }

      res.json({
        success: true,
        message: hardDelete === 'true' ? 'User permanently deleted' : 'User deleted successfully',
        data: user,
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async restoreUser(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      const { id } = req.params;
      
      // Restore soft-deleted user menggunakan service
      const user = await userService.restoreUser(parseInt(id));

      res.json({
        success: true,
        message: 'User restored successfully',
        data: user,
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }

  async getInactiveUsers(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        throw new AppError(ErrorType.FORBIDDEN, 'Insufficient permissions');
      }

      const users = await userService.getInactiveUsers();

      res.json({
        success: true,
        data: users,
      });
    } catch (error: any) {
      sendErrorResponse(res, error);
    }
  }
}