import pool from "./db.js";

export const publishScores = async (participant_id, scores, division_id) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query(
      "DELETE FROM published_scores WHERE participant_id = $1 AND division_id = $2",
      [participant_id, division_id]
    );
    const results = [];
    for (const { judge, score } of scores) {
      const result = await client.query(
        "INSERT INTO published_scores (participant_id, judge, score, division_id) VALUES ($1, $2, $3, $4) RETURNING *",
        [participant_id, judge, score, division_id]
      );
      results.push(result.rows[0]);
    }
    await client.query("COMMIT");
    return results;
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};

export const getPublishedScoresForParticipant = async (participant_id, division_id) => {
  const scoresResult = await pool.query(
    `SELECT DISTINCT ON (judge) judge, score
     FROM published_scores
     WHERE participant_id = $1 AND division_id = $2
     ORDER BY judge, published_at DESC`,
    [participant_id, division_id]
  );
  const deductionsResult = await pool.query(
    `SELECT DISTINCT d.deduction_code
     FROM participant_deductions pd
     JOIN deductions d ON pd.deduction_id = d.deduction_id
     WHERE pd.participant_id = $1 AND pd.division_id = $2`,
    [participant_id, division_id]
  );
  return {
    scores: scoresResult.rows,
    deduction_codes: deductionsResult.rows.map((row) => row.deduction_code),
  };
};