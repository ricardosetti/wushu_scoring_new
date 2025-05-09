import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import pool from '../models/db.js';

const router = express.Router();

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
  if (req.user.role !== role) {
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
      if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET is not defined');
      }
      const token = jwt.sign(
        { userId: user.id, username: user.username, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
      );
      return res.json({ token, role: user.role });
    } else if (email) {
      // Participant login
      const registrationResult = await pool.query('SELECT * FROM registrations WHERE email = $1', [email]);
      if (registrationResult.rows.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      const registration = registrationResult.rows[0];
      if (!registration.password_hash || registration.password_hash.trim() === '') {
        return res.status(500).json({ error: 'Participant password not set or invalid' });
      }
      const validPassword = await bcrypt.compare(password, registration.password_hash);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      if (!process.env.JWT_SECRET) {
        throw new Error('JWT_SECRET is not defined');
      }
      const token = jwt.sign(
        { userId: registration.id, email: registration.email, role: 'participant' },
        process.env.JWT_SECRET,
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
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    let user;
    if (decoded.role === 'participant') {
      const result = await pool.query('SELECT id, email, role FROM registrations WHERE id = $1', [decoded.userId]);
      user = result.rows[0];
    } else {
      const result = await pool.query('SELECT id, username, role FROM users WHERE id = $1', [decoded.userId]);
      user = result.rows[0];
    }

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ id: user.id, role: user.role });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

export default router;