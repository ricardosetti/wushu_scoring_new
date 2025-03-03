import { getAllParticipants, addParticipant, getParticipantById } from "../models/participantModel.js";

export const fetchParticipants = async (req, res) => {
  try {
    const participants = await getAllParticipants();
    res.json(participants);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createParticipant = async (req, res) => {
  const { name, school, division } = req.body;
  try {
    const newParticipant = await addParticipant(name, school, division);
    res.status(201).json(newParticipant);
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
