import pool from "./db.js";

export const addRegistration = async (data) => {
  const {
    first_name, middle_name, last_name, school_id, birthdate,
    height_feet, height_inches, weight, gender, phone,
    emergency_contact_name, emergency_contact_phone,
    street, city, state, country, zip_code,
    participant_rank, email, password_hash
  } = data;

  const result = await pool.query(`
    INSERT INTO registrations (
      first_name, middle_name, last_name, school_id, birthdate,
      height_feet, height_inches, weight, gender, phone,
      emergency_contact_name, emergency_contact_phone,
      street, city, state, country, zip_code, participant_rank,
      email, password_hash, status
    ) VALUES (
      $1, $2, $3, $4, $5,
      $6, $7, $8, $9, $10,
      $11, $12, $13, $14, $15,
      $16, $17, $18, $19, $20, 0
    )
    RETURNING *;
  `, [
    first_name, middle_name, last_name, school_id, birthdate,
    height_feet, height_inches, weight, gender, phone,
    emergency_contact_name, emergency_contact_phone,
    street, city, state, country, zip_code,
    participant_rank, email, password_hash
  ]);

  return result.rows[0];
};

export const getRegistrationByEmail = async (email) => {
  const result = await pool.query("SELECT * FROM registrations WHERE email = $1", [email]);
  return result.rows[0] || null;
};

export const getAllRegistrations = async () => {
  const result = await pool.query("SELECT * FROM registrations ORDER BY created_at DESC");
  return result.rows;
};

export const updateRegistrationStatus = async (id, status) => {
  const result = await pool.query(
    "UPDATE registrations SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *",
    [status, id]
  );
  return result.rows[0];
};

export const getRegistrationById = async (id) => {
  const result = await pool.query("SELECT * FROM registrations WHERE id = $1", [id]);
  return result.rows[0] || null;
};

export const getRegistrationByToken = async (token) => {
  const result = await pool.query(
    "SELECT id, school_name, school_address FROM schools WHERE registration_token = $1",
    [token]
  );
  return result.rows[0] || null;
};