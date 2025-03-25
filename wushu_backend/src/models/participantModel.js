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
  try {
    const result = await pool.query(`
      INSERT INTO participants (
        first_name, middle_name, last_name, school_id, birthdate, height_feet, height_inches,
        weight, gender, phone, emergency_contact_name, emergency_contact_phone, street,
        city, state, country, zip_code, participant_rank
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      RETURNING *,
             (SELECT school_name FROM schools s WHERE s.id = school_id) AS school_name
    `, [
      first_name, middle_name, last_name, school_id, birthdate, height_feet, height_inches,
      weight, gender, phone, emergency_contact_name, emergency_contact_phone, street,
      city, state, country, zip_code, participant_rank
    ]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const getParticipants = async () => {
  try {
    const result = await pool.query(`
      SELECT p.*, s.school_name,
             ARRAY_AGG(d.division_name) AS divisions
      FROM participants p
      LEFT JOIN schools s ON p.school_id = s.id
      LEFT JOIN tournament_participants tp ON p.id = tp.participant_id
      LEFT JOIN divisions d ON tp.division_id = d.id
      GROUP BY p.id, s.school_name
      ORDER BY p.last_name, p.first_name
    `);
    return result.rows;
  } catch (err) {
    throw new Error(err.message);
  }
};

export const getParticipantById = async (id) => {
  try {
    const result = await pool.query(`
      SELECT p.*, s.school_name,
             ARRAY_AGG(d.division_name) AS divisions
      FROM participants p
      LEFT JOIN schools s ON p.school_id = s.id
      LEFT JOIN tournament_participants tp ON p.id = tp.participant_id
      LEFT JOIN divisions d ON tp.division_id = d.id
      WHERE p.id = $1
      GROUP BY p.id, s.school_name
    `, [id]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
}

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
  try {
    const result = await pool.query(`
      UPDATE participants
      SET first_name = $1, middle_name = $2, last_name = $3, school_id = $4, birthdate = $5,
          height_feet = $6, height_inches = $7, weight = $8, gender = $9, phone = $10,
          emergency_contact_name = $11, emergency_contact_phone = $12, street = $13,
          city = $14, state = $15, country = $16, zip_code = $17, participant_rank = $18
      WHERE id = $19
      RETURNING *,
             (SELECT school_name FROM schools s WHERE s.id = school_id) AS school_name
    `, [
      first_name, middle_name, last_name, school_id, birthdate, height_feet, height_inches,
      weight, gender, phone, emergency_contact_name, emergency_contact_phone, street,
      city, state, country, zip_code, participant_rank, id
    ]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const deleteParticipant = async (id) => {
  try {
    const result = await pool.query('DELETE FROM participants WHERE id = $1 RETURNING *', [id]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

// New methods for managing participant-division relationships
export const addParticipantDivision = async (participant_id, division_id) => {
  try {
    const result = await pool.query(`
      INSERT INTO tournament_participants (participant_id, division_id)
      VALUES ($1, $2)
      RETURNING *
    `, [participant_id, division_id]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const removeParticipantDivision = async (participant_id, division_id) => {
  try {
    const result = await pool.query(`
      DELETE FROM tournament_participants
      WHERE participant_id = $1 AND division_id = $2
      RETURNING *
    `, [participant_id, division_id]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const getParticipantDivisions = async (participant_id) => {
  try {
    const result = await pool.query(`
      SELECT d.*
      FROM divisions d
      JOIN tournament_participants tp ON d.id = tp.division_id
      WHERE tp.participant_id = $1
    `, [participant_id]);
    console.log('getParticipantDivisions result:', result.rows);
    return result.rows;
  } catch (err) {
    throw new Error(err.message);
  }
};