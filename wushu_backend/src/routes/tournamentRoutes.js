import express from "express";
import multer from 'multer'; // Import multer
import {
  fetchTournaments,
  createTournament,
  fetchTournamentById,
  updateTournamentController,
  deleteTournamentController,
} from "../controllers/tournamentsController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Public GET (Allowed by server.js logic)
router.get("/", fetchTournaments);
router.get("/:id", fetchTournamentById);

// Protected Mutations (Auth handled in server.js or here)
// Add upload.single('tournament_logo') middleware
router.post("/", upload.single('tournament_logo'), createTournament);
router.put("/:id", upload.single('tournament_logo'), updateTournamentController);
router.delete("/:id", deleteTournamentController);

export default router;