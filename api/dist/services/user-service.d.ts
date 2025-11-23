import { User, Division } from '@prisma/client';
import { UserCreateData } from '../types';
type UserWithoutPassword = Omit<User, 'password'>;
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
export declare class UserService {
    getAllUsers(division?: Division): Promise<UserWithoutPassword[]>;
    getUserById(id: number): Promise<UserWithoutPassword | null>;
    createUser(userData: UserCreateData): Promise<UserWithoutPassword>;
    deleteUser(id: number): Promise<UserWithoutPassword>;
    hardDeleteUser(id: number): Promise<UserWithoutPassword>;
    updateUser(id: number, updateData: UserUpdateData): Promise<UserWithoutPassword>;
    restoreUser(id: number): Promise<UserWithoutPassword>;
    getUsersByDivision(division: Division): Promise<UserWithoutPassword[]>;
    getInactiveUsers(): Promise<UserWithoutPassword[]>;
}
export {};
//# sourceMappingURL=user-service.d.ts.map