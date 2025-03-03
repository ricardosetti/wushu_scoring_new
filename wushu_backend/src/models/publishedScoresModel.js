import pool from "./db.js";

export const publishScores = async (participant_id, scores) => {
    await pool.query("DELETE FROM published_scores WHERE participant_id = $1", [participant_id]);
    const results = [];
    for (const { judge, score } of scores) {
      const result = await pool.query(
        "INSERT INTO published_scores (participant_id, judge, score) VALUES ($1, $2, $3) RETURNING *",
        [participant_id, judge, score]
      );
      results.push(result.rows[0]);
    }
    return results;
  };

  export const getPublishedScoresForParticipant = async (participant_id) => {
    const scoresResult = await pool.query(
      "SELECT judge, score FROM published_scores WHERE participant_id = $1 ORDER BY published_at DESC",
      [participant_id]
    );
    const deductionsResult = await pool.query(
      `SELECT DISTINCT d.deduction_code
       FROM participant_deductions pd
       JOIN deductions d ON pd.deduction_id = d.deduction_id
       WHERE pd.participant_id = $1 AND pd.judge IN ('A1', 'A2')`,
      [participant_id]
    );
    return {
      scores: scoresResult.rows,
      deduction_codes: deductionsResult.rows.map(row => row.deduction_code),
    };
  };