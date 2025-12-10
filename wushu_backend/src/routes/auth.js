import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import pool from '../models/db.js';

const router = express.Router();

// Use a consistent secret. Fallback ensures it works in Dev even if .env fails.
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// Middleware to authenticate token
export const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  try {
    // Verify using the SAME secret used to sign
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // Attach user info to request
    next();
  } catch (err) {
    console.error("Token Verification Failed:", err.message); // Debugging Log
    res.status(403).json({ error: 'Invalid token' });
  }
};

// Middleware to authorize based on role
export const authorizeRole = (role) => (req, res, next) => {
  if (req.user.role !== role && req.user.role !== 'admin') {
    return res.status(403).json({ error: `Access denied. ${role} role required.` });
  }
  next();
};

router.post('/login', async (req, res) => {
  const { username, email, password } = req.body;

  // Validate input
  if (!password) {
    return res.status(400).json({ error: 'Password is required' });
  }
  if (!username && !email) {
    return res.status(400).json({ error: 'Username or email is required' });
  }

  try {
    if (username) {
      // Admin/Judge login
      const userResult = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
      if (userResult.rows.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      const user = userResult.rows[0];
      if (!user.password || user.password.trim() === '') {
        return res.status(500).json({ error: 'User password not set or invalid' });
      }
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const token = jwt.sign(
        { userId: user.id, username: user.username, role: user.role },
        JWT_SECRET,
        { expiresIn: '24h' }
      );
      return res.json({ token, role: user.role });

    } else if (email) {
      // Participant login (Unified Users Table Check)
      // Note: If you have migrated participants to the 'users' table, 
      // you should query 'users' here too, not 'registrations'.
      // Checking 'users' table for email login:
      const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      
      if (userResult.rows.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      
      const user = userResult.rows[0];
      
      if (!user.password || user.password.trim() === '') {
        return res.status(500).json({ error: 'Participant password not set or invalid' });
      }
      
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const token = jwt.sign(
        { userId: user.id, email: user.email, role: 'participant' },
        JWT_SECRET,
        { expiresIn: '24h' }
      );
      return res.json({ token, role: 'participant' });
    }
  } catch (err) {
    console.error('Login error:', err.message);
    console.error('Stack trace:', err.stack);
    res.status(500).json({ error: 'Server error: ' + err.message });
  }
});

router.get('/me', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const result = await pool.query('SELECT id, username, email, role FROM users WHERE id = $1', [decoded.userId]);
    const user = result.rows[0];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ id: user.id, role: user.role });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

export default router;