import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import pool from '../models/db.js';

// Simple mock for email until you add a real provider
const sendEmail = async ({ to, subject, text }) => {
  console.log("================ EMAIL MOCK ================");
  console.log(`To: ${to}`);
  console.log(`Subject: ${subject}`);
  console.log(`Link: ${text}`);
  console.log("============================================");
};

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';
const FRONTEND_URL = process.env.FRONTEND_ORIGIN || 'http://localhost:5173';

// 1. SIGN UP
export const signup = async (req, res) => {
  const { 
    email, password, first_name, last_name,
    birthdate, gender, phone,
    street, city, state, country, zip_code
  } = req.body;

  if (!email || !password || !first_name || !last_name) {
    return res.status(400).json({ error: 'Name, Email, and Password are required.' });
  }

  try {
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    const verificationToken = uuidv4();

    const result = await pool.query(
      `INSERT INTO users (
        username, email, password, role, 
        first_name, last_name, 
        birthdate, gender, phone,
        street, city, state, country, zip_code,
        is_verified, verification_token, created_at
      ) VALUES (
        $1, $1, $2, 'participant', 
        $3, $4, 
        $5, $6, $7,
        $8, $9, $10, $11, $12,
        FALSE, $13, CURRENT_TIMESTAMP
      )
      RETURNING id, email, first_name`,
      [
        email, passwordHash, 
        first_name, last_name, 
        birthdate || null, gender || null, phone || null,
        street || null, city || null, state || null, country || null, zip_code || null,
        verificationToken
      ]
    );

    const newUser = result.rows[0];

    const verifyLink = `${FRONTEND_URL}/verify-email?token=${verificationToken}`;
    await sendEmail({
      to: email,
      subject: 'Verify your Wushu Account',
      text: verifyLink
    });

    res.status(201).json({ 
      message: 'Account created! Please check your email to verify your account.',
      userId: newUser.id 
    });

  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Email already registered. Please log in.' });
    }
    console.error('Signup Error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. LOGIN (Updated Logic)
export const login = async (req, res) => {
  const { username, email, password } = req.body;
  const identifier = username || email;

  if (!identifier || !password) return res.status(400).json({ error: 'Missing credentials' });

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE username = $1 OR email = $1',
      [identifier]
    );
    const user = result.rows[0];

    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(401).json({ error: 'Invalid credentials' });

    // CRITICAL: Block login if not verified (Only for participants)
    if (user.role === 'participant' && !user.is_verified) {
       return res.status(403).json({ error: 'Please verify your email address before logging in. Check your inbox.' });
    }

    const token = jwt.sign(
      { userId: user.id, role: user.role, email: user.email },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({ token, role: user.role, userId: user.id });

  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// 3. VERIFY EMAIL
export const verifyEmail = async (req, res) => {
  const { token } = req.body;
  try {
    const result = await pool.query(
      `UPDATE users SET is_verified = TRUE, verification_token = NULL 
       WHERE verification_token = $1 RETURNING id`,
      [token]
    );
    if (result.rows.length === 0) return res.status(400).json({ error: 'Invalid or expired token.' });
    res.json({ message: 'Verified!' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 4. FORGOT PASSWORD
export const forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (user.rows.length > 0) {
      const resetToken = uuidv4();
      await pool.query(
        `UPDATE users SET reset_password_token = $1, reset_password_expires = (CURRENT_TIMESTAMP + interval '1 hour') WHERE email = $2`,
        [resetToken, email]
      );
      const link = `${FRONTEND_URL}/reset-password?token=${resetToken}`;
      await sendEmail({ to: email, subject: 'Password Reset', text: link });
    }
    res.json({ message: 'If account exists, email sent.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 5. RESET PASSWORD
export const resetPassword = async (req, res) => {
  const { token, newPassword } = req.body;
  try {
    const result = await pool.query(
      `SELECT id FROM users WHERE reset_password_token = $1 AND reset_password_expires > CURRENT_TIMESTAMP`,
      [token]
    );
    if (result.rows.length === 0) return res.status(400).json({ error: 'Invalid token.' });

    const hash = await bcrypt.hash(newPassword, 10);
    await pool.query(
      `UPDATE users SET password = $1, reset_password_token = NULL, reset_password_expires = NULL WHERE id = $2`,
      [hash, result.rows[0].id]
    );
    res.json({ message: 'Password reset.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 6. GET ME
export const getMe = async (req, res) => {
  try {
    const result = await pool.query('SELECT id, email, role, first_name, last_name, is_verified FROM users WHERE id = $1', [req.user.userId]);
    if (!result.rows.length) return res.status(404).json({ error: 'User not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};