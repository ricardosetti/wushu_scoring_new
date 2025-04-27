import pool from "./db.js";

export const addTournament = async (data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country, tournament_email
  } = data;

  const result = await pool.query(`
    INSERT INTO tournaments (
      tournament_title, tournament_start_date, tournament_end_date,
      tournament_hours, tournament_contact, tournament_address,
      tournament_city, tournament_state, tournament_country, tournament_email
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    RETURNING *;
  `, [
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country, tournament_email
  ]);

  return result.rows[0];
};

export const getTournaments = async () => {
  const result = await pool.query("SELECT * FROM tournaments ORDER BY tournament_start_date DESC");
  return result.rows;
};

export const getTournamentById = async (tournament_id) => {
  const result = await pool.query(
    "SELECT * FROM tournaments WHERE tournament_id = $1",
    [tournament_id]
  );
  return result.rows[0];
};

export const updateTournament = async (tournament_id, data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country, tournament_email
  } = data;

  const result = await pool.query(`
    UPDATE tournaments
    SET tournament_title = $1, tournament_start_date = $2, tournament_end_date = $3,
        tournament_hours = $4, tournament_contact = $5, tournament_address = $6,
        tournament_city = $7, tournament_state = $8, tournament_country = $9, tournament_email = $10,
        updated_at = CURRENT_TIMESTAMP
    WHERE tournament_id = $11
    RETURNING *;
  `, [
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country, tournament_email,
    tournament_id
  ]);

  return result.rows[0];
};
