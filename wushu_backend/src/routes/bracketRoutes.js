import express from "express";
import { fetchBrackets, generateBracket, fetchBracketParticipants } from "../controllers/bracketController.js";
import { authenticateToken, authorizeRole } from "./auth.js";

const router = express.Router();

router.get("/", authenticateToken, fetchBrackets);
router.get("/participants", authenticateToken, fetchBracketParticipants); // NEW
router.post("/generate", authenticateToken, authorizeRole('admin'), generateBracket);

export default router;