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
import { createUser, getUserByEmail } from '../models/userModel.js'; // Import the User Model
import {
  addRegistrationDivision,
  getDivisionsForRegistration,
  removeRegistrationDivision,
} from '../models/registrationDivisionsModel.js';

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

// --- Controllers ---

export const createRegistration = async (req, res) => {
  try {
    // 1. Validate Input
    const validationError = validateRegistrationData(req.body);
    if (validationError) {
      return res.status(400).json({ error: validationError });
    }

    const {
      email, password, first_name, middle_name, last_name, birthdate,
      gender, height_feet, height_inches, weight, phone,
      street, city, state, country, zip_code, emergency_contact_name, emergency_contact_phone,
      school_id, participant_rank, tournament_id, divisions
    } = req.body;

    if (!tournament_id) {
        return res.status(400).json({ error: 'Tournament ID is required.' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN'); // Start Transaction

      // 2. Handle User Identity (Create or Fetch)
      let user = await getUserByEmail(email);
      let userId = null;

      if (!user) {
        // New User: Hash password and create account
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        
        user = await createUser({
          email, password: passwordHash, role: 'participant',
          first_name, middle_name, last_name, birthdate, gender,
          height_feet, height_inches, weight, phone,
          emergency_contact_name, emergency_contact_phone,
          street, city, state, country, zip_code
        });
        userId = user.id;
      } else {
        // Existing User: Check password if provided (optional check for security)
        // For registration flow, we'll proceed using the existing user ID.
        // Ideally, we'd require login first, but for a smooth "Guest Checkout" feel:
        userId = user.id;
        
        // Optional: Check if they are already registered for THIS tournament
        const existingReg = await client.query(
            "SELECT id FROM registrations WHERE user_id = $1 AND tournament_id = $2",
            [userId, tournament_id]
        );
        if (existingReg.rows.length > 0) {
            throw new Error("This email is already registered for this tournament.");
        }
      }

      // 3. Create Registration (Linked to User)
      const registration = await addRegistration({
        user_id: userId,
        tournament_id,
        school_id,
        participant_rank
      }, client);

      // 4. Add Divisions
      if (divisions && Array.isArray(divisions)) {
          for (const divisionId of divisions) {
            await addRegistrationDivision(registration.id, divisionId, client);
          }
      }

      // 5. Fetch associated divisions for response
      const associatedDivisions = await getDivisionsForRegistration(registration.id, client);

      await client.query('COMMIT');
      
      res.status(201).json({
        ...registration,
        divisions: associatedDivisions,
        message: "Registration successful"
      });

    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Registration error:', err.message);
    if (err.message.includes('already registered')) {
        return res.status(409).json({ error: err.message });
    }
    res.status(500).json({ error: 'Failed to create registration: ' + err.message });
  }
};

// ... Keep existing Getters (fetchAllRegistrations, etc.) ...
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

export const updateRegistration = async (req, res) => {
    // NOTE: This needs a refactor later to update the USER table for profile info
    // and REGISTRATION table for tournament info.
    // For now, keeping it simple or leaving as placeholder if you use the Profile page instead.
    res.status(501).json({ error: "Update via specific endpoints recommended" });
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

// Approve Registration (Promote to Participant)
export const approveRegistrationController = async (req, res) => {
  const { id } = req.params; // Registration ID

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Fetch the Registration Data + User Data
    const regResult = await client.query(`
      SELECT r.*, u.* FROM registrations r
      JOIN users u ON r.user_id = u.id
      WHERE r.id = $1
    `, [id]);

    if (regResult.rows.length === 0) {
      throw new Error("Registration not found");
    }
    const data = regResult.rows[0];

    if (data.status === 1) {
      throw new Error("Registration is already approved");
    }

    // 2. Create the Participant (using User data)
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
      data.tournament_id, data.school_id,
      data.first_name, data.middle_name, data.last_name,
      data.birthdate, data.height_feet, data.height_inches, data.weight, data.gender,
      data.phone, data.emergency_contact_name, data.emergency_contact_phone,
      data.street, data.city, data.state, data.country, data.zip_code, data.participant_rank
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
      `, [newParticipantId, row.division_id, data.tournament_id]);
    }

    // 5. Mark Registration as Approved
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

export const registerAsMember = async (req, res) => {
  try {
    const userId = req.user.userId; // Extracted from JWT Token
    const { tournament_id, school_id, participant_rank, divisions } = req.body;

    if (!tournament_id || !school_id) {
      return res.status(400).json({ error: 'Tournament and School are required.' });
    }

    if (!divisions || divisions.length === 0) {
      return res.status(400).json({ error: 'At least one division is required.' });
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // 1. Create Registration linked to existing User ID
      const registration = await addRegistration({
        user_id: userId,
        tournament_id,
        school_id,
        participant_rank
      }, client);

      // 2. Add Divisions
      for (const divisionId of divisions) {
        await addRegistrationDivision(registration.id, divisionId, client);
      }

      // 3. Return success
      const associatedDivisions = await getDivisionsForRegistration(registration.id, client);
      
      await client.query('COMMIT');
      res.status(201).json({ ...registration, divisions: associatedDivisions });

    } catch (err) {
      await client.query('ROLLBACK');
      // Check for duplicate registration error
      if (err.message.includes('already registered')) {
        return res.status(409).json({ error: 'You are already registered for this tournament.' });
      }
      throw err;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Member registration error:', err.message);
    res.status(500).json({ error: err.message });
  }
};