"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const help_controller_1 = require("../controllers/help-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const helpController = new help_controller_1.HelpController();
router.get('/', auth_1.authenticate, helpController.getHelp);
router.get('/admin/all', auth_1.authenticate, helpController.getAllHelpContent);
router.post('/admin', auth_1.authenticate, helpController.createHelpContent);
router.put('/admin/:id', auth_1.authenticate, helpController.updateHelpContent);
router.delete('/admin/:id', auth_1.authenticate, helpController.deleteHelpContent);
router.patch('/admin/:id/toggle-status', auth_1.authenticate, helpController.toggleHelpContentStatus);
exports.default = router;
//# sourceMappingURL=help-routes.js.map