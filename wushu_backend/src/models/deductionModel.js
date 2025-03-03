import pool from "./db.js";

export const getAllDeductions = async () => {
  const result = await pool.query("SELECT * FROM deductions ORDER BY deduction_category");
  return result.rows;
};

export const getDeductionById = async (deduction_id) => {
  const result = await pool.query(
    "SELECT deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code FROM deductions WHERE deduction_id = $1",
    [deduction_id]
  );
  return result.rows[0] || null;
};

export const addDeduction = async (category, criteria, description, value, deduction_code) => {
  const result = await pool.query(
    "INSERT INTO deductions (deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) VALUES ($1, $2, $3, $4, $5) RETURNING *",
    [category, criteria, description, value, deduction_code]
  );
  return result.rows[0];
};

export const updateDeduction = async (id, category, criteria, description, value, deduction_code) => {
  const result = await pool.query(
    "UPDATE deductions SET deduction_category = $1, deduction_criteria = $2, deduction_description = $3, deduction_value = $4, deduction_code = $5 WHERE deduction_id = $6 RETURNING *",
    [category, criteria, description, value, deduction_code, id]
  );
  return result.rows[0];
};

export const deleteDeduction = async (id) => {
  const result = await pool.query("DELETE FROM deductions WHERE deduction_id = $1 RETURNING *", [id]);
  return result.rows[0];
};

export const getDeductionByCode = async (deduction_code) => {
  const result = await pool.query(
    "SELECT deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code FROM deductions WHERE deduction_code = $1",
    [deduction_code]
  );
  return result.rows[0] || null;
};