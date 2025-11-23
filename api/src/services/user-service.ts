// api/src/services/user-service.ts
import { PrismaClient, User, Division, Role } from '@prisma/client';
import { hashPassword } from '../utils/auth';
import { UserCreateData } from '../types';
import {
  handleServiceError,
  throwValidationError,
  throwNotFoundError,
  throwConflictError
} from '../utils/error-handler';
import { deleteImageFile } from '../utils/file-storage';

const prisma = new PrismaClient();

// Define type without password
type UserWithoutPassword = Omit<User, 'password'>;

// Update the type for update data to include all possible fields
type UserUpdateData = {
  name?: string;
  email?: string;
  division?: Division;
  position?: string;
  phone?: string | null;
  address?: string | null;
  photo?: string | null;
  isActive?: boolean;
  employeeId?: string;
};

export class UserService {
  async getAllUsers(division?: Division): Promise<UserWithoutPassword[]> {
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

      return users as UserWithoutPassword[];
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async getUserById(id: number): Promise<UserWithoutPassword | null> {
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
        throwNotFoundError('User not found');
      }

      return user as UserWithoutPassword;
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async createUser(userData: UserCreateData): Promise<UserWithoutPassword> {
    try {
      // Validasi required fields
      const requiredFields = ['employeeId', 'name', 'email', 'password', 'division', 'position', 'joinDate'];
      const missingFields = requiredFields.filter(field => !userData[field as keyof UserCreateData]);

      if (missingFields.length > 0) {
        throwValidationError(`Missing required fields: ${missingFields.join(', ')}`);
      }

      // Validasi email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(userData.email)) {
        throwValidationError('Invalid email format');
      }

      // Validasi email unique
      const existingUser = await prisma.user.findUnique({
        where: { email: userData.email }
      });

      if (existingUser) {
        throwConflictError('Email already exists');
      }

      // Validasi employeeId unique
      const existingEmployee = await prisma.user.findUnique({
        where: { employeeId: userData.employeeId }
      });

      if (existingEmployee) {
        throwConflictError('Employee ID already exists');
      }

      // Validasi division
      const validDivisions = Object.values(Division);
      if (!validDivisions.includes(userData.division as Division)) {
        throwValidationError(`Invalid division. Must be one of: ${validDivisions.join(', ')}`);
      }

      // Hash password
      const hashedPassword = await hashPassword(userData.password);

      // Create user
      const user = await prisma.user.create({
        data: {
          employeeId: userData.employeeId,
          name: userData.name,
          email: userData.email,
          password: hashedPassword,
          division: userData.division as Division,
          position: userData.position,
          joinDate: new Date(userData.joinDate),
          phone: userData.phone ?? null,
          address: userData.address ?? null,
          photo: userData.photo ?? null,
          role: Role.USER,
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
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async deleteUser(id: number): Promise<UserWithoutPassword> {
    try {
      // Check if user exists first
      const existingUser = await prisma.user.findUnique({
        where: { id }
      });

      if (!existingUser) {
        throwNotFoundError('User not found');
      }

      // SOFT DELETE: Tidak menghapus foto, hanya menonaktifkan user
      const user = await this.updateUser(id, {
        isActive: false,
        email: `deleted_${Date.now()}_${existingUser!.email}`, // Prevent email conflict
        employeeId: `deleted_${Date.now()}_${existingUser!.employeeId}`, // Prevent employeeId conflict
        // Photo tetap dipertahankan untuk keperluan restore
      });

      return user;
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async hardDeleteUser(id: number): Promise<UserWithoutPassword> {
    try {
      // Only for admin purposes - completely remove user from database
      // Check if user exists first
      const existingUser = await prisma.user.findUnique({
        where: { id }
      });

      if (!existingUser) {
        throwNotFoundError('User not found');
      }

      // HARD DELETE: Hapus foto profil dari storage sebelum hard delete
      if (existingUser!.photo) {
        deleteImageFile(existingUser!.photo);
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

      return user as UserWithoutPassword;
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async updateUser(id: number, updateData: UserUpdateData): Promise<UserWithoutPassword> {
    try {
      // Check if user exists
      const existingUser = await prisma.user.findUnique({
        where: { id }
      });

      if (!existingUser) {
        throwNotFoundError('User not found');
      }

      // Jika ada photo baru dan user sebelumnya punya photo, hapus photo lama
      if (updateData.photo && existingUser!.photo && updateData.photo !== existingUser!.photo) {
        deleteImageFile(existingUser!.photo);
      }

      // PERBAIKAN: Gunakan existingUser! karena kita sudah check null di atas
      // If email is being updated, check for uniqueness
      if (updateData.email && updateData.email !== existingUser!.email) {
        const emailExists = await prisma.user.findUnique({
          where: { email: updateData.email }
        });

        if (emailExists) {
          throwConflictError('Email already exists');
        }
      }

      // If employeeId is being updated, check for uniqueness
      if (updateData.employeeId && updateData.employeeId !== existingUser!.employeeId) {
        const employeeIdExists = await prisma.user.findUnique({
          where: { employeeId: updateData.employeeId }
        });

        if (employeeIdExists) {
          throwConflictError('Employee ID already exists');
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

      return user as UserWithoutPassword;
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async restoreUser(id: number): Promise<UserWithoutPassword> {
    try {
      // Check if user exists
      const existingUser = await prisma.user.findUnique({
        where: { id }
      });

      if (!existingUser) {
        throwNotFoundError('User not found');
      }

      // PERBAIKAN: Gunakan existingUser! karena kita sudah check null
      // Restore user by setting isActive to true and cleaning up deleted prefixes
      const cleanEmail = existingUser!.email.replace(/^deleted_\d+_/, '');
      const cleanEmployeeId = existingUser!.employeeId.replace(/^deleted_\d+_/, '');

      const user = await this.updateUser(id, {
        isActive: true,
        email: cleanEmail,
        employeeId: cleanEmployeeId
        // Photo tetap dipertahankan
      });

      return user;
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async getUsersByDivision(division: Division): Promise<UserWithoutPassword[]> {
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

      return users as UserWithoutPassword[];
    } catch (error) {
      throw handleServiceError(error);
    }
  }

  async getInactiveUsers(): Promise<UserWithoutPassword[]> {
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

      return users as UserWithoutPassword[];
    } catch (error) {
      throw handleServiceError(error);
    }
  }
}