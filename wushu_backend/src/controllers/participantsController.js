import {
  addParticipant,
  getParticipants,
  getParticipantById,
  updateParticipant,
  addParticipantDivision,
  removeParticipantDivision,
  getParticipantDivisions,
  deleteParticipant,
} from "../models/participantModel.js";

export const fetchParticipants = async (req, res) => {
  try {
    const participants = await getParticipants();
    res.json(participants);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createParticipant = async (req, res) => {
  const {
    first_name,
    middle_name,
    last_name,
    school_id,
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
  } = req.body;
  if (!first_name || !last_name) {
    return res.status(400).json({ error: "First name and last name are required" });
  }
  try {
    const participant = await addParticipant(
      first_name,
      middle_name,
      last_name,
      school_id,
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
      participant_rank
    );
    res.status(201).json(participant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


export const fetchParticipantById = async (req, res) => {
  const { id } = req.params;
  try {
    const participant = await getParticipantById(id);
    if (!participant) {
      return res.status(404).json({ error: "Participant not found" });
    }
    res.json(participant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateParticipantController = async (req, res) => {
  const { id } = req.params;
  const {
    first_name,
    middle_name,
    last_name,
    school_id,
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
  } = req.body;
  if (!first_name || !last_name) {
    return res.status(400).json({ error: "First name and last name are required" });
  }
  try {
    const participant = await updateParticipant(
      id,
      first_name,
      middle_name,
      last_name,
      school_id,
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
      participant_rank
    );
    if (!participant) {
      return res.status(404).json({ error: "Participant not found" });
    }
    res.json(participant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const deleteParticipantController = async (req, res) => {
  const { id } = req.params;
  try {
    const participant = await deleteParticipant(id);
    if (!participant) {
      return res.status(404).json({ error: "Participant not found" });
    }
    res.json({ message: "Participant deleted successfully", deleted: participant });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const addParticipantDivisionController = async (req, res) => {
  const { participant_id, division_id } = req.body;
  if (!participant_id || !division_id) {
    return res.status(400).json({ error: "Participant ID and Division ID are required" });
  }
  try {
    const relation = await addParticipantDivision(participant_id, division_id);
    res.status(201).json(relation);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const removeParticipantDivisionController = async (req, res) => {
  console.log('DELETE /participants/division, req.body:', req.body);
  const { participant_id, division_id } = req.body;
  if (!participant_id || !division_id) {
    return res.status(400).json({ error: "Participant ID and Division ID are required" });
  }
  try {
    const relation = await removeParticipantDivision(participant_id, division_id);
    if (!relation) {
      return res.status(404).json({ error: "Relation not found" });
    }
    res.json({ message: "Division removed from participant", deleted: relation });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchParticipantDivisions = async (req, res) => {
  const { participant_id } = req.params;
  try {
    const divisions = await getParticipantDivisions(participant_id);
    res.json(divisions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};