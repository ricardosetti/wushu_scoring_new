import { getAllScores, addScore, getLatestScore, getScoresForParticipant } from "../models/scoreModel.js";

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
  try {
    const newScore = await addScore(participant_id, judge, score);
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
    const latestScore = await getLatestScore(participant_id, judge);
    res.json(latestScore ? latestScore : { score: 5.0 }); // Default to 5.0 if no score found
  } catch (err) {
    console.error("Error fetching latest score:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

export const fetchParticipantScores = async (req, res) => {
  const { participant_id } = req.params;
  try {
    const scores = await getScoresForParticipant(participant_id);
    res.json(scores);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};