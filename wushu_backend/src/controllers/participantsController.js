import {
  addParticipant,
  getParticipants,
  getParticipantById,
  updateParticipant,
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
  const { name, school_id, division } = req.body;
  if (!name || !division) {
    return res.status(400).json({ error: "Name and division are required" });
  }
  try {
    const participant = await addParticipant(name, school_id, division);
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

export const updateParticipantController = async (req, res) => { // Renamed from updateParticipant
  const { id } = req.params;
  const { name, school_id, division } = req.body;
  if (!name || !division) {
    return res.status(400).json({ error: "Name and division are required" });
  }
  try {
    const participant = await updateParticipant(id, name, school_id, division);
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
