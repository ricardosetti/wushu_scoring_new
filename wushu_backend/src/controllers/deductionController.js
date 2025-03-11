import { getAllDeductions, addDeduction, updateDeduction, deleteDeduction, getDeductionById, getDeductionByCode } from "../models/deductionModel.js";

export const fetchDeductions = async (req, res) => {
  try {
    const deductions = await getAllDeductions();
    res.json(deductions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchDeductionById = async (req, res) => {
  const { id } = req.params;
  try {
    const deduction = await getDeductionById(id);
    if (!deduction) {
      return res.status(404).json({ error: "Deduction not found" });
    }
    res.json(deduction);
  } catch (err) {
    console.error("Error fetching deduction:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const createDeduction = async (req, res) => {
  const { deduction_category, deduction_criteria, deduction_description, deduction_value } = req.body;
  try {
    const newDeduction = await addDeduction(deduction_category, deduction_criteria, deduction_description, deduction_value);
    if (req.body.participant_id) {
      req.app.get('io').emit('deductionUpdated', { participantId: req.body.participant_id });
    }
    res.status(201).json(newDeduction);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const editDeduction = async (req, res) => {
  const { deduction_category, deduction_criteria, deduction_description, deduction_value } = req.body;
  const { id } = req.params;
  try {
    const updatedDeduction = await updateDeduction(id, deduction_category, deduction_criteria, deduction_description, deduction_value);
    if (req.body.participant_id) {
      req.app.get('io').emit('deductionUpdated', { participantId: req.body.participant_id });
    }
    res.json(updatedDeduction);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const removeDeduction = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedDeduction = await deleteDeduction(id);
    const participantId = req.body.participant_id || deletedDeduction.participant_id; // Adjust based on model
    if (participantId) {
      req.app.get('io').emit('deductionUpdated', { participantId });
    }
    res.json(deletedDeduction);
  } catch (err) {
    if (err.message === "Deduction not found") {
      return res.status(404).json({ error: "Deduction not found" });
    }
    res.status(500).json({ error: err.message });
  }
};

export const fetchDeductionByCode = async (req, res) => {
  const { code } = req.params;
  try {
    const deduction = await getDeductionByCode(code);
    if (!deduction) {
      return res.status(404).json({ error: "Deduction not found" });
    }
    res.json(deduction);
  } catch (err) {
    console.error("Error fetching deduction by code:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};