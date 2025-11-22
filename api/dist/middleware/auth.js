"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authorizeDivision = exports.authorize = exports.authenticate = void 0;
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
const authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401).json({
                success: false,
                message: 'Access denied.'
            });
            return;
        }
        if (!roles.includes(req.user.role)) {
            res.status(403).json({
                success: false,
                message: 'Insufficient permissions.'
            });
            return;
        }
        next();
    };
};
exports.authorize = authorize;
const authorizeDivision = (divisions) => {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401).json({
                success: false,
                message: 'Access denied.'
            });
            return;
        }
        if (req.user.role === 'SUPER_ADMIN') {
            next();
            return;
        }
        if (!divisions.includes(req.user.division)) {
            res.status(403).json({
                success: false,
                message: 'Access denied for this division.'
            });
            return;
        }
        next();
    };
};
exports.authorizeDivision = authorizeDivision;
//# sourceMappingURL=auth.js.map