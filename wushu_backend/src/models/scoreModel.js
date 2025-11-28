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

// NEW: Fetch all raw components to calculate final
export const getScoreComponents = async (participantId, divisionId) => {
  // 1. Get Judges Scores
  const scoresRes = await pool.query(`
    SELECT judge, score 
    FROM scores 
    WHERE participant_id = $1 AND division_id = $2
  `, [participantId, divisionId]);

  // 2. Get Deductions
  const dedRes = await pool.query(`
    SELECT d.deduction_value 
    FROM participant_deductions pd
    JOIN deductions d ON pd.deduction_id = d.deduction_id
    WHERE pd.participant_id = $1 AND pd.division_id = $2
  `, [participantId, divisionId]);

  return {
    scores: scoresRes.rows,
    deductions: dedRes.rows
  };
};

// NEW: Save the final calculated result
export const saveFinalResult = async (data) => {
  const { tournament_id, participant_id, division_id, total_score, breakdown } = data;
  
  const result = await pool.query(`
    INSERT INTO tournament_results (
      tournament_id, participant_id, division_id, total_score, score_breakdown
    ) VALUES ($1, $2, $3, $4, $5)
    ON CONFLICT (participant_id, division_id) 
    DO UPDATE SET 
      total_score = EXCLUDED.total_score,
      score_breakdown = EXCLUDED.score_breakdown,
      created_at = CURRENT_TIMESTAMP
    RETURNING *
  `, [tournament_id, participant_id, division_id, total_score, breakdown]);
  
  return result.rows[0];
};