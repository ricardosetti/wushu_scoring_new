import pool from "./db.js";

export const getTournaments = async () => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM tournaments
      ORDER BY tournament_start_date DESC, tournament_title
    `);
    return result.rows;
  } catch (err) {
    throw new Error(err.message);
  }
};

export const getTournamentById = async (id) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM tournaments
      WHERE tournament_id = $1
    `, [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(err.message);
  }
};

// NEW: Get Open Tournaments for Registration
export const getOpenTournaments = async () => {
  const result = await pool.query(`
    SELECT * FROM tournaments 
    WHERE registration_start_date <= CURRENT_DATE 
      AND registration_end_date >= CURRENT_DATE
    ORDER BY tournament_start_date ASC
  `);
  return result.rows;
};

export const addTournament = async (data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    registration_start_date, registration_end_date, // <--- New fields
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country,
    tournament_email, is_active,
    color_primary, color_background, details_content, tournament_logo,
    judges_config
  } = data;

  try {
    const config = judges_config || { A1: true, A2: true, B1: true, B2: true };

    const result = await pool.query(`
      INSERT INTO tournaments (
        tournament_title, tournament_start_date, tournament_end_date,
        registration_start_date, registration_end_date,
        tournament_hours, tournament_contact, tournament_address,
        tournament_city, tournament_state, tournament_country,
        tournament_email, is_active,
        color_primary, color_background, details_content, tournament_logo,
        judges_config
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      RETURNING *
    `, [
      tournament_title, 
      tournament_start_date || null, tournament_end_date || null,
      registration_start_date || null, registration_end_date || null,
      tournament_hours || null, tournament_contact || null, tournament_address || null,
      tournament_city || null, tournament_state || null, tournament_country || null,
      tournament_email || null, is_active || false,
      color_primary || '#1E40AF', color_background || '#F3F4F6', details_content || '', tournament_logo || null,
      config
    ]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const updateTournament = async (id, data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    registration_start_date, registration_end_date, // <--- New fields
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country,
    tournament_email, is_active,
    color_primary, color_background, details_content, tournament_logo,
    judges_config
  } = data;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    if (is_active) {
       await client.query("UPDATE tournaments SET is_active = false WHERE tournament_id != $1", [id]);
       await client.query("UPDATE tournament_details SET value = 0 WHERE argument IN ('Active_ID', 'OnDeck_ID')");
    }

    let logoQueryPart = "";
    let params = [
      tournament_title, 
      tournament_start_date || null, tournament_end_date || null,
      registration_start_date || null, registration_end_date || null,
      tournament_hours || null, tournament_contact || null, tournament_address || null,
      tournament_city || null, tournament_state || null, tournament_country || null,
      tournament_email || null, is_active || false,
      color_primary || '#1E40AF', color_background || '#F3F4F6', details_content || '',
      judges_config || { A1: true, A2: true, B1: true, B2: true },
      id
    ];

    if (tournament_logo !== undefined) {
      logoQueryPart = ", tournament_logo = $19"; // Index 19 now
      params.push(tournament_logo);
    }

    const result = await client.query(`
      UPDATE tournaments
      SET
        tournament_title = $1, tournament_start_date = $2, tournament_end_date = $3,
        registration_start_date = $4, registration_end_date = $5,
        tournament_hours = $6, tournament_contact = $7, tournament_address = $8,
        tournament_city = $9, tournament_state = $10, tournament_country = $11,
        tournament_email = $12, is_active = $13, 
        color_primary = $14, color_background = $15, details_content = $16,
        judges_config = $17,
        updated_at = CURRENT_TIMESTAMP
        ${logoQueryPart}
      WHERE tournament_id = $18
      RETURNING *
    `, params);

    await client.query('COMMIT');
    return result.rows[0] || null;
  } catch (err) {
    await client.query('ROLLBACK');
    throw new Error(err.message);
  } finally {
    client.release();
  }
};

export const deleteTournament = async (id) => {
  try {
    const result = await pool.query(`
      DELETE FROM tournaments
      WHERE tournament_id = $1
      RETURNING *
    `, [id]);
    return result.rows[0] || null;
  } catch (err) {
    throw new Error(err.message);
  }
};