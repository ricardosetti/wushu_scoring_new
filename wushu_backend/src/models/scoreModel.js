import pool from "./db.js";

export const getAllScores = async () => {
  const result = await pool.query("SELECT * FROM scores ORDER BY created_at DESC");
  return result.rows;
};

export const addScore = async (participant_id, judge, score, division_id) => {
  const result = await pool.query(
    "INSERT INTO scores (participant_id, judge, score, division_id) VALUES ($1, $2, $3, $4) RETURNING *",
    [participant_id, judge, score, division_id]
  );
  return result.rows[0];
};

export const getLatestScore = async (participant_id, judge, division_id) => {
  const result = await pool.query(
    "SELECT score FROM scores WHERE participant_id = $1 AND judge = $2 AND division_id = $3 ORDER BY created_at DESC LIMIT 1",
    [participant_id, judge, division_id]
  );
  return result.rows.length > 0 ? result.rows[0] : null;
};

export const getScoresForParticipant = async (participant_id, division_id) => {
  const result = await pool.query(
    "SELECT judge, score FROM scores WHERE participant_id = $1 AND division_id = $2 ORDER BY created_at DESC",
    [participant_id, division_id]
  );
  return result.rows;
};