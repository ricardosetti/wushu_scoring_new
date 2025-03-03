import express from "express";
import { fetchActiveParticipant, updateActiveParticipant } from "../controllers/activeParticipantController.js";

const router = express.Router();

router.get("/", fetchActiveParticipant);
router.post("/", updateActiveParticipant);

export default router;
