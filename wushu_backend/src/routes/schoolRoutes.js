import express from 'express';
import {
  fetchSchools,
  createSchool,
  updateSchool,
  deleteSchool,
  fetchSchoolById,
  generateRegistrationLink,
  toggleSchoolStatusController // <--- Ensure this is imported
} from '../controllers/schoolController.js';
import multer from 'multer';

// CRITICAL FIX: Import the auth middleware so the variables are defined
import { authenticateToken, authorizeRole } from './auth.js'; 

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Protected Routes (Admin Only)
router.get('/', authenticateToken, authorizeRole('admin'), fetchSchools);
router.post('/', authenticateToken, authorizeRole('admin'), upload.single('school_logo'), createSchool);
router.put('/:id', authenticateToken, authorizeRole('admin'), upload.single('school_logo'), updateSchool);
router.delete('/:id', authenticateToken, authorizeRole('admin'), deleteSchool);
router.get('/:id', authenticateToken, authorizeRole('admin'), fetchSchoolById);
router.post('/:schoolId/generate-token', authenticateToken, authorizeRole('admin'), generateRegistrationLink);

// NEW ROUTE: Toggle School Status
router.post('/:id/toggle-status', authenticateToken, authorizeRole('admin'), toggleSchoolStatusController);

export default router;