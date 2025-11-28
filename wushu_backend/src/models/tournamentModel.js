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

export const addTournament = async (data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country,
    tournament_email, is_active,
    color_primary, color_background, details_content, tournament_logo
  } = data;

  try {
    const result = await pool.query(`
      INSERT INTO tournaments (
        tournament_title, tournament_start_date, tournament_end_date,
        tournament_hours, tournament_contact, tournament_address,
        tournament_city, tournament_state, tournament_country,
        tournament_email, is_active,
        color_primary, color_background, details_content, tournament_logo
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      RETURNING *
    `, [
      tournament_title, tournament_start_date || null, tournament_end_date || null,
      tournament_hours || null, tournament_contact || null, tournament_address || null,
      tournament_city || null, tournament_state || null, tournament_country || null,
      tournament_email || null, is_active || false,
      color_primary || '#1E40AF', color_background || '#F3F4F6', details_content || '', tournament_logo || null
    ]);
    return result.rows[0];
  } catch (err) {
    throw new Error(err.message);
  }
};

export const updateTournament = async (id, data) => {
  const {
    tournament_title, tournament_start_date, tournament_end_date,
    tournament_hours, tournament_contact, tournament_address,
    tournament_city, tournament_state, tournament_country,
    tournament_email, is_active,
    color_primary, color_background, details_content, tournament_logo
  } = data;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    if (is_active) {
       await client.query("UPDATE tournaments SET is_active = false WHERE tournament_id != $1", [id]);
       await client.query("UPDATE tournament_details SET value = 0 WHERE argument IN ('Active_ID', 'OnDeck_ID')");
    }

    // Build query dynamically to handle optional logo update
    // If tournament_logo is undefined (not sent), we keep the old one
    let logoQueryPart = "";
    let params = [
      tournament_title, tournament_start_date || null, tournament_end_date || null,
      tournament_hours || null, tournament_contact || null, tournament_address || null,
      tournament_city || null, tournament_state || null, tournament_country || null,
      tournament_email || null, is_active || false,
      color_primary || '#1E40AF', color_background || '#F3F4F6', details_content || '',
      id
    ];

    if (tournament_logo !== undefined) {
      logoQueryPart = ", tournament_logo = $16";
      params.push(tournament_logo);
    }

    const result = await client.query(`
      UPDATE tournaments
      SET
        tournament_title = $1, tournament_start_date = $2, tournament_end_date = $3,
        tournament_hours = $4, tournament_contact = $5, tournament_address = $6,
        tournament_city = $7, tournament_state = $8, tournament_country = $9,
        tournament_email = $10, is_active = $11, 
        color_primary = $12, color_background = $13, details_content = $14,
        updated_at = CURRENT_TIMESTAMP
        ${logoQueryPart}
      WHERE tournament_id = $15
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