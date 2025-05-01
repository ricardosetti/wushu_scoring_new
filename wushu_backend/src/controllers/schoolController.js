import pool from "../models/db.js";
import { v4 as uuidv4 } from 'uuid';
import QRCode from 'qrcode';

export const fetchSchools = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM schools ORDER BY school_name ASC");
    const schools = result.rows.map(school => ({
      ...school,
      school_logo: school.school_logo ? `data:image/jpeg;base64,${Buffer.from(school.school_logo).toString('base64')}` : null,
      school_qr_code: school.registration_qr_code ? `data:image/png;base64,${Buffer.from(school.registration_qr_code).toString('base64')}` : null,
    }));
    res.json(schools);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createSchool = async (req, res) => {
  const { school_name, school_address, school_contact, school_phone } = req.body;
  const school_logo = req.file ? req.file.buffer : null;
  if (!school_name) {
    return res.status(400).json({ error: "School name is required" });
  }
  try {
    const result = await pool.query(
      "INSERT INTO schools (school_name, school_address, school_contact, school_phone, school_logo) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [school_name, school_address || null, school_contact || null, school_phone || null, school_logo]
    );
    const newSchool = result.rows[0];
    newSchool.school_logo = newSchool.school_logo ? `data:image/jpeg;base64,${Buffer.from(newSchool.school_logo).toString('base64')}` : null;
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
    return res.status(400).json({ error: "School name is required" });
  }
  try {
    const result = await pool.query(
      "SELECT school_logo FROM schools WHERE id = $1",
      [id]
    );
    const existingLogo = result.rows[0]?.school_logo;
    const updateLogo = school_logo !== undefined ? school_logo : existingLogo;
    const resultUpdate = await pool.query(
      "UPDATE schools SET school_name = $1, school_address = $2, school_contact = $3, school_phone = $4, school_logo = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *",
      [school_name, school_address || null, school_contact || null, school_phone || null, updateLogo, id]
    );
    if (resultUpdate.rows.length === 0) {
      return res.status(404).json({ error: "School not found" });
    }
    const updatedSchool = resultUpdate.rows[0];
    updatedSchool.school_logo = updatedSchool.school_logo ? `data:image/jpeg;base64,${Buffer.from(updatedSchool.school_logo).toString('base64')}` : null;
    res.json(updatedSchool);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const deleteSchool = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("DELETE FROM schools WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "School not found" });
    }
    res.json({ message: "School deleted successfully", deleted: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchSchoolById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM schools WHERE id = $1", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "School not found" });
    }
    const school = result.rows[0];
    school.school_logo = school.school_logo ? `data:image/jpeg;base64,${Buffer.from(school.school_logo).toString('base64')}` : null;
    school.school_qr_code = school.registration_qr_code ? `data:image/png;base64,${Buffer.from(school.registration_qr_code).toString('base64')}` : null;
    res.json(school);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const generateRegistrationLink = async (req, res) => {
  const { schoolId } = req.params;
  const baseUrl = process.env.REGISTRATION_BASE_URL || "https://yourdomain.com/register"; // ← customize this!

  try {
    const token = uuidv4();
    const registrationLink = `${baseUrl}/${token}`;
    const qrCodeDataUrl = await QRCode.toDataURL(registrationLink);

    const result = await pool.query(`
      UPDATE schools
      SET registration_token = $1, registration_link = $2, registration_qr_code = $3, updated_at = CURRENT_TIMESTAMP
      WHERE id = $4
      RETURNING *;
    `, [token, registrationLink, qrCodeDataUrl.split(',')[1], schoolId]);

    res.json({
      message: "Registration link and QR Code generated successfully",
      registration_link: registrationLink,
      qr_code_data_url: qrCodeDataUrl
    });
  } catch (error) {
    console.error("Error generating registration link:", error);
    res.status(500).json({ error: error.message });
  }
};
