import pool from "./db.js";

export const addDivision = async (division_name) => {
  try {
    const result = await pool.query(
      "INSERT INTO divisions (division_name) VALUES ($1) RETURNING *",
      [division_name]
    );
    return result.rows[0];
  } catch (err) {
    throw new Error(`Failed to add division: ${err.message}`);
  }
};

export const getDivisions = async () => {
  try {
    const result = await pool.query("SELECT * FROM divisions ORDER BY division_name ASC");
    return result.rows;
  } catch (err) {
    throw new Error(`Failed to fetch divisions: ${err.message}`);
  }
};

export const getDivisionById = async (id) => {
  try {
    const result = await pool.query("SELECT * FROM divisions WHERE id = $1", [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(`Failed to fetch division by ID: ${err.message}`);
  }
};

export const getActiveDivision = async () => {
  try {
    const result = await pool.query("SELECT * FROM divisions WHERE active = TRUE LIMIT 1");
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(`Failed to fetch active division: ${err.message}`);
  }
};

export const setActiveDivision = async (division_id) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    // First, set all divisions to inactive
    await client.query("UPDATE divisions SET active = FALSE WHERE active = TRUE");
    // Then, set the specified division to active
    const result = await client.query(
      "UPDATE divisions SET active = TRUE WHERE id = $1 RETURNING *",
      [division_id]
    );
    if (result.rows.length === 0) {
      throw new Error("Division not found");
    }
    await client.query("COMMIT");
    return result.rows[0];
  } catch (err) {
    await client.query("ROLLBACK");
    throw new Error(`Failed to set active division: ${err.message}`);
  } finally {
    client.release();
  }
};

export const clearActiveDivision = async () => {
  try {
    const result = await pool.query("UPDATE divisions SET active = FALSE WHERE active = TRUE RETURNING *");
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(`Failed to clear active division: ${err.message}`);
  }
};

export const updateDivision = async (id, division_name) => {
  try {
    const result = await pool.query(
      "UPDATE divisions SET division_name = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *",
      [division_name, id]
    );
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(`Failed to update division: ${err.message}`);
  }
};

export const deleteDivision = async (id) => {
  try {
    const result = await pool.query("DELETE FROM divisions WHERE id = $1 RETURNING *", [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(`Failed to delete division: ${err.message}`);
  }
};