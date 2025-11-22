import { User, Division } from '@prisma/client';
type UserWithoutPassword = Omit<User, 'password'>;
export declare class UserService {
    getAllUsers(division?: Division): Promise<UserWithoutPassword[]>;
    getUserById(id: number): Promise<UserWithoutPassword | null>;
    createUser(userData: {
        employeeId: string;
        name: string;
        email: string;
        password: string;
        division: Division;
        position: string;
        joinDate: Date;
        phone?: string;
        address?: string;
        photo?: string;
    }): Promise<UserWithoutPassword>;
    updateUser(id: number, updateData: Partial<Omit<User, 'id' | 'password'>>): Promise<UserWithoutPassword>;
    deleteUser(id: number): Promise<UserWithoutPassword>;
    getUsersByDivision(division: Division): Promise<UserWithoutPassword[]>;
}
export {};
//# sourceMappingURL=user-service.d.ts.map