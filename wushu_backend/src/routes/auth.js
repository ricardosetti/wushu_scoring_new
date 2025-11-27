import express from 'express';
import jwt from 'jsonwebtoken';
import { login, getMe } from '../controllers/authController.js';

const router = express.Router();

// --- Middleware ---

// Middleware to authenticate token
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Attach user info to request
    next();
  } catch (err) {
    res.status(403).json({ error: 'Invalid token' });
  }
};

// Middleware to authorize based on role
export const authorizeRole = (role) => (req, res, next) => {
  // Allow admins to access everything
  if (req.user.role === 'admin') {
    return next();
  }
  
  if (req.user.role !== role) {
    return res.status(403).json({ error: `Access denied. ${role} role required.` });
  }
  next();
};

// --- Routes ---

router.post('/login', login);
router.get('/me', authenticateToken, getMe);

export default router;