import express from "express";
import { fetchScores, createScore, fetchLatestScore, fetchParticipantScores } from "../controllers/scoresController.js";

const router = express.Router();

router.get("/", fetchScores);
router.post("/", createScore);
router.get("/latest", fetchLatestScore); // New API route for latest score
router.get("/participant/:participant_id", fetchParticipantScores); // New route

export default router;