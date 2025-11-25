import pool from './db.js';

export const addRegistration = async (data, client) => {
  const {
    tournament_id,
    first_name,
    middle_name,
    last_name,
    school_id,
    birthdate,
    height_feet,
    height_inches,
    weight,
    gender,
    phone,
    emergency_contact_name,
    emergency_contact_phone,
    street,
    city,
    state,
    country,
    zip_code,
    participant_rank,
    email,
    password_hash,
  } = data;

  // Validate gender
  if (gender && !['M', 'F', 'O'].includes(gender)) {
    throw new Error('Invalid gender value. Must be M, F, or O.');
  }

  // Use the provided client (for transactions) or pool
  const db = client || pool;

  // Validate school_id exists
  const schoolCheck = await db.query('SELECT id FROM schools WHERE id = $1', [school_id]);
  if (schoolCheck.rows.length === 0) {
    throw new Error('Invalid school_id. School does not exist.');
  }

  // Default to Tournament 1 (Legacy) if tournament_id is missing
  const targetTournament = tournament_id || 1;

  const result = await db.query(
    `
    INSERT INTO registrations (
      tournament_id,
      first_name, middle_name, last_name, school_id, birthdate,
      height_feet, height_inches, weight, gender, phone,
      emergency_contact_name, emergency_contact_phone,
      street, city, state, country, zip_code, participant_rank,
      email, password_hash, status
    ) VALUES (
      $1, $2, $3, $4, $5, $6,
      $7, $8, $9, $10, $11,
      $12, $13,
      $14, $15, $16, $17, $18, $19,
      $20, $21, 0
    )
    RETURNING *;
  `,
    [
      targetTournament,
      first_name,
      middle_name,
      last_name,
      school_id,
      birthdate,
      height_feet,
      height_inches,
      weight,
      gender,
      phone,
      emergency_contact_name,
      emergency_contact_phone,
      street,
      city,
      state,
      country,
      zip_code,
      participant_rank,
      email,
      password_hash,
    ]
  );

  return result.rows[0];
};

export const getRegistrationByEmail = async (email) => {
  const result = await pool.query('SELECT * FROM registrations WHERE email = $1', [email]);
  return result.rows[0] || null;
};

export const getAllRegistrations = async () => {
  const result = await pool.query('SELECT * FROM registrations ORDER BY created_at DESC');
  return result.rows;
};

export const updateRegistrationStatus = async (id, status) => {
  const result = await pool.query(
    'UPDATE registrations SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
    [status, id]
  );
  if (result.rows.length === 0) {
    throw new Error('Registration not found');
  }
  return result.rows[0];
};

export const getRegistrationById = async (id) => {
  const result = await pool.query('SELECT * FROM registrations WHERE id = $1', [id]);
  return result.rows[0] || null;
};

export const getRegistrationByToken = async (token) => {
  const result = await pool.query(
    `SELECT id, school_name, school_address, school_contact, school_phone 
     FROM schools 
     WHERE registration_token = $1 
     AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP)`,
    [token]
  );
  return result.rows[0] || null;
};