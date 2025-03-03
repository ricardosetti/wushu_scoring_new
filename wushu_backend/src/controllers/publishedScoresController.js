import { publishScores, getPublishedScoresForParticipant } from "../models/publishedScoresModel.js";

export const publishParticipantScores = async (req, res) => {
    const { participant_id, scores } = req.body;
  
    try {
      const published = await publishScores(participant_id, scores);
      res.status(201).json(published);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  export const fetchPublishedScores = async (req, res) => {
    const { participant_id } = req.params;
  
    try {
      const data = await getPublishedScoresForParticipant(participant_id);
      res.json(data);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };