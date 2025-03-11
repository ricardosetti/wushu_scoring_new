import pool from "./db.js";

export const getTournamentDetail = async (argument) => {
  const result = await pool.query("SELECT value FROM tournament_details WHERE argument = $1", [argument]);
  return result.rows[0] ? result.rows[0].value : null;
};

export const setTournamentDetail = async (argument, value) => {
  const result = await pool.query(
    "INSERT INTO tournament_details (argument, value) VALUES ($1, $2) ON CONFLICT (argument) DO UPDATE SET value = $2 RETURNING *",
    [argument, value]
  );
  return result.rows[0];
};
