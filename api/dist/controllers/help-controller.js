"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HelpController = void 0;
const help_service_1 = require("../services/help-service");
const helpService = new help_service_1.HelpService();
class HelpController {
    async getHelp(req, res) {
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
        }
        catch (error) {
            console.error('Get help error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async getAllHelpContent(req, res) {
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
        }
        catch (error) {
            console.error('Get all help content error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async createHelpContent(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Forbidden: Admin access required',
                });
                return;
            }
            const data = req.body;
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
        }
        catch (error) {
            console.error('Create help content error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async updateHelpContent(req, res) {
        try {
            if (!req.user || req.user.role !== 'SUPER_ADMIN') {
                res.status(403).json({
                    success: false,
                    message: 'Forbidden: Admin access required',
                });
                return;
            }
            const id = parseInt(req.params.id);
            const data = req.body;
            const updatedContent = await helpService.updateHelpContent(id, data);
            res.json({
                success: true,
                message: 'Help content updated successfully',
                data: updatedContent,
            });
        }
        catch (error) {
            console.error('Update help content error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async deleteHelpContent(req, res) {
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
        }
        catch (error) {
            console.error('Delete help content error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
    async toggleHelpContentStatus(req, res) {
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
        }
        catch (error) {
            console.error('Toggle help content status error:', error);
            res.status(500).json({
                success: false,
                message: 'Internal server error',
            });
        }
    }
}
exports.HelpController = HelpController;
//# sourceMappingURL=help-controller.js.map