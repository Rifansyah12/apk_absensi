"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const division_setting_controller_1 = require("../controllers/division-setting-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const divisionSettingController = new division_setting_controller_1.DivisionSettingController();
router.get('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), divisionSettingController.getAllDivisionSettings);
router.get('/:division', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), divisionSettingController.getDivisionSetting);
router.put('/:division', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), divisionSettingController.updateDivisionSetting);
router.post('/', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), divisionSettingController.createDivisionSetting);
exports.default = router;
//# sourceMappingURL=division-setting-routes.js.map