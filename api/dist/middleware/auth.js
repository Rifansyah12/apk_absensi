"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authorize = exports.authenticate = void 0;
const auth_1 = require("../utils/auth");
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const authenticate = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        if (!token) {
            res.status(401).json({
                success: false,
                message: 'Access denied. No token provided.'
            });
            return;
        }
        const decoded = (0, auth_1.verifyToken)(token);
        const user = await prisma.user.findUnique({
            where: { id: decoded.id },
        });
        if (!user) {
            res.status(401).json({
                success: false,
                message: 'Invalid token.'
            });
            return;
        }
        if (!user.isActive) {
            res.status(401).json({
                success: false,
                message: 'Account is deactivated.'
            });
            return;
        }
        req.user = user;
        next();
    }
    catch (error) {
        res.status(401).json({
            success: false,
            message: 'Invalid token.'
        });
    }
};
exports.authenticate = authenticate;
const authorize = (allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required'
            });
        }
        const userRole = req.user.role;
        const superAdminRoles = [
            'SUPER_ADMIN',
            'SUPER_ADMIN_FINANCE',
            'SUPER_ADMIN_APO',
            'SUPER_ADMIN_FRONT_DESK',
            'SUPER_ADMIN_ONSITE',
        ];
        if (allowedRoles === '*') {
            if (superAdminRoles.includes(userRole)) {
                return next();
            }
            return res.status(403).json({
                success: false,
                message: 'Only super-admin roles are allowed'
            });
        }
        const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];
        if (roles.includes('SUPER_ADMIN') && superAdminRoles.includes(userRole)) {
            return next();
        }
        if (roles.includes(userRole)) {
            return next();
        }
        return res.status(403).json({
            success: false,
            message: 'Insufficient permissions'
        });
    };
};
exports.authorize = authorize;
//# sourceMappingURL=auth.js.map