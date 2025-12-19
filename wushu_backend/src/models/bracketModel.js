import pool from "./db.js";

// Create a new bracket container
export const createBracket = async (data) => {
  const { tournament_id, division_id, bracket_type, name, settings } = data;
  const result = await pool.query(
    `INSERT INTO brackets (tournament_id, division_id, bracket_type, name, settings)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [tournament_id, division_id, bracket_type, name, settings || {}]
  );
  return result.rows[0];
};

// Get brackets for a specific tournament/division
export const getBrackets = async (tournamentId, divisionId) => {
  const result = await pool.query(
    `SELECT * FROM brackets 
     WHERE tournament_id = $1 AND ($2::int IS NULL OR division_id = $2)
     ORDER BY created_at DESC`,
    [tournamentId, divisionId]
  );
  return result.rows;
};

// Create match nodes (Bulk insert for generating a tree)
export const createMatches = async (matches) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const created = [];
    
    for (const m of matches) {
      const res = await client.query(
        `INSERT INTO matches (bracket_id, round_number, match_number, participant1_id, participant2_id, next_match_id)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [m.bracket_id, m.round_number, m.match_number, m.participant1_id, m.participant2_id, m.next_match_id]
      );
      created.push(res.rows[0]);
    }
    
    await client.query('COMMIT');
    return created;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};