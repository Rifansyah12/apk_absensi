"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth-controller");
const auth_1 = require("../middleware/auth");
const validation_1 = require("../middleware/validation");
const upload_1 = require("../middleware/upload");
const router = (0, express_1.Router)();
const authController = new auth_controller_1.AuthController();
router.post('/login', validation_1.validateLogin, validation_1.handleValidationErrors, authController.login);
router.get('/profile', auth_1.authenticate, authController.getProfile);
router.post('/change-password', auth_1.authenticate, authController.changePassword);
router.put('/profile', auth_1.authenticate, upload_1.uploadSinglePhoto, upload_1.handleUploadError, authController.updateProfile);
exports.default = router;
//# sourceMappingURL=auth-routes.js.map