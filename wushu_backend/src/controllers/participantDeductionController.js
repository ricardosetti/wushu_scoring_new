import { addParticipantDeduction, getDeductionsForParticipant} from "../models/participantDeductionModel.js";

export const createParticipantDeduction = async (req, res) => {
  const { participant_id, deduction_id, judge } = req.body;

  if (!participant_id || !deduction_id || !judge) {
    return res.status(400).json({ error: "Missing required fields (participant_id, deduction_id, judge)" });
  }

  try {
    const newDeduction = await addParticipantDeduction(participant_id, deduction_id, judge);
    req.app.get('io').emit('deductionUpdated', { participantId: participant_id });
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
    const deletedDeduction = await deleteParticipantDeduction(participant_id, deduction_id, judge);
    req.app.get('io').emit('deductionUpdated', { participantId: participant_id });
    res.json({ message: "Deduction removed successfully", deleted: deletedDeduction });
  } catch (err) {
    console.error("Error deleting participant deduction:", err.message);
    if (err.message === "Deduction not found" || err.message === "Deduction record not found") {
      return res.status(404).json({ error: err.message });
    }
    res.status(500).json({ error: "Internal Server Error" });
  }
};
