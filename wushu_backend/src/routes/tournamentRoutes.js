import express from "express";
import {
  fetchTournaments,
  createTournament,
  fetchTournamentById,
  updateTournamentController,
  deleteTournamentController,
} from "../controllers/tournamentsController.js";

const router = express.Router();

// Exact matches first
router.get("/", fetchTournaments);
router.post("/", createTournament);

// Parameterized routes
router.get("/:id", fetchTournamentById);
router.put("/:id", updateTournamentController);
router.delete("/:id", deleteTournamentController);

export default router;