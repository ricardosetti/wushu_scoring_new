import express from "express";
import { publishParticipantScores, fetchPublishedScores } from "../controllers/publishedScoresController.js";

const router = express.Router();

router.post("/", publishParticipantScores);
router.get("/participant/:participant_id", fetchPublishedScores);

export default router;