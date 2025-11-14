import pool from "./db.js";

export const getTournaments = async () => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM tournaments
      ORDER BY tournament_start_date DESC, tournament_title
    `);
    return result.rows;
  } catch (err) {
    throw new Error(err.message);
  }
};

export const getTournamentById = async (id) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM tournaments
      WHERE tournament_id = $1
    `, [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(err.message);
  }
};

export const addTournament = async (
  tournament_title,
  tournament_start_date,
  tournament_end_date,
  tournament_hours,
  tournament_contact,
  tournament_address,
  tournament_city,
  tournament_state,
  tournament_country,
  tournament_email
) => {
  try {
    const result = await pool.query(`
      INSERT INTO tournaments (
        tournament_title,
        tournament_start_date,
        tournament_end_date,
        tournament_hours,
        tournament_contact,
        tournament_address,
        tournament_city,
        tournament_state,
        tournament_country,
        tournament_email
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
    `, [
      tournament_title,
      tournament_start_date || null,
      tournament_end_date || null,
      tournament_hours || null,
      tournament_contact || null,
      tournament_address || null,
      tournament_city || null,
      tournament_state || null,
      tournament_country || null,
      tournament_email || null
    ]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const updateTournament = async (
  id,
  tournament_title,
  tournament_start_date,
  tournament_end_date,
  tournament_hours,
  tournament_contact,
  tournament_address,
  tournament_city,
  tournament_state,
  tournament_country,
  tournament_email
) => {
  try {
    const result = await pool.query(`
      UPDATE tournaments
      SET
        tournament_title = $1,
        tournament_start_date = $2,
        tournament_end_date = $3,
        tournament_hours = $4,
        tournament_contact = $5,
        tournament_address = $6,
        tournament_city = $7,
        tournament_state = $8,
        tournament_country = $9,
        tournament_email = $10,
        updated_at = CURRENT_TIMESTAMP
      WHERE tournament_id = $11
      RETURNING *
    `, [
      tournament_title,
      tournament_start_date || null,
      tournament_end_date || null,
      tournament_hours || null,
      tournament_contact || null,
      tournament_address || null,
      tournament_city || null,
      tournament_state || null,
      tournament_country || null,
      tournament_email || null,
      id
    ]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(err.message);
  }
};

export const deleteTournament = async (id) => {
  try {
    const result = await pool.query(`
      DELETE FROM tournaments
      WHERE tournament_id = $1
      RETURNING *
    `, [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(err.message);
  }
};