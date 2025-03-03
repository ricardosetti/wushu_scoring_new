import express from "express";
import { fetchTournamentDetails, updateTournamentDetails } from "../controllers/tournamentDetailsController.js";

const router = express.Router();

router.get("/", fetchTournamentDetails);
router.post("/", updateTournamentDetails);

export default router;
