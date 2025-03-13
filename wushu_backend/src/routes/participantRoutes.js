import express from "express";
import {
  fetchParticipants,
  createParticipant,
  fetchParticipantById,
  updateParticipantController, // Updated to match the new name
  deleteParticipantController,
} from "../controllers/participantsController.js";

const router = express.Router();

router.get("/", fetchParticipants);
router.post("/", createParticipant);
router.get("/:id", fetchParticipantById);
router.put("/:id", updateParticipantController); // New route
router.delete("/:id", deleteParticipantController); // New route

export default router;