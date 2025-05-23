import { publishScores, getPublishedScoresForParticipant } from "../models/publishedScoresModel.js";
import pool from "../models/db.js";

export const publishParticipantScores = async (req, res) => {
  const { participant_id, scores, division_id } = req.body;
  if (!participant_id || !scores || !Array.isArray(scores)) {
    return res.status(400).json({ error: "Missing or invalid fields (participant_id, scores)" });
  }
  try {
    // Use division_id from the request if provided; otherwise, fall back to active division
    let finalDivisionId = division_id;
    if (!finalDivisionId) {
      const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
      finalDivisionId = activeDivisionResult.rows[0]?.id || null;
      if (!finalDivisionId) {
        return res.status(400).json({ error: "No active division set and no division_id provided" });
      }
    }
    const published = await publishScores(participant_id, scores, finalDivisionId);
    req.app.get("io").emit("scorePublished", {
      participantId: participant_id,
      scores: published,
      division_id: finalDivisionId,
    });
    res.status(201).json(published);
  } catch (err) {
    console.error("Error publishing scores:", err.stack);
    res.status(500).json({ error: err.message });
  }
};

export const fetchPublishedScores = async (req, res) => {
  const { participant_id } = req.params;
  const { division_id } = req.query; // Allow division_id to be specified in query
  try {
    // Use division_id from query if provided; otherwise, fall back to active division
    let finalDivisionId = division_id ? parseInt(division_id) : null;
    if (!finalDivisionId) {
      const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
      finalDivisionId = activeDivisionResult.rows[0]?.id || null;
      if (!finalDivisionId) {
        return res.status(400).json({ error: "No active division set and no division_id provided" });
      }
    }
    const data = await getPublishedScoresForParticipant(participant_id, finalDivisionId);
    res.json(data);
  } catch (err) {
    console.error("Error fetching published scores:", err.stack);
    res.status(500).json({ error: err.message });
  }
};