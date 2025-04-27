import pool from "./db.js";

export const addRegistrationDivision = async (registration_id, division_id) => {
  const result = await pool.query(
    "INSERT INTO registrations_divisions (registration_id, division_id) VALUES ($1, $2) RETURNING *",
    [registration_id, division_id]
  );
  return result.rows[0];
};

export const getDivisionsForRegistration = async (registration_id) => {
  const result = await pool.query(`
    SELECT d.* FROM divisions d
    JOIN registrations_divisions rd ON d.id = rd.division_id
    WHERE rd.registration_id = $1
  `, [registration_id]);
  return result.rows;
};

export const removeRegistrationDivision = async (registration_id, division_id) => {
  const result = await pool.query(
    "DELETE FROM registrations_divisions WHERE registration_id = $1 AND division_id = $2 RETURNING *",
    [registration_id, division_id]
  );
  return result.rows[0];
};
