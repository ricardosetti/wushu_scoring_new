import express from "express";
import {
  createTournament,
  fetchTournaments,
  fetchTournamentById,
  updateTournamentController
} from "../controllers/tournamentController.js";

const router = express.Router();

// Tournament management
router.get("/", fetchTournaments);
router.post("/", createTournament);
router.get("/:tournament_id", fetchTournamentById);
router.put("/:tournament_id", updateTournamentController);

export default router;
