import express from "express";
import { createParticipantDeduction, fetchParticipantDeductions, deleteParticipantDeduction } from "../controllers/participantDeductionController.js";

const router = express.Router();

router.post("/", createParticipantDeduction);
router.get("/:participant_id/:judge", fetchParticipantDeductions);
router.delete("/:participant_id/:deduction_id/:judge", deleteParticipantDeduction);

export default router;