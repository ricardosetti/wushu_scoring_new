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
  // 1. Get text fields from body
  const data = req.body;

  // 2. Handle File Upload (if sent)
  // Multer stores the file in req.file. We convert the buffer to a Base64 string.
  if (req.file) {
    const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    data.tournament_logo = base64;
  }

  if (!data.tournament_title) {
    return res.status(400).json({ error: "Tournament title is required" });
  }

  try {
    // Pass the entire data object (including logo and colors) to the model
    const tournament = await addTournament(data);
    res.status(201).json(tournament);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const updateTournamentController = async (req, res) => {
  const { id } = req.params;
  const data = req.body;

  // 1. Handle File Upload (if sent)
  if (req.file) {
    const base64 = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    data.tournament_logo = base64;
  }

  if (!data.tournament_title) {
    return res.status(400).json({ error: "Tournament title is required" });
  }

  try {
    // Pass ID and Data object to model
    const tournament = await updateTournament(id, data);
    
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