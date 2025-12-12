import { getUserById, updateUser, createUser } from "../models/userModel.js";
import { getRegistrationsByUser } from "../models/registrationModel.js";
import pool from "../models/db.js";
import bcrypt from 'bcrypt';

// --- Existing Public/User Profile Functions ---

export const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const [user, registrations] = await Promise.all([
      getUserById(userId),
      getRegistrationsByUser(userId)
    ]);
    if (!user) return res.status(404).json({ error: "User not found" });
    delete user.password;
    res.json({ user, registrations });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updatedUser = await updateUser(userId, req.body);
    delete updatedUser.password;
    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// --- Admin User Management Functions ---

export const getAllUsers = async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM users ORDER BY created_at DESC"
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const adminCreateUser = async (req, res) => {
  const { 
    email, password, role, first_name, last_name,
    birthdate, gender, phone,
    street, city, state, country, zip_code
  } = req.body;
  
  if (!email || !password || !first_name || !last_name) {
    return res.status(400).json({ error: "Email, Password, First Name, Last Name are required" });
  }

  try {
    const existing = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
    if (existing.rows.length > 0) return res.status(409).json({ error: "Email already exists" });

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Insert with all fields
    const result = await pool.query(
      `INSERT INTO users (
        username, email, password, role, 
        first_name, last_name, 
        birthdate, gender, phone,
        street, city, state, country, zip_code,
        is_verified, created_at
      ) VALUES (
        $1, $1, $2, $3, 
        $4, $5, 
        $6, $7, $8,
        $9, $10, $11, $12, $13,
        TRUE, CURRENT_TIMESTAMP
      )
      RETURNING *`,
      [
        email, passwordHash, role || 'participant', 
        first_name, last_name,
        birthdate || null, gender || null, phone || null,
        street || null, city || null, state || null, country || null, zip_code || null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const adminUpdateUser = async (req, res) => {
  const { id } = req.params;
  const { 
    first_name, last_name, email, role, is_verified,
    birthdate, gender, phone,
    street, city, state, country, zip_code
  } = req.body;

  try {
    // Update all fields
    const result = await pool.query(
      `UPDATE users SET 
        first_name = $1, last_name = $2, email = $3, username = $3, 
        role = $4, is_verified = $5,
        birthdate = $6, gender = $7, phone = $8,
        street = $9, city = $10, state = $11, country = $12, zip_code = $13,
        updated_at = CURRENT_TIMESTAMP
       WHERE id = $14 
       RETURNING *`,
      [
        first_name, last_name, email, role, is_verified,
        birthdate || null, gender || null, phone || null,
        street || null, city || null, state || null, country || null, zip_code || null,
        id
      ]
    );
    
    if (result.rows.length === 0) return res.status(404).json({ error: "User not found" });
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const adminDeleteUser = async (req, res) => {
  const { id } = req.params;
  try {
    if (parseInt(id) === req.user.userId) {
       return res.status(400).json({ error: "Cannot delete your own admin account." });
    }
    const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: "User not found" });
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const adminResetPassword = async (req, res) => {
  const { id } = req.params;
  const { newPassword } = req.body;

  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({ error: "Password must be at least 6 chars" });
  }

  try {
    const saltRounds = 10;
    const hash = await bcrypt.hash(newPassword, saltRounds);

    await pool.query("UPDATE users SET password = $1 WHERE id = $2", [hash, id]);
    res.json({ message: "Password updated successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};