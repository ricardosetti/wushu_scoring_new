import express from "express";
import {
  fetchParticipants,
  createParticipant,
  fetchParticipantById,
  updateParticipantController,
  addParticipantDivisionController,
  removeParticipantDivisionController,
  fetchParticipantDivisions,
  deleteParticipantController,
} from "../controllers/participantsController.js";

const router = express.Router();

// Exact matches first
router.get("/", fetchParticipants);
router.post("/", createParticipant);

// Parameterized routes after exact matches
router.get("/:id", fetchParticipantById);
router.put("/:id", updateParticipantController);
router.delete("/division", removeParticipantDivisionController);
router.delete("/:id", deleteParticipantController);

// Division-related routes
router.get("/:participant_id/divisions", fetchParticipantDivisions);
router.post("/division", addParticipantDivisionController);


export default router;