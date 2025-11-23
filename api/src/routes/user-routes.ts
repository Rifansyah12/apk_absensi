import { Router } from 'express';
import { UserController } from '../controllers/user-controller';
import { authenticate, authorize } from '../middleware/auth';
import { uploadSinglePhoto, handleUploadError } from '../middleware/upload';

const router = Router();
const userController = new UserController();

// Get all users (with optional includeInactive parameter)
router.get('/', authenticate, authorize('SUPER_ADMIN'), userController.getAllUsers);

// Get inactive users only
router.get('/inactive', authenticate, authorize('SUPER_ADMIN'), userController.getInactiveUsers);

// Get user by ID
router.get('/:id', authenticate, userController.getUserById);

// Create user with photo upload
router.post('/', 
  authenticate, 
  authorize('SUPER_ADMIN'), 
  uploadSinglePhoto, 
  handleUploadError, 
  userController.createUser
);

// Update user with photo upload
router.put('/:id', 
  authenticate, 
  authorize('SUPER_ADMIN'), 
  uploadSinglePhoto, 
  handleUploadError, 
  userController.updateUser
);

// Delete user (soft delete by default, hard delete with query parameter)
router.delete('/:id', authenticate, authorize('SUPER_ADMIN'), userController.deleteUser);

// Restore soft-deleted user
router.patch('/:id/restore', authenticate, authorize('SUPER_ADMIN'), userController.restoreUser);

export default router;