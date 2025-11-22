import { Router } from 'express';
import { SalaryController } from '../controllers/salary-controller';
import { authenticate, authorize } from '../middleware/auth';

const router = Router();
const salaryController = new SalaryController();

router.get('/my-salaries', authenticate, salaryController.getMySalaries);
router.get('/:id', authenticate, salaryController.getSalaryById);
router.post('/calculate', authenticate, authorize('SUPER_ADMIN'), salaryController.calculateSalary);

export default router;