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
    res.json(updatedDeduction);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const removeDeduction = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedDeduction = await deleteDeduction(id);
    res.json(deletedDeduction);
  } catch (err) {
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