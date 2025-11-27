import { publishScores, getPublishedScoresForParticipant } from "../models/publishedScoresModel.js";
import { getScoreComponents, saveFinalResult } from "../models/scoreModel.js";
import pool from "../models/db.js";

export const publishParticipantScores = async (req, res) => {
  const { participant_id, division_id } = req.body;

  try {
    // 1. Get Raw Data
    const { scores, deductions } = await getScoreComponents(participant_id, division_id);

    // 2. SCORING LOGIC (Centralized here)
    // Group A (Quality)
    const aScores = scores.filter(s => s.judge.startsWith('A')).map(s => parseFloat(s.score));
    const avgA = aScores.length ? aScores.reduce((a, b) => a + b, 0) / aScores.length : 0;

    // Group B (Overall)
    const bScores = scores.filter(s => s.judge.startsWith('B')).map(s => parseFloat(s.score));
    const avgB = bScores.length ? bScores.reduce((a, b) => a + b, 0) / bScores.length : 0;

    // Deductions
    const totalDeductions = deductions.reduce((sum, d) => sum + parseFloat(d.deduction_value), 0);

    // Final Calculation
    let finalScore = (avgA + avgB) - totalDeductions;
    finalScore = Math.max(0, parseFloat(finalScore.toFixed(2))); // Ensure no negative scores

    // 3. Get Tournament ID (Context)
    const partRes = await pool.query("SELECT tournament_id FROM participants WHERE id = $1", [participant_id]);
    const tournamentId = partRes.rows[0]?.tournament_id;

    // 4. Save to Results Table
    const savedResult = await saveFinalResult({
      tournament_id: tournamentId,
      participant_id,
      division_id,
      total_score: finalScore,
      breakdown: {
        avg_a: avgA.toFixed(2),
        avg_b: avgB.toFixed(2),
        deductions: totalDeductions.toFixed(2),
        raw_scores: scores // Save raw judge inputs for history
      }
    });

    // 5. Notify Frontend (Socket)
    req.app.get("io").emit("scorePublished", {
      participantId: participant_id,
      division_id,
      finalScore,
      breakdown: savedResult.score_breakdown
    });

    res.status(201).json(savedResult);

  } catch (err) {
    console.error("Publish Error:", err);
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