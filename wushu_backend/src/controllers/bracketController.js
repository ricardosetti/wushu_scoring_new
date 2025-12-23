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


// NEW: Simulate (Preview) Brackets based on criteria
export const simulateBrackets = async (req, res) => {
  const { tournament_id, criteria } = req.body;
  // criteria = { useDivision: true, useAge: false, useSex: false, useRank: false }

  if (!tournament_id) return res.status(400).json({ error: "Tournament ID required" });

  try {
    // 1. Fetch ALL APPROVED REGISTRATIONS for this tournament
    // We join with users to get names/DOB, and schools for school name
    const result = await pool.query(`
      SELECT r.id as registration_id, r.user_id, r.participant_id,
             u.first_name, u.last_name, u.gender, u.birthdate,
             r.participant_rank, r.age_at_event, r.weight, r.height_feet, r.height_inches,
             s.school_name, r.school_id,
             d.id as division_id, d.division_name
      FROM registrations r
      JOIN users u ON r.user_id = u.id
      JOIN registrations_divisions rd ON r.id = rd.registration_id
      JOIN divisions d ON rd.division_id = d.id
      LEFT JOIN schools s ON r.school_id = s.id
      WHERE r.tournament_id = $1 AND r.status = 1 -- Only approved registrations
    `, [tournament_id]);

    const allEntries = result.rows;

    // 2. Grouping Logic (Same as before, but using registration data fields)
    const groups = {};

    for (const entry of allEntries) {
      let groupKey = entry.division_name; 
      let groupNameParts = [entry.division_name];
      // Store IDs needed to create the real bracket later
      let meta = { 
        division_id: entry.division_id 
      }; 

      if (criteria.useSex) {
        const sex = entry.gender === 'M' ? 'Male' : (entry.gender === 'F' ? 'Female' : 'Mixed');
        groupKey += `_${sex}`;
        groupNameParts.push(sex);
        meta.sex = entry.gender;
      }

      if (criteria.useRank) {
        const rank = entry.participant_rank || 'Unknown';
        groupKey += `_${rank}`;
        groupNameParts.push(rank);
        meta.rank = rank;
      }

      if (criteria.useAge) {
        let age = entry.age_at_event;
        // Fallback calculation if age_at_event is missing
        if (!age && entry.birthdate) {
            const birth = new Date(entry.birthdate);
            const today = new Date(); 
            let a = today.getFullYear() - birth.getFullYear();
            const m = today.getMonth() - birth.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) a--;
            age = a;
        }
        
        let ageGroup = 'Adult';
        if (age < 8) ageGroup = 'Under 7';
        else if (age <= 12) ageGroup = '8-12';
        else if (age <= 17) ageGroup = '13-17';
        else if (age <= 35) ageGroup = '18-35';
        else ageGroup = '36+';

        groupKey += `_${ageGroup}`;
        groupNameParts.push(ageGroup);
        meta.age_group = ageGroup;
      }

      if (!groups[groupKey]) {
        groups[groupKey] = {
          name: groupNameParts.join(' - '),
          participants: [],
          meta
        };
      }
      // Push the full entry so we have registration_id and user info
      groups[groupKey].participants.push(entry);
    }

    const proposedBrackets = Object.values(groups).map(g => ({
      name: g.name,
      participantCount: g.participants.length,
      participants: g.participants,
      meta: g.meta
    }));

    proposedBrackets.sort((a, b) => a.name.localeCompare(b.name));

    res.json(proposedBrackets);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};

export const commitBrackets = async (req, res) => {
  const { tournament_id, brackets } = req.body;
  // brackets = [{ name, meta, participants: [ {registration_id, user_id, ...} ] }]

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const results = [];

    for (const b of brackets) {
      // 1. Create the Bracket Record
      const bracketRes = await client.query(
        `INSERT INTO brackets (tournament_id, division_id, bracket_type, name, settings)
         VALUES ($1, $2, 'single_elimination', $3, $4)
         RETURNING id`,
        [tournament_id, b.meta.division_id, b.name, JSON.stringify(b.meta)]
      );
      const bracketId = bracketRes.rows[0].id;

      // 2. Process Participants for this Bracket
      const participantIds = [];
      
      for (const reg of b.participants) {
        let pId = reg.participant_id;

        // If this registration doesn't have a participant_id yet, create one!
        if (!pId) {
          // Check if we already created one in this transaction (user might be in multiple brackets)
          // This query checks DB to see if we already promoted this registration
          const check = await client.query('SELECT participant_id FROM registrations WHERE id = $1', [reg.registration_id]);
          if (check.rows[0]?.participant_id) {
             pId = check.rows[0].participant_id;
          } else {
             // Create new Participant from Registration data
             const newP = await client.query(`
               INSERT INTO participants (
                 tournament_id, school_id, 
                 first_name, last_name, gender, birthdate, 
                 participant_rank, weight, height_feet, height_inches,
                 phone, emergency_contact_name, emergency_contact_phone,
                 street, city, state, country, zip_code
               ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
               RETURNING id
             `, [
               tournament_id, reg.school_id,
               reg.first_name, reg.last_name, reg.gender, reg.birthdate,
               reg.participant_rank, reg.weight, reg.height_feet, reg.height_inches,
               null, null, null, null, null, null, null, null // Address/Contact info could be pulled from Users table if needed
             ]);
             pId = newP.rows[0].id;

             // Link back to Registration
             await client.query('UPDATE registrations SET participant_id = $1 WHERE id = $2', [pId, reg.registration_id]);
          }
        }
        
        // Ensure the participant is linked to this division in tournament_participants
        await client.query(`
          INSERT INTO tournament_participants (tournament_id, participant_id, division_id)
          VALUES ($1, $2, $3)
          ON CONFLICT DO NOTHING
        `, [tournament_id, pId, b.meta.division_id]);

        participantIds.push(pId);
      }

      // 3. Generate Matches (Simple Pairings)
      let matchNum = 1;
      for (let i = 0; i < participantIds.length; i += 2) {
        await client.query(
          `INSERT INTO matches (bracket_id, round_number, match_number, participant1_id, participant2_id)
           VALUES ($1, 1, $2, $3, $4)`,
          [bracketId, matchNum++, participantIds[i], participantIds[i+1] || null]
        );
      }
      results.push({ id: bracketId, name: b.name });
    }

    await client.query('COMMIT');
    res.json({ message: `${results.length} brackets created. Participants promoted.`, results });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
};