import { Division } from '@prisma/client';
import { HelpResponse, CreateHelpContentRequest, UpdateHelpContentRequest } from '../types';
export declare class HelpService {
    getHelpContent(division?: Division): Promise<HelpResponse>;
    getAllHelpContent(): Promise<({
        creator: {
            name: string;
            id: number;
            email: string;
        };
    } & {
        id: number;
        division: import(".prisma/client").$Enums.Division | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.HelpContentType;
        title: string;
        content: string;
        order: number;
        createdBy: number;
    })[]>;
    createHelpContent(data: CreateHelpContentRequest, createdBy: number): Promise<{
        id: number;
        division: import(".prisma/client").$Enums.Division | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.HelpContentType;
        title: string;
        content: string;
        order: number;
        createdBy: number;
    }>;
    updateHelpContent(id: number, data: UpdateHelpContentRequest): Promise<{
        id: number;
        division: import(".prisma/client").$Enums.Division | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.HelpContentType;
        title: string;
        content: string;
        order: number;
        createdBy: number;
    }>;
    deleteHelpContent(id: number): Promise<{
        id: number;
        division: import(".prisma/client").$Enums.Division | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.HelpContentType;
        title: string;
        content: string;
        order: number;
        createdBy: number;
    }>;
    toggleHelpContentStatus(id: number): Promise<{
        id: number;
        division: import(".prisma/client").$Enums.Division | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
        type: import(".prisma/client").$Enums.HelpContentType;
        title: string;
        content: string;
        order: number;
        createdBy: number;
    }>;
}
//# sourceMappingURL=help-service.d.ts.map