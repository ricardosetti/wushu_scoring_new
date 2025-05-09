// src/controllers/registrationController.js (updated snippet for createRegistration)
import bcrypt from 'bcrypt';
import pool from '../models/db.js'; // Import pool for transactions
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
  const requiredFields = ['first_name', 'last_name', 'birthdate', 'gender', 'school_id', 'email', 'password'];
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
      const associatedDivisions = await getDivisionsForRegistration(registration.id);

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
    if (err.message.includes('duplicate key value violates unique constraint "registrations_email_key"')) {
      return res.status(409).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: err.message });
  }
};

// ... (rest of the controller remains the same)

export const fetchAllRegistrations = async (req, res) => {
  try {
    const registrations = await getAllRegistrations();
    // Optionally fetch divisions for each registration
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