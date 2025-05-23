import { addParticipantDeduction, getDeductionsForParticipant, deleteParticipantDeduction as deleteParticipantDeductionModel } from "../models/participantDeductionModel.js";

export const createParticipantDeduction = async (req, res) => {
  const { participant_id, deduction_id, judge, division_id } = req.body;

  if (!participant_id || !deduction_id || !judge || !division_id) {
    return res.status(400).json({ error: "Missing required fields (participant_id, deduction_id, judge, division_id)" });
  }

  try {
    const newDeduction = await addParticipantDeduction(participant_id, deduction_id, judge, division_id);
    req.app.get('io').emit('deductionUpdated', { 
      participantId: participant_id,
      division_id: division_id,
      deduction_codes: [newDeduction.deduction_code]
    });
    res.status(201).json(newDeduction);
  } catch (err) {
    console.error("Error saving participant deduction:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const fetchParticipantDeductions = async (req, res) => {
  const { participant_id, judge } = req.params;
  const { division_id } = req.query;

  if (!division_id) {
    return res.status(400).json({ error: "Missing required query parameter (division_id)" });
  }

  try {
    const deductions = await getDeductionsForParticipant(participant_id, judge, parseInt(division_id));
    res.json(deductions);
  } catch (err) {
    console.error("Error fetching participant deductions:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const deleteParticipantDeduction = async (req, res) => {
  const { participant_id, deduction_id, judge } = req.params;
  const { division_id } = req.query;

  if (!division_id) {
    return res.status(400).json({ error: "Missing required query parameter (division_id)" });
  }

  try {
    const deletedDeduction = await deleteParticipantDeductionModel(participant_id, deduction_id, judge, parseInt(division_id));
    req.app.get('io').emit('deductionUpdated', { 
      participantId: participant_id,
      division_id: parseInt(division_id),
      deduction_codes: []
    });
    res.json({ message: "Deduction removed successfully", deleted: deletedDeduction });
  } catch (err) {
    console.error("Error deleting participant deduction:", err.message);
    if (err.message === "Deduction not found" || err.message === "Deduction record not found") {
      return res.status(404).json({ error: err.message });
    }
    res.status(500).json({ error: "Internal Server Error" });
  }
};