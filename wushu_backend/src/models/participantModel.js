import pool from "./db.js";

export const getAllParticipants = async () => {
  const result = await pool.query("SELECT * FROM participants ORDER BY name ASC");
  return result.rows;
};

export const addParticipant = async (name, school, division) => {
  try {
    const result = await pool.query(
      "INSERT INTO participants (name, school, division) VALUES ($1, $2, $3) RETURNING *",
      [name, school, division]
    );
    return result.rows[0];
  } catch (err) {
    throw err; // Let the controller handle the error
  }
};

export const getParticipantById = async (id) => {
  const result = await pool.query("SELECT * FROM participants WHERE id = $1", [id]);
  return result.rows[0] || null;
};
