import {
  getTournaments,
  getTournamentById,
  addTournament,
  updateTournament,
  deleteTournament,
  getOpenTournaments
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

export const fetchOpenTournaments = async (req, res) => {
  try {
    const tournaments = await getOpenTournaments();
    res.json(tournaments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const createTournament = async (req, res) => {
  const data = req.body;
  if (req.file) {
    const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    data.tournament_logo = base64;
  }
  
  // Ensure dates are null if empty string
  if (!data.registration_start_date) data.registration_start_date = null;
  if (!data.registration_end_date) data.registration_end_date = null;

  if (!data.tournament_title) return res.status(400).json({ error: "Title required" });

  try {
    const tournament = await addTournament(data);
    res.status(201).json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateTournamentController = async (req, res) => {
  const { id } = req.params;
  const data = req.body;
  
  if (req.file) {
    const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    data.tournament_logo = base64;
  }

  // Ensure dates are null if empty string
  if (!data.registration_start_date) data.registration_start_date = null;
  if (!data.registration_end_date) data.registration_end_date = null;

  try {
    const tournament = await updateTournament(id, data);
    if (!tournament) return res.status(404).json({ error: "Not found" });
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