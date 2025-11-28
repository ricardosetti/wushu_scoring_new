import { getTournamentDetail, setTournamentDetail } from "../models/tournamentDetailsModel.js";

export const fetchTournamentDetails = async (req, res) => {
  try {
    const activeID = await getTournamentDetail("Active_ID");
    const onDeckID = await getTournamentDetail("OnDeck_ID");
    const judgeA1 = await getTournamentDetail("Judge_A1") ?? 0;
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
  
  if (!argument) {
    return res.status(400).json({ error: "Missing argument" });
  }

  // CRITICAL FIX: Convert null/undefined to 0 so the DB doesn't crash
  const safeValue = (value === null || value === undefined || value === "") ? 0 : value;

  try {
    const updatedDetail = await setTournamentDetail(argument, safeValue);
    res.json({ 
        message: `Tournament detail updated: ${argument} -> ${safeValue}`, 
        updated: updatedDetail 
    });
  } catch (err) {
    console.error("Error updating tournament details:", err);
    res.status(500).json({ error: err.message });
  }
};