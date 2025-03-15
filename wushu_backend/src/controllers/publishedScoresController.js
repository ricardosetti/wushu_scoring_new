import { publishScores, getPublishedScoresForParticipant } from "../models/publishedScoresModel.js";
import pool from "../models/db.js";

export const publishParticipantScores = async (req, res) => {
  const { participant_id, scores } = req.body;
  if (!participant_id || !scores || !Array.isArray(scores)) {
    return res.status(400).json({ error: "Missing or invalid fields (participant_id, scores)" });
  }
  try {
    const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
    const division_id = activeDivisionResult.rows[0]?.id || null;
    if (!division_id) {
      return res.status(400).json({ error: "No active division set" });
    }
    const published = await publishScores(participant_id, scores, division_id);
    req.app.get("io").emit("scorePublished", {
      participantId: participant_id,
      scores: published,
      division_id,
    });
    res.status(201).json(published);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchPublishedScores = async (req, res) => {
  const { participant_id } = req.params;
  try {
    const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
    const division_id = activeDivisionResult.rows[0]?.id || null;
    if (!division_id) {
      return res.status(400).json({ error: "No active division set" });
    }
    const data = await getPublishedScoresForParticipant(participant_id, division_id);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};