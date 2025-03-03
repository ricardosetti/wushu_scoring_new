import pool from "../models/db.js";
import { addParticipantDeduction, getDeductionsForParticipant} from "../models/participantDeductionModel.js";

export const createParticipantDeduction = async (req, res) => {
    const { participant_id, deduction_id, judge } = req.body;
  
    if (!participant_id || !deduction_id || !judge) {
      return res.status(400).json({ error: "Missing required fields (participant_id, deduction_id, judge)" });
    }
  
    try {
      const newDeduction = await addParticipantDeduction(participant_id, deduction_id, judge);
      res.status(201).json(newDeduction);
    } catch (err) {
      console.error("Error saving participant deduction:", err.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  };
  

export const fetchParticipantDeductions = async (req, res) => {
  const { participant_id, judge } = req.params;

  try {
    const deductions = await getDeductionsForParticipant(participant_id, judge);
    res.json(deductions);
  } catch (err) {
    console.error("Error fetching participant deductions:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const deleteParticipantDeduction = async (req, res) => {
    const { participant_id, deduction_id, judge } = req.params;
  
    try {
      const result = await pool.query(
        "DELETE FROM participant_deductions WHERE participant_id = $1 AND deduction_id = $2 AND judge = $3 RETURNING *",
        [participant_id, deduction_id, judge]
      );
  
      if (result.rows.length === 0) {
        return res.status(404).json({ error: "Deduction record not found" });
      }
  
      res.json({ message: "Deduction removed successfully", deleted: result.rows[0] });
    } catch (err) {
      console.error("Error deleting participant deduction:", err.message);
      res.status(500).json({ error: "Internal Server Error" });
    }
  };
