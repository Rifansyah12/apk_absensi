import { Response } from 'express';
import { AuthRequest } from '../types';
import { HelpService } from '../services/help-service';
import { CreateHelpContentRequest, UpdateHelpContentRequest } from '../types';

const helpService = new HelpService();

export class HelpController {
  async getHelp(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          message: 'Unauthorized',
        });
        return;
      }

      const helpContent = await helpService.getHelpContent(req.user.division);

      res.json({
        success: true,
        data: helpContent,
      });
    } catch (error) {
      console.error('Get help error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async getAllHelpContent(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Forbidden: Admin access required',
        });
        return;
      }

      const helpContent = await helpService.getAllHelpContent();

      res.json({
        success: true,
        data: helpContent,
      });
    } catch (error) {
      console.error('Get all help content error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async createHelpContent(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Forbidden: Admin access required',
        });
        return;
      }

      const data: CreateHelpContentRequest = req.body;

      // Validasi required fields
      if (!data.title || !data.content || !data.type) {
        res.status(400).json({
          success: false,
          message: 'Title, content, and type are required',
        });
        return;
      }

      const newContent = await helpService.createHelpContent(data, req.user.id);

      res.status(201).json({
        success: true,
        message: 'Help content created successfully',
        data: newContent,
      });
    } catch (error) {
      console.error('Create help content error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async updateHelpContent(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Forbidden: Admin access required',
        });
        return;
      }

      const id = parseInt(req.params.id);
      const data: UpdateHelpContentRequest = req.body;

      const updatedContent = await helpService.updateHelpContent(id, data);

      res.json({
        success: true,
        message: 'Help content updated successfully',
        data: updatedContent,
      });
    } catch (error) {
      console.error('Update help content error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async deleteHelpContent(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Forbidden: Admin access required',
        });
        return;
      }

      const id = parseInt(req.params.id);
      await helpService.deleteHelpContent(id);

      res.json({
        success: true,
        message: 'Help content deleted successfully',
      });
    } catch (error) {
      console.error('Delete help content error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }

  async toggleHelpContentStatus(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Forbidden: Admin access required',
        });
        return;
      }

      const id = parseInt(req.params.id);
      const updatedContent = await helpService.toggleHelpContentStatus(id);

      res.json({
        success: true,
        message: `Help content ${updatedContent.isActive ? 'activated' : 'deactivated'} successfully`,
        data: updatedContent,
      });
    } catch (error) {
      console.error('Toggle help content status error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  }
}