import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import pool from '../models/db.js';
import { sendEmail } from '../utils/email.js';

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';
const FRONTEND_URL = process.env.FRONTEND_ORIGIN || 'http://localhost:5173';

// 1. SIGN UP (Create Account)
export const signup = async (req, res) => {
  const { 
    email, password, first_name, last_name,
    // New Fields
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

    // Insert new user with all profile fields
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

    // Send Verification Email
    const verifyLink = `${FRONTEND_URL}/verify-email?token=${verificationToken}`;
    await sendEmail({
      to: email,
      subject: 'Verify your Wushu Account',
      text: `Welcome ${first_name}! Click here to verify your account: ${verifyLink}`
    });

    res.status(201).json({ 
      message: 'Account created! Please check your email to verify your account.',
      userId: newUser.id 
    });

  } catch (err) {
    if (err.code === '23505') { // Unique constraint violation
      return res.status(409).json({ error: 'Email already registered. Please log in.' });
    }
    console.error('Signup Error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. VERIFY EMAIL
export const verifyEmail = async (req, res) => {
  const { token } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users SET is_verified = TRUE, verification_token = NULL 
       WHERE verification_token = $1 RETURNING id`,
      [token]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired verification token.' });
    }

    res.json({ message: 'Email verified successfully! You can now log in.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 3. LOGIN
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

    // Check Verification
    if (user.role === 'participant' && !user.is_verified) {
       // Optional: Allow login but warn, or block. Blocking for security:
       // return res.status(403).json({ error: 'Please verify your email address before logging in.' });
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

// 4. FORGOT PASSWORD
export const forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const userResult = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      return res.json({ message: 'If an account exists, a reset link has been sent.' });
    }

    const resetToken = uuidv4();
    const expires = new Date(Date.now() + 3600000); // 1 hour

    await pool.query(
      `UPDATE users SET reset_password_token = $1, reset_password_expires = $2 WHERE email = $3`,
      [resetToken, expires, email]
    );

    const resetLink = `${FRONTEND_URL}/reset-password?token=${resetToken}`;
    await sendEmail({
      to: email,
      subject: 'Password Reset Request',
      text: `Click here to reset your password: ${resetLink}`
    });

    res.json({ message: 'If an account exists, a reset link has been sent.' });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// 5. RESET PASSWORD
export const resetPassword = async (req, res) => {
  const { token, newPassword } = req.body;

  try {
    const userResult = await pool.query(
      `SELECT id FROM users 
       WHERE reset_password_token = $1 AND reset_password_expires > CURRENT_TIMESTAMP`,
      [token]
    );

    if (userResult.rows.length === 0) {
      return res.status(400).json({ error: 'Token is invalid or expired.' });
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(newPassword, saltRounds);

    await pool.query(
      `UPDATE users SET password = $1, reset_password_token = NULL, reset_password_expires = NULL WHERE id = $2`,
      [passwordHash, userResult.rows[0].id]
    );

    res.json({ message: 'Password has been reset successfully. Please log in.' });

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