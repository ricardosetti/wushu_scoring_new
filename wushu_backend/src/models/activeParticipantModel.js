import pool from "./db.js";

export const getActiveParticipant = async () => {
  const result = await pool.query(
    "SELECT participants.* FROM participants JOIN tournament_details ON participants.id = tournament_details.value WHERE tournament_details.argument = 'Active_ID' LIMIT 1"
  );
  return result.rows[0] || null;
};

export const setActiveParticipant = async (id) => {
  await pool.query("UPDATE participants SET active = false");
  const result = await pool.query(
    "UPDATE participants SET active = true WHERE id = $1 RETURNING *",
    [id]
  );
  return result.rows[0];
};
