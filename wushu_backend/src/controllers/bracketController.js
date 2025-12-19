import { createBracket, getBrackets, createMatches } from "../models/bracketModel.js";
import pool from "../models/db.js";

// Fetch Brackets
export const fetchBrackets = async (req, res) => {
  const { tournament_id, division_id } = req.query;
  if (!tournament_id) return res.status(400).json({ error: "Tournament ID required" });

  try {
    const brackets = await getBrackets(tournament_id, division_id);
    res.json(brackets);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// NEW: Fetch Participants for Bracket (Tournament + Division)
export const fetchBracketParticipants = async (req, res) => {
  const { tournament_id, division_id } = req.query;
  
  if (!tournament_id || !division_id) {
    return res.status(400).json({ error: "Tournament ID and Division ID are required" });
  }

  try {
    const result = await pool.query(`
      SELECT p.id, p.first_name, p.last_name, p.participant_rank,
             s.school_name
      FROM participants p
      JOIN tournament_participants tp ON p.id = tp.participant_id
      LEFT JOIN schools s ON p.school_id = s.id
      WHERE p.tournament_id = $1 AND tp.division_id = $2
      ORDER BY p.last_name, p.first_name
    `, [tournament_id, division_id]);
    
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Generate a Bracket (The "Brain")
export const generateBracket = async (req, res) => {
  const { tournament_id, division_id, bracket_type, name } = req.body;

  if (!tournament_id || !division_id || !bracket_type) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // 1. Get Participants for this Tournament & Division
    // Note: We need to filter participants who are actually registered for THIS tournament
    const partsRes = await pool.query(`
      SELECT p.id 
      FROM participants p
      JOIN tournament_participants tp ON p.id = tp.participant_id
      WHERE p.tournament_id = $1 AND tp.division_id = $2
    `, [tournament_id, division_id]);
    
    const participants = partsRes.rows.map(r => r.id);
    
    if (participants.length < 2) {
      return res.status(400).json({ error: "Not enough participants to generate a bracket." });
    }

    // 2. Create Bracket Record
    const bracket = await createBracket({ tournament_id, division_id, bracket_type, name });

    // 3. Logic: Single Elimination Generator (Simple Version)
    // This pairs participants sequentially (1vs2, 3vs4).
    // A full implementation would handle seeding and byes.
    const matches = [];
    let matchNum = 1;
    
    for (let i = 0; i < participants.length; i += 2) {
      matches.push({
        bracket_id: bracket.id,
        round_number: 1, // Round 1
        match_number: matchNum++,
        participant1_id: participants[i],
        participant2_id: participants[i+1] || null, // Bye if odd number
        next_match_id: null 
      });
    }

    await createMatches(matches);

    res.status(201).json({ message: "Bracket generated", bracket });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};