import pool from "./db.js";

export const addParticipantDeduction = async (participant_id, deduction_id, judge) => {
    const result = await pool.query(
      "INSERT INTO participant_deductions (participant_id, deduction_id, judge) VALUES ($1, $2, $3) RETURNING *",
      [participant_id, deduction_id, judge]
    );
    return result.rows[0];
  };
  


  export const getDeductionsForParticipant = async (participant_id, judge) => {
    const result = await pool.query(
      `SELECT pd.id AS participant_deduction_id, d.deduction_category, d.deduction_criteria, d.deduction_description, d.deduction_value, d.deduction_id
       FROM participant_deductions pd
       JOIN deductions d ON pd.deduction_id = d.deduction_id
       WHERE pd.participant_id = $1 AND pd.judge = $2
       ORDER BY pd.created_at DESC`,
      [participant_id, judge]
    );
    return result.rows;
  };
