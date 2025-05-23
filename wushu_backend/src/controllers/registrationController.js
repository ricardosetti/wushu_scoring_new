import bcrypt from 'bcrypt';
import pool from '../models/db.js';
import {
  addRegistration,
  getRegistrationByEmail,
  getAllRegistrations,
  updateRegistrationStatus,
  getRegistrationById,
  getRegistrationByToken,
} from '../models/registrationModel.js';
import {
  addRegistrationDivision,
  getDivisionsForRegistration,
  removeRegistrationDivision,
} from '../models/registrationDivisionsModel.js';

const validateRegistrationData = (data) => {
  const requiredFields = ['first_name', 'last_name', 'birthdate', 'gender', 'school_id', 'email'];
  for (const field of requiredFields) {
    if (!data[field]) {
      return `Missing required field: ${field}`;
    }
  }
  if (!data.divisions || !Array.isArray(data.divisions) || data.divisions.length === 0) {
    return 'At least one division is required';
  }
  return null;
};

const validateUpdateData = (data) => {
  const requiredFields = ['first_name', 'last_name', 'birthdate', 'gender', 'school_id', 'email'];
  for (const field of requiredFields) {
    if (!(field in data)) {
      return `Missing required field: ${field}`;
    }
  }
  if ('divisions' in data && (!Array.isArray(data.divisions) || data.divisions.length === 0)) {
    return 'At least one division is required';
  }
  return null;
};

export const createRegistration = async (req, res) => {
  try {
    const validationError = validateRegistrationData(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    const { password, divisions, ...registrationData } = req.body;

    // Hash the password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    if (!passwordHash) {
      throw new Error('Failed to hash password');
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN'); // Start transaction

      // Create the registration
      const registration = await addRegistration(
        {
          ...registrationData,
          password_hash: passwordHash,
        },
        client
      );

      // Add division associations
      for (const divisionId of divisions) {
        await addRegistrationDivision(registration.id, divisionId, client);
      }

      // Fetch the divisions to include in the response
      const associatedDivisions = await getDivisionsForRegistration(registration.id, client);

      await client.query('COMMIT');
      res.status(201).json({
        ...registration,
        divisions: associatedDivisions,
      });
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Registration error:', err.message);
    console.error('Stack trace:', err.stack);
    if (err.message.includes('duplicate key value violates unique constraint "registrations_email_key"')) {
      return res.status(409).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: 'Failed to create registration: ' + err.message });
  }
};

export const updateRegistration = async (req, res) => {
  const { id } = req.params;
  const {
    first_name,
    middle_name,
    last_name,
    birthdate,
    height_feet,
    height_inches,
    weight,
    gender,
    phone,
    emergency_contact_name,
    emergency_contact_phone,
    street,
    city,
    state,
    country,
    zip_code,
    participant_rank,
    email,
    password,
    divisions,
    school_id,
  } = req.body;

  try {
    // Validate required fields
    const validationError = validateUpdateData({
      first_name,
      last_name,
      birthdate,
      gender,
      school_id,
      email,
      divisions,
    });
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    // Validate gender
    if (gender && !['M', 'F', 'O'].includes(gender)) {
      return res.status(400).json({ error: 'Invalid gender value. Must be M, F, or O.' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN'); // Start transaction

      // Check if the registration exists
      const existingRegistration = await client.query('SELECT * FROM registrations WHERE id = $1', [id]);
      if (existingRegistration.rows.length === 0) {
        throw new Error('Registration not found');
      }

      // If email is updated, check for uniqueness
      if (email !== existingRegistration.rows[0].email) {
        const emailCheck = await client.query('SELECT id FROM registrations WHERE email = $1 AND id != $2', [email, id]);
        if (emailCheck.rows.length > 0) {
          throw new Error('Email already exists');
        }
      }

      // Hash the password if provided
      let passwordHash = existingRegistration.rows[0].password_hash;
      if (password) {
        const saltRounds = 10;
        passwordHash = await bcrypt.hash(password, saltRounds);
        if (!passwordHash) {
          throw new Error('Failed to hash password');
        }
      }

      // Update the registration
      const updateQuery = `
        UPDATE registrations
        SET
          first_name = $1,
          middle_name = $2,
          last_name = $3,
          birthdate = $4,
          height_feet = $5,
          height_inches = $6,
          weight = $7,
          gender = $8,
          phone = $9,
          emergency_contact_name = $10,
          emergency_contact_phone = $11,
          street = $12,
          city = $13,
          state = $14,
          country = $15,
          zip_code = $16,
          participant_rank = $17,
          email = $18,
          password_hash = $19,
          school_id = $20,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $21
        RETURNING *;
      `;
      const updateValues = [
        first_name,
        middle_name || null,
        last_name,
        birthdate,
        height_feet || null,
        height_inches || null,
        weight || null,
        gender,
        phone || null,
        emergency_contact_name || null,
        emergency_contact_phone || null,
        street || null,
        city || null,
        state || null,
        country || null,
        zip_code || null,
        participant_rank || null,
        email,
        passwordHash,
        school_id,
        id,
      ];
      const updatedRegistration = await client.query(updateQuery, updateValues);

      // Update divisions if provided
      if (divisions && Array.isArray(divisions)) {
        // Delete existing division associations
        await client.query('DELETE FROM registrations_divisions WHERE registration_id = $1', [id]);
        // Add new division associations
        for (const divisionId of divisions) {
          await addRegistrationDivision(id, divisionId, client);
        }
      }

      // Fetch updated divisions
      const updatedDivisions = await getDivisionsForRegistration(id, client);

      await client.query('COMMIT');
      res.json({
        ...updatedRegistration.rows[0],
        divisions: updatedDivisions,
      });
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Update registration error:', err.message);
    console.error('Stack trace:', err.stack);
    if (err.message.includes('duplicate key value violates unique constraint "registrations_email_key"')) {
      return res.status(409).json({ error: 'Email already exists' });
    }
    if (err.message === 'Registration not found') {
      return res.status(404).json({ error: err.message });
    }
    res.status(500).json({ error: 'Failed to update registration: ' + err.message });
  }
};

export const fetchAllRegistrations = async (req, res) => {
  try {
    const registrations = await getAllRegistrations();
    const registrationsWithDivisions = await Promise.all(
      registrations.map(async (reg) => {
        const divisions = await getDivisionsForRegistration(reg.id);
        return { ...reg, divisions };
      })
    );
    res.json(registrationsWithDivisions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchRegistrationByEmail = async (req, res) => {
  const { email } = req.params;
  try {
    const registration = await getRegistrationByEmail(email);
    if (!registration) {
      return res.status(404).json({ error: 'Registration not found' });
    }
    const divisions = await getDivisionsForRegistration(registration.id);
    res.json({ ...registration, divisions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchRegistrationById = async (req, res) => {
  const { id } = req.params;
  try {
    const registration = await getRegistrationById(id);
    if (!registration) {
      return res.status(404).json({ error: 'Registration not found' });
    }
    const divisions = await getDivisionsForRegistration(registration.id);
    res.json({ ...registration, divisions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateRegistrationStatusController = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  if (status === undefined) {
    return res.status(400).json({ error: 'Missing status field' });
  }
  try {
    const updated = await updateRegistrationStatus(id, status);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const addDivisionToRegistration = async (req, res) => {
  const { registration_id, division_id } = req.body;
  if (!registration_id || !division_id) {
    return res.status(400).json({ error: 'Missing registration_id or division_id' });
  }
  try {
    const relation = await addRegistrationDivision(registration_id, division_id);
    res.status(201).json(relation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchDivisionsForRegistration = async (req, res) => {
  const { registration_id } = req.params;
  try {
    const divisions = await getDivisionsForRegistration(registration_id);
    res.json(divisions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const removeDivisionFromRegistration = async (req, res) => {
  const { registration_id, division_id } = req.body;
  if (!registration_id || !division_id) {
    return res.status(400).json({ error: 'Missing registration_id or division_id' });
  }
  try {
    const relation = await removeRegistrationDivision(registration_id, division_id);
    res.json({ message: 'Division removed from registration', deleted: relation });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const validateRegistrationToken = async (req, res) => {
  const { token } = req.params;
  try {
    const school = await getRegistrationByToken(token);
    if (!school) {
      return res.status(404).json({ error: 'Invalid or expired token.' });
    }
    res.json({ school });
  } catch (err) {
    console.error('Error validating registration token:', err);
    res.status(500).json({ error: 'Internal server error.' });
  }
};