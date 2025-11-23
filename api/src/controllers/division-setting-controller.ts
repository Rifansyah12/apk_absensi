import { Response } from 'express';
import { AuthRequest } from '../types';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class DivisionSettingController {
  async getAllDivisionSettings(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const settings = await prisma.divisionSetting.findMany({
        orderBy: { division: 'asc' },
      });

      res.json({
        success: true,
        data: settings,
      });
    } catch (error: any) {
      console.error('Get division settings error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async getDivisionSetting(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { division } = req.params;
      const setting = await prisma.divisionSetting.findUnique({
        where: { division: division as any },
      });

      if (!setting) {
        res.status(404).json({
          success: false,
          message: 'Division setting not found',
        });
        return;
      }

      res.json({
        success: true,
        data: setting,
      });
    } catch (error: any) {
      console.error('Get division setting error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Internal server error',
      });
    }
  }

  async updateDivisionSetting(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { division } = req.params;
      const { workStart, workEnd, lateThreshold, deductionPerMinute } = req.body;

      // Validasi input
      if (!workStart || !workEnd || !lateThreshold || !deductionPerMinute) {
        res.status(400).json({
          success: false,
          message: 'All fields are required: workStart, workEnd, lateThreshold, deductionPerMinute',
        });
        return;
      }

      // Validasi format waktu
      const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
      if (!timeRegex.test(workStart) || !timeRegex.test(workEnd)) {
        res.status(400).json({
          success: false,
          message: 'Time format must be HH:MM (24-hour format)',
        });
        return;
      }

      // Validasi angka
      if (isNaN(Number(lateThreshold)) || isNaN(Number(deductionPerMinute))) {
        res.status(400).json({
          success: false,
          message: 'lateThreshold and deductionPerMinute must be numbers',
        });
        return;
      }

      const setting = await prisma.divisionSetting.update({
        where: { division: division as any },
        data: {
          workStart,
          workEnd,
          lateThreshold: parseInt(lateThreshold),
          deductionPerMinute: parseFloat(deductionPerMinute),
        },
      });

      res.json({
        success: true,
        message: 'Division setting updated successfully',
        data: setting,
      });
    } catch (error: any) {
      console.error('Update division setting error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to update division setting',
      });
    }
  }

  async createDivisionSetting(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user || req.user.role !== 'SUPER_ADMIN') {
        res.status(403).json({
          success: false,
          message: 'Insufficient permissions',
        });
        return;
      }

      const { division, workStart, workEnd, lateThreshold, deductionPerMinute } = req.body;

      // Validasi input
      if (!division || !workStart || !workEnd || !lateThreshold || !deductionPerMinute) {
        res.status(400).json({
          success: false,
          message: 'All fields are required: division, workStart, workEnd, lateThreshold, deductionPerMinute',
        });
        return;
      }

      const setting = await prisma.divisionSetting.create({
        data: {
          division: division as any,
          workStart,
          workEnd,
          lateThreshold: parseInt(lateThreshold),
          deductionPerMinute: parseFloat(deductionPerMinute),
        },
      });

      res.status(201).json({
        success: true,
        message: 'Division setting created successfully',
        data: setting,
      });
    } catch (error: any) {
      console.error('Create division setting error:', error);
      res.status(400).json({
        success: false,
        message: error.message || 'Failed to create division setting',
      });
    }
  }
}