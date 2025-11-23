import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class HelpController {
    getHelp(req: AuthRequest, res: Response): Promise<void>;
    getAllHelpContent(req: AuthRequest, res: Response): Promise<void>;
    createHelpContent(req: AuthRequest, res: Response): Promise<void>;
    updateHelpContent(req: AuthRequest, res: Response): Promise<void>;
    deleteHelpContent(req: AuthRequest, res: Response): Promise<void>;
    toggleHelpContentStatus(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=help-controller.d.ts.map