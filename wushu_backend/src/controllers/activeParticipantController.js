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
  if (!participant_id) {
    return res.status(400).json({ error: "Missing participant_id" });
  }
  try {
    const updatedParticipant = await setActiveParticipant(participant_id);
    if (!updatedParticipant) {
      return res.status(404).json({ error: "Participant not found" });
    }
    // Update tournament_details to keep in sync
    await setTournamentDetail("Active_ID", participant_id); // Import setTournamentDetail
    req.app.get('io').emit('updateTournamentDetails', {
      Active_ID: participant_id,
      OnDeck_ID: await getTournamentDetail("OnDeck_ID"),
      Judge_A1: await getTournamentDetail("Judge_A1") ?? 0,
      Judge_A2: await getTournamentDetail("Judge_A2") ?? 0,
      Judge_B1: await getTournamentDetail("Judge_B1") ?? 0,
      Judge_B2: await getTournamentDetail("Judge_B2") ?? 0,
    });
    res.json(updatedParticipant);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
