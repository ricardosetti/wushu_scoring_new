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

export const getDivisions = async (tournamentId = null) => {
  try {
    let query = "SELECT * FROM divisions";
    let params = [];

    // If a tournament ID is provided, filter by the link table
    if (tournamentId) {
      query = `
        SELECT d.* FROM divisions d
        JOIN tournament_divisions td ON d.id = td.division_id
        WHERE td.tournament_id = $1
        ORDER BY d.division_name ASC
      `;
      params = [tournamentId];
    } else {
      query += " ORDER BY division_name ASC";
    }

    const result = await pool.query(query, params);
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

export const toggleTournamentDivision = async (divisionId, isActive) => {
  const client = await pool.connect();
  try {
    // 1. Find the currently active tournament
    const tourneyRes = await client.query("SELECT tournament_id FROM tournaments WHERE is_active = TRUE LIMIT 1");
    const tournamentId = tourneyRes.rows[0]?.tournament_id;

    if (!tournamentId) throw new Error("No active tournament found.");

    if (isActive) {
      // Link it
      await client.query(
        "INSERT INTO tournament_divisions (tournament_id, division_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        [tournamentId, divisionId]
      );
    } else {
      // Unlink it
      await client.query(
        "DELETE FROM tournament_divisions WHERE tournament_id = $1 AND division_id = $2",
        [tournamentId, divisionId]
      );
    }
    return { success: true };
  } finally {
    client.release();
  }
};