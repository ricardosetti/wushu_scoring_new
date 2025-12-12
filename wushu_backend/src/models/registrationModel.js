import pool from './db.js';

export const addRegistration = async (data, client) => {
  const {
    user_id,
    tournament_id,
    school_id,
    participant_rank,
    height_feet, height_inches, weight // <--- New fields
  } = data;

  const db = client || pool;

  const existing = await db.query(
    "SELECT id FROM registrations WHERE user_id = $1 AND tournament_id = $2",
    [user_id, tournament_id]
  );

  if (existing.rows.length > 0) {
    throw new Error("User is already registered for this tournament.");
  }

  const result = await db.query(
    `
    INSERT INTO registrations (
      user_id, tournament_id, school_id, participant_rank, 
      height_feet, height_inches, weight,
      status, created_at
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, 0, CURRENT_TIMESTAMP)
    RETURNING *;
    `,
    [
      user_id, tournament_id, school_id, participant_rank,
      height_feet || null, height_inches || null, weight || null
    ]
  );

  return result.rows[0];
};

// 2. Get All Registrations (For Admin Dashboard)
export const getAllRegistrations = async () => {
  const result = await pool.query(`
    SELECT r.*, 
           u.first_name, u.last_name, u.email, u.birthdate, u.gender,
           t.tournament_title, 
           s.school_name
    FROM registrations r
    JOIN users u ON r.user_id = u.id
    LEFT JOIN tournaments t ON r.tournament_id = t.tournament_id
    LEFT JOIN schools s ON r.school_id = s.id
    ORDER BY r.created_at DESC
  `);
  return result.rows;
};

// 3. Get Registration by Email (Legacy support)
export const getRegistrationByEmail = async (email) => {
  const result = await pool.query(`
    SELECT r.*,
           u.first_name, u.last_name, u.email
    FROM registrations r
    JOIN users u ON r.user_id = u.id
    WHERE u.email = $1
    ORDER BY r.created_at DESC
    LIMIT 1
  `, [email]);
  
  return result.rows[0] || null;
};

// 4. Get Registration By ID
export const getRegistrationById = async (id) => {
  const result = await pool.query(`
    SELECT r.*, 
           u.first_name, u.last_name, u.email, u.birthdate,
           s.school_name
    FROM registrations r
    JOIN users u ON r.user_id = u.id
    LEFT JOIN schools s ON r.school_id = s.id
    WHERE r.id = $1
  `, [id]);
  return result.rows[0] || null;
};

// 5. Update Status
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

// 6. Validate School Token
export const getRegistrationByToken = async (token) => {
  const result = await pool.query(
    `SELECT s.id, s.school_name, s.school_address, s.school_contact, s.school_phone 
     FROM schools s
     JOIN tournament_schools ts ON s.id = ts.school_id
     JOIN tournaments t ON ts.tournament_id = t.tournament_id
     WHERE s.registration_token = $1 
     AND t.is_active = TRUE
     AND (s.expires_at IS NULL OR s.expires_at > CURRENT_TIMESTAMP)`,
    [token]
  );
  return result.rows[0] || null;
};

// 7. NEW: Get Registrations By User (Needed for Profile Page)
// This was missing and causing your Profile to crash/blank out
export const getRegistrationsByUser = async (userId) => {
  const result = await pool.query(`
    SELECT r.*, 
           t.tournament_title, t.tournament_start_date, t.tournament_city, t.is_active,
           s.school_name,
           tr.total_score, tr.rank, tr.score_breakdown
    FROM registrations r
    JOIN tournaments t ON r.tournament_id = t.tournament_id
    LEFT JOIN schools s ON r.school_id = s.id
    LEFT JOIN tournament_results tr ON r.participant_id = tr.participant_id
    WHERE r.user_id = $1
    ORDER BY t.tournament_start_date DESC
  `, [userId]);
  return result.rows;
};

export const deleteRegistration = async (id, userId) => {
  // Ensure the user owns the registration before deleting
  const result = await pool.query(
    'DELETE FROM registrations WHERE id = $1 AND user_id = $2 RETURNING *',
    [id, userId]
  );
  return result.rows[0] || null;
};

// NEW: Update Registration (Edit Details)
export const updateRegistrationDetails = async (id, userId, data) => {
  const { school_id, participant_rank, height_feet, height_inches, weight } = data;
  
  const result = await pool.query(`
    UPDATE registrations 
    SET school_id = $1, participant_rank = $2, 
        height_feet = $3, height_inches = $4, weight = $5,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = $6 AND user_id = $7
    RETURNING *
  `, [school_id, participant_rank, height_feet, height_inches, weight, id, userId]);
  
  return result.rows[0] || null;
};