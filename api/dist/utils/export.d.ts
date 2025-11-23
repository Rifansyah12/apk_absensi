import { Response } from 'express';
export declare class ExportUtils {
    static exportToExcel(data: any[], columns: any[], filename: string, res: Response): Promise<void>;
    static exportToPDF(data: any[], columns: any[], filename: string, res: Response): void;
}
//# sourceMappingURL=export.d.ts.map