import pool from "./db.js";

// Toggle a school's access to the Active Tournament
export const toggleTournamentSchool = async (schoolId, isActive) => {
  const client = await pool.connect();
  try {
    // 1. Find the active tournament ID
    const tourneyRes = await client.query("SELECT tournament_id FROM tournaments WHERE is_active = TRUE LIMIT 1");
    const tournamentId = tourneyRes.rows[0]?.tournament_id;

    if (!tournamentId) throw new Error("No active tournament found.");

    if (isActive) {
      // Link: Allow this school in this tournament
      await client.query(
        "INSERT INTO tournament_schools (tournament_id, school_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        [tournamentId, schoolId]
      );
    } else {
      // Unlink: Block this school from this tournament
      await client.query(
        "DELETE FROM tournament_schools WHERE tournament_id = $1 AND school_id = $2",
        [tournamentId, schoolId]
      );
    }
    return { success: true };
  } finally {
    client.release();
  }
};

// Fetch all schools, but include a flag (is_active_in_tournament) 
// checking if they are linked to the CURRENT active tournament
export const getSchoolsWithStatus = async () => {
  const result = await pool.query(`
    SELECT s.*, 
           CASE WHEN ts.tournament_id IS NOT NULL THEN true ELSE false END as is_active_in_tournament
    FROM schools s
    LEFT JOIN tournament_schools ts 
      ON s.id = ts.school_id 
      AND ts.tournament_id = (SELECT tournament_id FROM tournaments WHERE is_active = TRUE LIMIT 1)
    ORDER BY s.school_name ASC
  `);
  return result.rows;
};