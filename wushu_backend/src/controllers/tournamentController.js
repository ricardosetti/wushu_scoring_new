import {
    addTournament,
    getTournaments,
    getTournamentById,
    updateTournament
  } from "../models/tournamentModel.js";
  
  export const createTournament = async (req, res) => {
    try {
      const tournament = await addTournament(req.body);
      res.status(201).json(tournament);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchTournaments = async (req, res) => {
    try {
      const tournaments = await getTournaments();
      res.json(tournaments);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchTournamentById = async (req, res) => {
    const { tournament_id } = req.params;
    try {
      const tournament = await getTournamentById(tournament_id);
      if (!tournament) {
        return res.status(404).json({ error: "Tournament not found" });
      }
      res.json(tournament);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const updateTournamentController = async (req, res) => {
    const { tournament_id } = req.params;
    try {
      const updated = await updateTournament(tournament_id, req.body);
      res.json(updated);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  