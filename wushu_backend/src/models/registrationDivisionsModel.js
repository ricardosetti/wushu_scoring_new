import pool from './db.js';

export const addRegistrationDivision = async (registrationId, divisionId, client = pool) => {
  const useClient = client !== pool ? client : await pool.connect();
  try {
    const result = await useClient.query(
      'INSERT INTO registrations_divisions (registration_id, division_id) VALUES ($1, $2) RETURNING *',
      [registrationId, divisionId]
    );
    return result.rows[0];
  } finally {
    if (client === pool) useClient.release();
  }
};

export const getDivisionsForRegistration = async (registrationId, client = pool) => {
  const useClient = client !== pool ? client : await pool.connect();
  try {
    const result = await useClient.query(
      `
      SELECT d.*
      FROM divisions d
      JOIN registrations_divisions rd ON d.id = rd.division_id
      WHERE rd.registration_id = $1
      `,
      [registrationId]
    );
    return result.rows;
  } finally {
    if (client === pool) useClient.release();
  }
};

export const removeRegistrationDivision = async (registrationId, divisionId) => {
  const result = await pool.query(
    'DELETE FROM registrations_divisions WHERE registration_id = $1 AND division_id = $2 RETURNING *',
    [registrationId, divisionId]
  );
  return result.rows[0] || null;
};