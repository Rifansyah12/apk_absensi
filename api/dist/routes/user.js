"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const user_controller_1 = require("../controllers/user-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const userController = new user_controller_1.UserController();
router.get('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), userController.getAllUsers);
router.get('/:id', auth_1.authenticate, userController.getUserById);
router.post('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), userController.createUser);
router.put('/:id', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), userController.updateUser);
router.delete('/:id', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), userController.deleteUser);
exports.default = router;
//# sourceMappingURL=user.js.map