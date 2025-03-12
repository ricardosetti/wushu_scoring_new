import pool from "../models/db.js";

export const fetchSchools = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM schools ORDER BY school_name ASC");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createSchool = async (req, res) => {
  const { school_name, school_address, school_contact, school_phone } = req.body;
  const school_logo = req.file ? req.file.buffer : null; // Assuming multer for file upload
  if (!school_name) {
    return res.status(400).json({ error: "School name is required" });
  }
  try {
    const result = await pool.query(
      "INSERT INTO schools (school_name, school_address, school_contact, school_phone, school_logo) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [school_name, school_address || null, school_contact || null, school_phone || null, school_logo]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateSchool = async (req, res) => {
  const { id } = req.params;
  const { school_name, school_address, school_contact, school_phone } = req.body;
  const school_logo = req.file ? req.file.buffer : undefined; // Optional update
  if (!school_name) {
    return res.status(400).json({ error: "School name is required" });
  }
  try {
    const result = await pool.query(
      "UPDATE schools SET school_name = $1, school_address = $2, school_contact = $3, school_phone = $4, school_logo = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *",
      [school_name, school_address || null, school_contact || null, school_phone || null, school_logo, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "School not found" });
    }
    res.json(result.rows[0]);
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
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};