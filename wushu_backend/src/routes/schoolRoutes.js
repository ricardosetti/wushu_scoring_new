import express from 'express';
import {
  fetchSchools,
  createSchool,
  updateSchool,
  deleteSchool,
  fetchSchoolById,
  generateRegistrationLink,
} from '../controllers/schoolController.js';
import multer from 'multer';
import { requireAuth, requireAdminRole } from '../middleware/auth.js'; // Assumed middleware

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Protected Routes (Admin Only)
router.get('/', requireAuth, requireAdminRole, fetchSchools);
router.post('/', requireAuth, requireAdminRole, upload.single('school_logo'), createSchool);
router.put('/:id', requireAuth, requireAdminRole, upload.single('school_logo'), updateSchool);
router.delete('/:id', requireAuth, requireAdminRole, deleteSchool);
router.get('/:id', requireAuth, requireAdminRole, fetchSchoolById);
router.post('/:schoolId/generate-token', requireAuth, requireAdminRole, generateRegistrationLink);

export default router;