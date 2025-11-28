import { getScoreComponents, saveFinalResult } from "../models/scoreModel.js";
import pool from "../models/db.js";

// 1. CALCULATE AND PUBLISH (No changes here)
export const publishParticipantScores = async (req, res) => {
  const { participant_id, division_id } = req.body;

  try {
    const { scores, deductions } = await getScoreComponents(participant_id, division_id);

    const aScores = scores.filter(s => s.judge.startsWith('A')).map(s => parseFloat(s.score));
    const avgA = aScores.length ? aScores.reduce((a, b) => a + b, 0) / aScores.length : 0;

    const bScores = scores.filter(s => s.judge.startsWith('B')).map(s => parseFloat(s.score));
    const avgB = bScores.length ? bScores.reduce((a, b) => a + b, 0) / bScores.length : 0;

    const totalDeductions = deductions.reduce((sum, d) => sum + parseFloat(d.deduction_value), 0);

    let finalScore = (avgA + avgB) - totalDeductions;
    finalScore = Math.max(0, parseFloat(finalScore.toFixed(2))); 

    const partRes = await pool.query("SELECT tournament_id FROM participants WHERE id = $1", [participant_id]);
    const tournamentId = partRes.rows[0]?.tournament_id;

    const savedResult = await saveFinalResult({
      tournament_id: tournamentId,
      participant_id,
      division_id,
      total_score: finalScore,
      breakdown: {
        avg_a: avgA.toFixed(2),
        avg_b: avgB.toFixed(2),
        deductions: totalDeductions.toFixed(2),
        raw_scores: scores
      }
    });

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

// 2. FETCH SCORES (Updated for Unique Deduction Codes)
export const fetchPublishedScores = async (req, res) => {
  const { participant_id } = req.params;
  const { division_id } = req.query;

  try {
    let finalDivisionId = division_id ? parseInt(division_id) : null;
    
    if (!finalDivisionId) {
      const activeRes = await pool.query("SELECT id FROM divisions WHERE active = TRUE LIMIT 1");
      finalDivisionId = activeRes.rows[0]?.id;
    }

    if (!finalDivisionId) return res.json({ scores: [], deduction_codes: [] });

    const result = await pool.query(`
      SELECT score_breakdown 
      FROM tournament_results 
      WHERE participant_id = $1 AND division_id = $2
    `, [participant_id, finalDivisionId]);

    if (result.rows.length === 0) {
      return res.json({ scores: [], deduction_codes: [] });
    }

    const breakdown = result.rows[0].score_breakdown;
    
    const finalScores = [
      { judge: 'FinalA', score: breakdown.avg_a },
      { judge: 'FinalB', score: breakdown.avg_b },
      { judge: 'Final', score: (parseFloat(breakdown.avg_a) + parseFloat(breakdown.avg_b) - parseFloat(breakdown.deductions)).toFixed(2) }
    ];

    const allScores = [...(breakdown.raw_scores || []), ...finalScores];

    // UPDATED QUERY: Added DISTINCT to ensure unique codes
    const dedRes = await pool.query(`
      SELECT DISTINCT d.deduction_code 
      FROM participant_deductions pd
      JOIN deductions d ON pd.deduction_id = d.deduction_id
      WHERE pd.participant_id = $1 AND pd.division_id = $2
      ORDER BY d.deduction_code ASC
    `, [participant_id, finalDivisionId]);

    res.json({
      scores: allScores,
      deduction_codes: dedRes.rows.map(r => r.deduction_code)
    });

  } catch (err) {
    console.error("Error fetching published scores:", err);
    res.status(500).json({ error: err.message });
  }
};