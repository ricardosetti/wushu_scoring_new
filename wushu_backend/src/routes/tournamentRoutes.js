import express from "express";
import multer from 'multer'; // Import multer
import {
  fetchTournaments,
  createTournament,
  fetchTournamentById,
  updateTournamentController,
  deleteTournamentController,
  fetchOpenTournaments
} from "../controllers/tournamentsController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Public
router.get("/open", fetchOpenTournaments); // <--- New Route
router.get("/", fetchTournaments);
router.get("/:id", fetchTournamentById);

// Protected
router.post("/", upload.single('tournament_logo'), createTournament);
router.put("/:id", upload.single('tournament_logo'), updateTournamentController);
router.delete("/:id", deleteTournamentController);

export default router;