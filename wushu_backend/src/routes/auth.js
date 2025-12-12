import express from 'express';
import jwt from 'jsonwebtoken';
import { 
  login, 
  signup, 
  verifyEmail, 
  forgotPassword, 
  resetPassword, 
  getMe 
} from '../controllers/authController.js';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// --- MIDDLEWARE (Exported for other files to use) ---
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Access denied. No token.' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(403).json({ error: 'Invalid token' });
  }
};

export const authorizeRole = (role) => (req, res, next) => {
  if (req.user.role !== role && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Access denied.' });
  }
  next();
};

// --- ROUTES ---
router.post('/signup', signup);
router.post('/login', login);
router.post('/verify-email', verifyEmail);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

router.get('/me', authenticateToken, getMe);

export default router;