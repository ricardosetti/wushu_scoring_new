import pool from './db.js';

// 1. Add Registration (Links an existing User to a Tournament)
export const addRegistration = async (data, client) => {
  const {
    user_id,          // Link to the Users table (Identity)
    tournament_id,    // Link to the Tournaments table (Event)
    school_id,        // School for this specific event
    participant_rank  // Rank can change over time, so we store it per registration
  } = data;

  // Use the provided client (for transactions) or the global pool
  const db = client || pool;

  // Check if this user is already registered for this specific tournament
  const existing = await db.query(
    "SELECT id FROM registrations WHERE user_id = $1 AND tournament_id = $2",
    [user_id, tournament_id]
  );

  if (existing.rows.length > 0) {
    throw new Error("User is already registered for this tournament.");
  }

  // Insert the registration record (Status 0 = Pending)
  const result = await db.query(
    `
    INSERT INTO registrations (
      user_id, tournament_id, school_id, participant_rank, status, created_at
    ) VALUES ($1, $2, $3, $4, 0, CURRENT_TIMESTAMP)
    RETURNING *;
    `,
    [user_id, tournament_id, school_id, participant_rank]
  );

  return result.rows[0];
};

// 2. Get All Registrations (For Admin Dashboard)
// We JOIN the 'users' table so the Admin sees the actual names, not just IDs.
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

// 3. Get Registration by Email (For Profile View)
// This reconstructs the full profile object by joining Users + Registrations
export const getRegistrationByEmail = async (email) => {
  const result = await pool.query(`
    SELECT r.*,
           u.first_name, u.middle_name, u.last_name, u.email, u.birthdate, 
           u.height_feet, u.height_inches, u.weight, u.gender, u.phone,
           u.emergency_contact_name, u.emergency_contact_phone,
           u.street, u.city, u.state, u.country, u.zip_code,
           s.school_name
    FROM registrations r
    JOIN users u ON r.user_id = u.id
    LEFT JOIN schools s ON r.school_id = s.id
    WHERE u.email = $1
    ORDER BY r.created_at DESC
    LIMIT 1
  `, [email]);
  
  return result.rows[0] || null;
};

// 4. Get Registration By ID (Admin Detail View)
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

// 5. Update Status (Approve/Reject)
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
// Ensures the school is allowed in the ACTIVE tournament
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

// NEW: Get all registrations for a specific user
export const getRegistrationsByUser = async (userId) => {
  const result = await pool.query(`
    SELECT r.*, 
           t.tournament_title, t.tournament_start_date, t.tournament_city, t.is_active,
           s.school_name,
           -- Fetch Results Data using the new link
           tr.total_score, tr.rank, tr.score_breakdown
    FROM registrations r
    JOIN tournaments t ON r.tournament_id = t.tournament_id
    LEFT JOIN schools s ON r.school_id = s.id
    -- Join Results via the participant_id stored in registration
    LEFT JOIN tournament_results tr ON r.participant_id = tr.participant_id
    WHERE r.user_id = $1
    ORDER BY t.tournament_start_date DESC
  `, [userId]);
  return result.rows;
};