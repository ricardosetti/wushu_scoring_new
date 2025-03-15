import pool from "./db.js";

export const addDivision = async (division_name) => {
    const result = await pool.query(
      "INSERT INTO divisions (division_name) VALUES ($1) RETURNING *",
      [division_name]
    );
    return result.rows[0];
  };

export const getDivisions = async () => {
  const result = await pool.query("SELECT * FROM divisions ORDER BY division_name ASC");
  return result.rows;
};

export const getDivisionById = async (id) => {
  const result = await pool.query("SELECT * FROM divisions WHERE id = $1", [id]);
  return result.rows[0];
};

export const getActiveDivision = async () => {
    const result = await pool.query("SELECT * FROM divisions WHERE active = TRUE LIMIT 1");
    return result.rows[0] || null;
  };

export const setActiveDivision = async (division_id) => {
    // First, set all divisions to inactive
    await pool.query("UPDATE divisions SET active = FALSE WHERE active = TRUE");
    // Then, set the specified division to active
    const result = await pool.query(
      "UPDATE divisions SET active = TRUE WHERE id = $1 RETURNING *",
      [division_id]
    );
    return result.rows[0];
  };

  export const clearActiveDivision = async () => {
    const result = await pool.query("UPDATE divisions SET active = FALSE WHERE active = TRUE RETURNING *");
    return result.rows[0] || null;
  };

  export const updateDivision = async (id, division_name) => {
    const result = await pool.query(
      "UPDATE divisions SET division_name = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *",
      [division_name, id]
    );
    return result.rows[0];
  };

export const deleteDivision = async (id) => {
  const result = await pool.query("DELETE FROM divisions WHERE id = $1 RETURNING *", [id]);
  return result.rows[0];
};