import pool from '../models/db.js';
import { v4 as uuidv4 } from 'uuid';
import QRCode from 'qrcode';
import dotenv from 'dotenv';

dotenv.config();

// Helper to format images for frontend
const formatImage = (buffer, type = 'jpeg') => {
  if (!buffer) return null;
  return `data:image/${type};base64,${Buffer.from(buffer).toString('base64')}`;
};

export const fetchSchools = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM schools ORDER BY school_name ASC');
    const schools = result.rows.map(school => ({
      ...school,
      school_logo: formatImage(school.school_logo, 'jpeg'),
      registration_qr_code: formatImage(school.registration_qr_code, 'png'),
    }));
    res.json(schools);
  } catch (err) {
    console.error('Error fetching schools:', err);
    res.status(500).json({ error: 'Failed to fetch schools' });
  }
};

export const createSchool = async (req, res) => {
  const { school_name, school_address, school_contact, school_phone } = req.body;
  const school_logo = req.file ? req.file.buffer : null;

  if (!school_name) return res.status(400).json({ error: 'School name is required' });

  try {
    const result = await pool.query(
      'INSERT INTO schools (school_name, school_address, school_contact, school_phone, school_logo) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [school_name, school_address || null, school_contact || null, school_phone || null, school_logo]
    );
    const newSchool = result.rows[0];
    newSchool.school_logo = formatImage(newSchool.school_logo);
    res.status(201).json(newSchool);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateSchool = async (req, res) => {
  const { id } = req.params;
  const { school_name, school_address, school_contact, school_phone } = req.body;
  const school_logo = req.file ? req.file.buffer : undefined;
  if (!school_name) {
    return res.status(400).json({ error: 'School name is required' });
  }
  try {
    const result = await pool.query('SELECT school_logo FROM schools WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'School not found' });
    }
    const existingLogo = result.rows[0]?.school_logo;
    const updateLogo = school_logo !== undefined ? school_logo : existingLogo;
    const resultUpdate = await pool.query(
      'UPDATE schools SET school_name = $1, school_address = $2, school_contact = $3, school_phone = $4, school_logo = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *',
      [school_name, school_address || null, school_contact || null, school_phone || null, updateLogo, id]
    );
    const updatedSchool = resultUpdate.rows[0];
    updatedSchool.school_logo = updatedSchool.school_logo ? `data:image/jpeg;base64,${Buffer.from(updatedSchool.school_logo).toString('base64')}` : null;
    updatedSchool.registration_qr_code = updatedSchool.registration_qr_code ? `data:image/png;base64,${Buffer.from(updatedSchool.registration_qr_code).toString('base64')}` : null;
    res.json(updatedSchool);
  } catch (err) {
    console.error('Error updating school:', err);
    res.status(500).json({ error: 'Failed to update school: ' + err.message });
  }
};

export const deleteSchool = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM schools WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'School not found' });
    }
    res.json({ message: 'School deleted successfully', deleted: result.rows[0] });
  } catch (err) {
    console.error('Error deleting school:', err);
    res.status(500).json({ error: 'Failed to delete school: ' + err.message });
  }
};

export const fetchSchoolById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM schools WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'School not found' });
    }
    const school = result.rows[0];
    school.school_logo = school.school_logo ? `data:image/jpeg;base64,${Buffer.from(school.school_logo).toString('base64')}` : null;
    school.registration_qr_code = school.registration_qr_code ? `data:image/png;base64,${Buffer.from(school.registration_qr_code).toString('base64')}` : null;
    res.json(school);
  } catch (err) {
    console.error('Error fetching school by ID:', err);
    res.status(500).json({ error: 'Failed to fetch school: ' + err.message });
  }
};

export const generateRegistrationLink = async (req, res) => {
  const { schoolId } = req.params;
  
  // 1. Get the Frontend URL from ENV, or default to localhost:5173
  const frontendUrl = process.env.FRONTEND_ORIGIN || 'http://localhost:5173';

  try {
    const schoolCheck = await pool.query('SELECT id FROM schools WHERE id = $1', [schoolId]);
    if (schoolCheck.rows.length === 0) {
      return res.status(404).json({ error: 'School not found' });
    }

    const token = uuidv4();
    
    // 2. Generate Link pointing to FRONTEND
    const registrationLink = `${frontendUrl}/register?token=${token}&school_id=${schoolId}`;
    
    // 3. Generate QR Code
    const qrCodeData = await QRCode.toDataURL(registrationLink, { width: 300, margin: 2 });
    const qrBuffer = Buffer.from(qrCodeData.split(',')[1], 'base64');

    // 4. Set expiration (e.g., 90 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 90);

    const result = await pool.query(
      `UPDATE schools
       SET registration_token = $1, registration_link = $2, registration_qr_code = $3, expires_at = $4, updated_at = CURRENT_TIMESTAMP
       WHERE id = $5
       RETURNING *`,
      [token, registrationLink, qrBuffer, expiresAt, schoolId]
    );

    const updatedSchool = result.rows[0];
    updatedSchool.registration_qr_code = formatImage(updatedSchool.registration_qr_code, 'png');
    updatedSchool.school_logo = formatImage(updatedSchool.school_logo, 'jpeg');

    res.json(updatedSchool);
  } catch (error) {
    console.error('Error generating link:', error);
    res.status(500).json({ error: error.message });
  }
};