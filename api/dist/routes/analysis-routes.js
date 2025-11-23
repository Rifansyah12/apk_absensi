"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const analysis_controller_1 = require("../controllers/analysis-controller");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
const analysisController = new analysis_controller_1.AnalysisController();
router.get('/performance', auth_1.authenticate, (0, auth_1.authorize)('SUPER_ADMIN'), analysisController.getPerformanceAnalysis);
exports.default = router;
//# sourceMappingURL=analysis-routes.js.map