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
import { addParticipantDivision } from '../models/participantModel.js';

// --- Validation Helpers ---
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

// --- Controllers ---

export const createRegistration = async (req, res) => {
  try {
    const validationError = validateRegistrationData(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    const { password, divisions, tournament_id, ...registrationData } = req.body;

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
      // We pass the client so it participates in the transaction
      const registration = await addRegistration(
        {
          ...registrationData,
          password_hash: passwordHash,
          tournament_id: tournament_id || 1, // Default to legacy tournament if not provided
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
    if (err.message.includes('unique constraint') || err.message.includes('registrations_email_key')) {
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

    if (gender && !['M', 'F', 'O'].includes(gender)) {
      return res.status(400).json({ error: 'Invalid gender value. Must be M, F, or O.' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const existingRegistration = await client.query('SELECT * FROM registrations WHERE id = $1', [id]);
      if (existingRegistration.rows.length === 0) {
        throw new Error('Registration not found');
      }

      if (email !== existingRegistration.rows[0].email) {
        const emailCheck = await client.query('SELECT id FROM registrations WHERE email = $1 AND id != $2', [email, id]);
        if (emailCheck.rows.length > 0) {
          throw new Error('Email already exists');
        }
      }

      let passwordHash = existingRegistration.rows[0].password_hash;
      if (password) {
        const saltRounds = 10;
        passwordHash = await bcrypt.hash(password, saltRounds);
      }

      const updateQuery = `
        UPDATE registrations
        SET
          first_name = $1, middle_name = $2, last_name = $3, birthdate = $4,
          height_feet = $5, height_inches = $6, weight = $7, gender = $8,
          phone = $9, emergency_contact_name = $10, emergency_contact_phone = $11,
          street = $12, city = $13, state = $14, country = $15, zip_code = $16,
          participant_rank = $17, email = $18, password_hash = $19, school_id = $20,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $21
        RETURNING *;
      `;
      const updateValues = [
        first_name, middle_name || null, last_name, birthdate,
        height_feet || null, height_inches || null, weight || null, gender,
        phone || null, emergency_contact_name || null, emergency_contact_phone || null,
        street || null, city || null, state || null, country || null, zip_code || null,
        participant_rank || null, email, passwordHash, school_id, id,
      ];
      const updatedRegistration = await client.query(updateQuery, updateValues);

      if (divisions && Array.isArray(divisions)) {
        await client.query('DELETE FROM registrations_divisions WHERE registration_id = $1', [id]);
        for (const divisionId of divisions) {
          await addRegistrationDivision(id, divisionId, client);
        }
      }

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
    if (err.message.includes('unique constraint') || err.message.includes('registrations_email_key')) {
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

export const approveRegistrationController = async (req, res) => {
  const { id } = req.params; // Registration ID

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Fetch the Registration Data
    const regResult = await client.query(`
      SELECT * FROM registrations WHERE id = $1
    `, [id]);

    if (regResult.rows.length === 0) {
      throw new Error("Registration not found");
    }
    const reg = regResult.rows[0];

    if (reg.status === 1) {
      throw new Error("Registration is already approved");
    }

    // 2. Create the Participant (Copying data)
    const participantResult = await client.query(`
      INSERT INTO participants (
        tournament_id, school_id, 
        first_name, middle_name, last_name, 
        birthdate, height_feet, height_inches, weight, gender, 
        phone, emergency_contact_name, emergency_contact_phone, 
        street, city, state, country, zip_code, participant_rank
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
      RETURNING id
    `, [
      reg.tournament_id, reg.school_id,
      reg.first_name, reg.middle_name, reg.last_name,
      reg.birthdate, reg.height_feet, reg.height_inches, reg.weight, reg.gender,
      reg.phone, reg.emergency_contact_name, reg.emergency_contact_phone,
      reg.street, reg.city, reg.state, reg.country, reg.zip_code, reg.participant_rank
    ]);

    const newParticipantId = participantResult.rows[0].id;

    // 3. Fetch Requested Divisions
    const divResult = await client.query(`
      SELECT division_id FROM registrations_divisions WHERE registration_id = $1
    `, [id]);

    // 4. Link Participant to Divisions (tournament_participants)
    for (const row of divResult.rows) {
      await client.query(`
        INSERT INTO tournament_participants (participant_id, division_id, tournament_id)
        VALUES ($1, $2, $3)
      `, [newParticipantId, row.division_id, reg.tournament_id]);
    }

    // 5. Mark Registration as Approved (Status 1)
    // We also optionally link the participant_id back to the registration if you added that column, 
    // but for now just status is enough.
    await client.query(`
      UPDATE registrations SET status = 1, updated_at = CURRENT_TIMESTAMP WHERE id = $1
    `, [id]);

    await client.query('COMMIT');
    
    res.json({ 
      message: "Registration approved and participant created", 
      participant_id: newParticipantId 
    });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error("Approve Error:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
};