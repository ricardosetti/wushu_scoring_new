import {
  getTournaments,
  getTournamentById,
  addTournament,
  updateTournament,
  deleteTournament,
} from "../models/tournamentModel.js";

export const fetchTournaments = async (req, res) => {
  try {
    const tournaments = await getTournaments();
    res.json(tournaments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const fetchTournamentById = async (req, res) => {
  const { id } = req.params;
  try {
    const tournament = await getTournamentById(id);
    if (!tournament) {
      return res.status(404).json({ error: "Tournament not found" });
    }
    res.json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createTournament = async (req, res) => {
  const {
    tournament_title,
    tournament_start_date,
    tournament_end_date,
    tournament_hours,
    tournament_contact,
    tournament_address,
    tournament_city,
    tournament_state,
    tournament_country,
    tournament_email,
    is_active // <--- Extract this
  } = req.body;

  if (!tournament_title) {
    return res.status(400).json({ error: "Tournament title is required" });
  }

  try {
    const tournament = await addTournament(
      tournament_title,
      tournament_start_date,
      tournament_end_date,
      tournament_hours,
      tournament_contact,
      tournament_address,
      tournament_city,
      tournament_state,
      tournament_country,
      tournament_email,
      is_active // <--- Pass it to the model
    );
    res.status(201).json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateTournamentController = async (req, res) => {
  const { id } = req.params;
  const {
    tournament_title,
    tournament_start_date,
    tournament_end_date,
    tournament_hours,
    tournament_contact,
    tournament_address,
    tournament_city,
    tournament_state,
    tournament_country,
    tournament_email,
    is_active // <--- Extract this
  } = req.body;

  if (!tournament_title) {
    return res.status(400).json({ error: "Tournament title is required" });
  }

  try {
    const tournament = await updateTournament(
      id,
      tournament_title,
      tournament_start_date,
      tournament_end_date,
      tournament_hours,
      tournament_contact,
      tournament_address,
      tournament_city,
      tournament_state,
      tournament_country,
      tournament_email,
      is_active // <--- Pass it to the model (CRITICAL FIX)
    );
    
    if (!tournament) {
      return res.status(404).json({ error: "Tournament not found" });
    }
    res.json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const deleteTournamentController = async (req, res) => {
  const { id } = req.params;
  try {
    const tournament = await deleteTournament(id);
    if (!tournament) {
      return res.status(404).json({ error: "Tournament not found" });
    }
    res.json({ message: "Tournament deleted successfully", deleted: tournament });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};