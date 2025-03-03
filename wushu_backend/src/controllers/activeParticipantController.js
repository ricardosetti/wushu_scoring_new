import { getActiveParticipant, setActiveParticipant } from "../models/activeParticipantModel.js";

export const fetchActiveParticipant = async (req, res) => {
  try {
    const participant = await getActiveParticipant();
    res.json(participant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateActiveParticipant = async (req, res) => {
  const { participant_id } = req.body;
  try {
    const updatedParticipant = await setActiveParticipant(participant_id);
    res.json(updatedParticipant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
