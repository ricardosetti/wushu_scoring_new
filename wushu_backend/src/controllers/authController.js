import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../models/db.js';

export const login = async (req, res) => {
  const { username, email, password } = req.body;

  // 1. Validate Input
  if (!password) {
    return res.status(400).json({ error: 'Password is required' });
  }
  
  // Allow login via Username (Admins/Judges) OR Email (Participants)
  const identifier = username || email;
  if (!identifier) {
    return res.status(400).json({ error: 'Username or email is required' });
  }

  try {
    // 2. Query the USERS table (Single Source of Truth)
    // We check if the identifier matches either the 'username' column or the 'email' column
    const result = await pool.query(
      'SELECT * FROM users WHERE username = $1 OR email = $1',
      [identifier]
    );

    const user = result.rows[0];

    // 3. User Not Found
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // 4. Verify Password
    // Note: Ensure your 'users' table password column is named 'password'
    if (!user.password || user.password.trim() === '') {
      return res.status(500).json({ error: 'Account password not set. Please contact support.' });
    }

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // 5. Generate Token
    if (!process.env.JWT_SECRET) {
      throw new Error('JWT_SECRET is not defined in environment variables');
    }

    const token = jwt.sign(
      { 
        userId: user.id, 
        username: user.username, 
        email: user.email,
        role: user.role 
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // 6. Return Token & Role
    return res.json({ token, role: user.role, userId: user.id });

  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ error: 'Server error: ' + err.message });
  }
};

export const getMe = async (req, res) => {
  try {
    // req.user is populated by the authenticateToken middleware
    const userId = req.user.userId;

    const result = await pool.query('SELECT id, username, email, role FROM users WHERE id = $1', [userId]);
    const user = result.rows[0];

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (err) {
    console.error('Get Me error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};