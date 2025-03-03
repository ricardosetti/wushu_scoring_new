import express from "express";
import { fetchParticipants, createParticipant, fetchParticipantById } from "../controllers/participantsController.js";

const router = express.Router();

router.get("/", fetchParticipants);
router.post("/", createParticipant);
router.get("/:id", fetchParticipantById); // New route to fetch participant by ID

export default router;
