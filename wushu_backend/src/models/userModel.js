import pool from "./db.js";

// Helper to convert empty strings to null (prevents DB errors on Integer/Date columns)
const toNull = (val) => (val === '' || val === undefined || val === 'null' ? null : val);

export const getUserByEmail = async (email) => {
  const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
  return result.rows[0];
};

export const getUserById = async (id) => {
  const result = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
  return result.rows[0];
};

export const createUser = async (userData) => {
  const {
    email, password, role,
    first_name, middle_name, last_name, birthdate, gender,
    height_feet, height_inches, weight, phone,
    emergency_contact_name, emergency_contact_phone,
    street, city, state, country, zip_code
  } = userData;

  const result = await pool.query(
    `INSERT INTO users (
      username, email, password, role,
      first_name, middle_name, last_name, birthdate, gender,
      height_feet, height_inches, weight, phone,
      emergency_contact_name, emergency_contact_phone,
      street, city, state, country, zip_code
    ) VALUES (
      $1, $1, $2, $3, 
      $4, $5, $6, $7, $8, 
      $9, $10, $11, $12, 
      $13, $14, 
      $15, $16, $17, $18, $19
    )
    RETURNING *`,
    [
      email, password, role || 'participant',
      first_name, toNull(middle_name), last_name, toNull(birthdate), gender,
      toNull(height_feet), toNull(height_inches), toNull(weight), phone,
      emergency_contact_name, emergency_contact_phone,
      street, city, state, country, zip_code
    ]
  );
  return result.rows[0];
};

export const updateUser = async (id, data) => {
  const {
    first_name, middle_name, last_name, birthdate, gender,
    height_feet, height_inches, weight, phone,
    emergency_contact_name, emergency_contact_phone,
    street, city, state, country, zip_code
  } = data;

  const result = await pool.query(
    `UPDATE users SET
      first_name = $1, middle_name = $2, last_name = $3, birthdate = $4, gender = $5,
      height_feet = $6, height_inches = $7, weight = $8, phone = $9,
      emergency_contact_name = $10, emergency_contact_phone = $11,
      street = $12, city = $13, state = $14, country = $15, zip_code = $16,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $17
    RETURNING *`,
    [
      first_name, 
      toNull(middle_name), 
      last_name, 
      toNull(birthdate), 
      gender,
      toNull(height_feet), 
      toNull(height_inches), 
      toNull(weight), 
      phone,
      emergency_contact_name, 
      emergency_contact_phone,
      street, city, state, country, zip_code,
      id
    ]
  );
  return result.rows[0];
};