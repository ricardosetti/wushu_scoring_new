import pool from "./db.js";

export const getAllParticipants = async () => {
  const result = await pool.query("SELECT * FROM participants ORDER BY name ASC");
  return result.rows;
};

export const addParticipant = async (name, school_id, division) => {
  const result = await pool.query(
    "INSERT INTO participants (name, school_id, division) VALUES ($1, $2, $3) RETURNING *",
    [name, school_id || null, division]
  );
  return result.rows[0];
};

export const getParticipants = async () => {
  const result = await pool.query(
    "SELECT p.id, p.name, p.division, s.school_name, s.id AS school_id FROM participants p LEFT JOIN schools s ON p.school_id = s.id ORDER BY p.name ASC"
  );
  return result.rows;
};

export const getParticipantById = async (id) => {
  const result = await pool.query(
    "SELECT p.id, p.name, p.division, s.school_name, s.id AS school_id FROM participants p LEFT JOIN schools s ON p.school_id = s.id WHERE p.id = $1",
    [id]
  );
  return result.rows[0];
};

export const updateParticipant = async (id, name, school_id, division) => {
  const result = await pool.query(
    "UPDATE participants SET name = $1, school_id = $2, division = $3 WHERE id = $4 RETURNING *",
    [name, school_id || null, division, id]
  );
  return result.rows[0];
};

export const deleteParticipant = async (id) => {
  const result = await pool.query("DELETE FROM participants WHERE id = $1 RETURNING *", [id]);
  return result.rows[0];
};