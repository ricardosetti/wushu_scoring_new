import express from 'express';
import {
  createRegistration,
  fetchAllRegistrations,
  fetchRegistrationByEmail,
  fetchRegistrationById,
  updateRegistrationStatusController,
  addDivisionToRegistration,
  fetchDivisionsForRegistration,
  removeDivisionFromRegistration,
  validateRegistrationToken,
  updateRegistration,
  approveRegistrationController,
  registerAsMember,
  withdrawRegistration,
  editRegistration
} from '../controllers/registrationController.js';

// Import auth middleware
import { authenticateToken } from './auth.js'; 

const router = express.Router();

// Middleware to check if the user can access specific registration details
// Note: We only use this for strict data like personal info updates by ID
const checkRegistrationAccess = (req, res, next) => {
  // Allow admins to access all routes
  if (req.user.role === 'admin') {
    return next();
  }

  // Allow participants to access their own data
  if (req.user.role === 'participant') {
    // For GET /registrations/email/:email
    if (req.method === 'GET' && req.url.startsWith('/email/')) {
      const requestedEmail = req.params.email;
      if (requestedEmail === req.user.email) {
        return next();
      }
      return res.status(403).json({ error: 'Forbidden: You can only access your own data' });
    }
  }

  // Default to denying access for other strictly matched routes
  return res.status(403).json({ error: 'Forbidden: Insufficient permissions' });
};

// Public Routes
router.post('/', createRegistration);
router.get('/register/validate-token', (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).json({ error: 'Missing token parameter' });
  }
  req.params = { token };
  validateRegistrationToken(req, res);
});

// --- Protected Routes ---

// List & Details
router.get('/', checkRegistrationAccess, fetchAllRegistrations);
router.get('/email/:email', checkRegistrationAccess, fetchRegistrationByEmail);
router.get('/:id', checkRegistrationAccess, fetchRegistrationById);

// Admin Actions
router.put('/:id', checkRegistrationAccess, updateRegistration);
router.put('/:id/status', checkRegistrationAccess, updateRegistrationStatusController);
router.post('/:id/approve', checkRegistrationAccess, approveRegistrationController);

// Divisions Associated with a Registration
// FIX: Changed from checkRegistrationAccess to authenticateToken to avoid ID mismatch error
router.get('/:registration_id/divisions', authenticateToken, fetchDivisionsForRegistration);
router.post('/division', checkRegistrationAccess, addDivisionToRegistration);
router.delete('/division', checkRegistrationAccess, removeDivisionFromRegistration);

// --- User Actions (New) ---
router.post('/join', authenticateToken, registerAsMember);
router.delete('/:id/withdraw', authenticateToken, withdrawRegistration);
router.put('/:id/edit', authenticateToken, editRegistration);

export default router;