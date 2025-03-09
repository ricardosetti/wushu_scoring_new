import { getTournamentDetail, setTournamentDetail } from "../models/tournamentDetailsModel.js";

export const fetchTournamentDetails = async (req, res) => {
  try {
    const activeID = await getTournamentDetail("Active_ID");
    const onDeckID = await getTournamentDetail("OnDeck_ID");
    const judgeA1 = await getTournamentDetail("Judge_A1") ?? 0; // Default to off
    const judgeA2 = await getTournamentDetail("Judge_A2") ?? 0;
    const judgeB1 = await getTournamentDetail("Judge_B1") ?? 0;
    const judgeB2 = await getTournamentDetail("Judge_B2") ?? 0;
    res.json({
      Active_ID: activeID,
      OnDeck_ID: onDeckID,
      Judge_A1: judgeA1,
      Judge_A2: judgeA2,
      Judge_B1: judgeB1,
      Judge_B2: judgeB2,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateTournamentDetails = async (req, res) => {
  const { argument, value } = req.body;
  if (!argument || value === undefined) {
    return res.status(400).json({ error: "Missing argument or value" });
  }
  try {
    await setTournamentDetail(argument, value);
    res.json({ message: `Tournament detail updated: ${argument} -> ${value}` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};