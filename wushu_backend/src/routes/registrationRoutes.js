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
} from '../controllers/registrationController.js';
import { 
  // ... existing imports
  approveRegistrationController // <--- Add this import
} from '../controllers/registrationController.js';

const router = express.Router();

// Middleware to check if the user can access the registration
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
    // For GET /registrations/:registration_id/divisions
    if (req.method === 'GET' && req.url.match(/^\/[0-9]+\/divisions$/)) {
      const registrationId = parseInt(req.url.split('/')[1], 10);
      if (registrationId === req.user.userId) {
        return next();
      }
      return res.status(403).json({ error: 'Forbidden: You can only access your own data' });
    }
    // For PUT /registrations/:id
    if (req.method === 'PUT' && req.url.match(/^\/[0-9]+$/)) {
      const registrationId = parseInt(req.url.split('/')[1], 10);
      if (registrationId === req.user.userId) {
        return next();
      }
      return res.status(403).json({ error: 'Forbidden: You can only update your own data' });
    }
  }

  // Default to denying access
  return res.status(403).json({ error: 'Forbidden: Insufficient permissions' });
};

// Public Routes for Self-Registration
router.post('/', createRegistration);
router.get('/register/validate-token', (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).json({ error: 'Missing token parameter' });
  }
  req.params = { token };
  validateRegistrationToken(req, res);
});

// Protected Routes (apply access control)
router.get('/', checkRegistrationAccess, fetchAllRegistrations);
router.get('/email/:email', checkRegistrationAccess, fetchRegistrationByEmail);
router.get('/:id', checkRegistrationAccess, fetchRegistrationById);
router.put('/:id', checkRegistrationAccess, updateRegistration);
router.put('/:id/status', checkRegistrationAccess, updateRegistrationStatusController);

// Divisions Associated with a Registration
router.get('/:registration_id/divisions', checkRegistrationAccess, fetchDivisionsForRegistration);
router.post('/division', checkRegistrationAccess, addDivisionToRegistration);
router.delete('/division', checkRegistrationAccess, removeDivisionFromRegistration);
router.post('/:id/approve', checkRegistrationAccess, approveRegistrationController);

export default router;