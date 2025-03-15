import pool from "./db.js";

export const getAllParticipants = async () => {
  const result = await pool.query("SELECT * FROM participants ORDER BY name ASC");
  return result.rows;
};

export const addParticipant = async (
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
  participant_rank
) => {
  const result = await pool.query(
    `INSERT INTO participants (
      first_name, middle_name, last_name, school_id, birthdate, height_feet, height_inches, weight, gender, phone,
      emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, participant_rank
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) RETURNING *`,
    [
      first_name || null,
      middle_name || null,
      last_name || null,
      school_id || null,
      birthdate || null,
      height_feet || null,
      height_inches || null,
      weight || null,
      gender || null,
      phone || null,
      emergency_contact_name || null,
      emergency_contact_phone || null,
      street || null,
      city || null,
      state || null,
      country || null,
      zip_code || null,
      participant_rank || null,
    ]
  );
  return result.rows[0];
};

export const getParticipants = async () => {
  const result = await pool.query(
    `SELECT p.id, p.first_name, p.middle_name, p.last_name, s.school_name, s.id AS school_id, 
      p.birthdate, p.height_feet, p.height_inches, p.weight, p.gender, p.phone, 
      p.emergency_contact_name, p.emergency_contact_phone, p.street, p.city, p.state, p.country, p.zip_code, p.participant_rank,
      COALESCE(
        (SELECT ARRAY_AGG(d.division_name) 
         FROM tournament_participants tp 
         JOIN divisions d ON tp.division_id = d.id 
         WHERE tp.participant_id = p.id), 
        ARRAY[]::VARCHAR[]
      ) AS divisions
      FROM participants p 
      LEFT JOIN schools s ON p.school_id = s.id 
      ORDER BY p.last_name ASC, p.first_name ASC`
  );
  return result.rows;
};

export const getParticipantById = async (id) => {
  const result = await pool.query(
    `SELECT p.id, p.first_name, p.middle_name, p.last_name, s.school_name, s.id AS school_id, 
      p.birthdate, p.height_feet, p.height_inches, p.weight, p.gender, p.phone, 
      p.emergency_contact_name, p.emergency_contact_phone, p.street, p.city, p.state, p.country, p.zip_code, p.participant_rank,
      COALESCE(
        (SELECT ARRAY_AGG(d.division_name) 
         FROM tournament_participants tp 
         JOIN divisions d ON tp.division_id = d.id 
         WHERE tp.participant_id = p.id), 
        ARRAY[]::VARCHAR[]
      ) AS divisions
      FROM participants p 
      LEFT JOIN schools s ON p.school_id = s.id 
      WHERE p.id = $1`,
    [id]
  );
  return result.rows[0];
};

export const updateParticipant = async (
  id,
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
  participant_rank
) => {
  const result = await pool.query(
    `UPDATE participants 
     SET first_name = $1, middle_name = $2, last_name = $3, school_id = $4, birthdate = $5, height_feet = $6, 
         height_inches = $7, weight = $8, gender = $9, phone = $10, emergency_contact_name = $11, 
         emergency_contact_phone = $12, street = $13, city = $14, state = $15, country = $16, zip_code = $17, 
         participant_rank = $18, updated_at = CURRENT_TIMESTAMP 
     WHERE id = $19 RETURNING *`,
    [
      first_name || null,
      middle_name || null,
      last_name || null,
      school_id || null,
      birthdate || null,
      height_feet || null,
      height_inches || null,
      weight || null,
      gender || null,
      phone || null,
      emergency_contact_name || null,
      emergency_contact_phone || null,
      street || null,
      city || null,
      state || null,
      country || null,
      zip_code || null,
      participant_rank || null,
      id,
    ]
  );
  return result.rows[0];
};

export const deleteParticipant = async (id) => {
  const result = await pool.query("DELETE FROM participants WHERE id = $1 RETURNING *", [id]);
  return result.rows[0];
};

// New methods for managing participant-division relationships
export const addParticipantDivision = async (participant_id, division_id) => {
  const result = await pool.query(
    "INSERT INTO tournament_participants (participant_id, division_id) VALUES ($1, $2) RETURNING *",
    [participant_id, division_id]
  );
  return result.rows[0];
};

export const removeParticipantDivision = async (participant_id, division_id) => {
  const result = await pool.query(
    "DELETE FROM tournament_participants WHERE participant_id = $1 AND division_id = $2 RETURNING *",
    [participant_id, division_id]
  );
  return result.rows[0];
};

export const getParticipantDivisions = async (participant_id) => {
  const result = await pool.query(
    `SELECT d.id, d.division_name 
     FROM tournament_participants tp 
     JOIN divisions d ON tp.division_id = d.id 
     WHERE tp.participant_id = $1`,
    [participant_id]
  );
  return result.rows;
};