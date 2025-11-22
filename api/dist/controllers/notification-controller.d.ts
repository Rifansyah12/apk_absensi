import { Response } from 'express';
import { AuthRequest } from '../types';
export declare class NotificationController {
    getMyNotifications(req: AuthRequest, res: Response): Promise<void>;
    markAsRead(req: AuthRequest, res: Response): Promise<void>;
    markAllAsRead(req: AuthRequest, res: Response): Promise<void>;
    getUnreadCount(req: AuthRequest, res: Response): Promise<void>;
}
//# sourceMappingURL=notification-controller.d.ts.map