import { getAllScores, addScore, getLatestScore, getScoresForParticipant } from "../models/scoreModel.js";
import pool from "../models/db.js";

export const fetchScores = async (req, res) => {
  try {
    const scores = await getAllScores();
    res.json(scores);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createScore = async (req, res) => {
  const { participant_id, judge, score } = req.body;
  if (!participant_id || !judge || score === undefined || score === null || isNaN(score)) {
    return res.status(400).json({ error: "Missing or invalid fields (participant_id, judge, score)" });
  }
  try {
    // Fetch the active division
    const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
    const division_id = activeDivisionResult.rows[0]?.id || null;
    if (!division_id) {
      return res.status(400).json({ error: "No active division set" });
    }
    const newScore = await addScore(participant_id, judge, score, division_id);
    req.app.get("io").emit("scoreUpdated", { participantId: participant_id, judge, score, division_id });
    res.status(201).json(newScore);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchLatestScore = async (req, res) => {
  const { participant_id, judge } = req.query;
  if (!participant_id || !judge) {
    return res.status(400).json({ error: "Missing participant_id or judge" });
  }
  try {
    const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
    const division_id = activeDivisionResult.rows[0]?.id || null;
    if (!division_id) {
      return res.status(400).json({ error: "No active division set" });
    }
    const latestScore = await getLatestScore(participant_id, judge, division_id);
    res.json(latestScore ? latestScore : { score: 5.0 }); // Default to 5.0 if no score found
  } catch (err) {
    console.error("Error fetching latest score:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const fetchParticipantScores = async (req, res) => {
  const { participant_id } = req.params;
  try {
    const activeDivisionResult = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
    const division_id = activeDivisionResult.rows[0]?.id || null;
    if (!division_id) {
      return res.status(400).json({ error: "No active division set" });
    }
    const scores = await getScoresForParticipant(participant_id, division_id);
    res.json(scores);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};