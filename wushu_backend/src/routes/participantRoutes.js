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

router.get("/", fetchParticipants);
router.post("/", createParticipant);
router.get("/:id", fetchParticipantById);
router.put("/:id", updateParticipantController);
router.delete("/:id", deleteParticipantController);
router.post("/division", addParticipantDivisionController);
router.delete("/division", removeParticipantDivisionController);
router.get("/:participant_id/divisions", fetchParticipantDivisions);

export default router;