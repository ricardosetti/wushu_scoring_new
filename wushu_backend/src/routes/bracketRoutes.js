import express from "express";
import { 
    fetchBrackets, 
    generateBracket, 
    fetchBracketParticipants, 
    simulateBrackets, 
    commitBrackets} 
    from "../controllers/bracketController.js";
import { authenticateToken, authorizeRole } from "./auth.js";

const router = express.Router();

router.get("/", authenticateToken, fetchBrackets);
router.get("/participants", authenticateToken, fetchBracketParticipants); // NEW
router.post("/generate", authenticateToken, authorizeRole('admin'), generateBracket);

// New Routes for Bulk Roster Mgmt
router.post("/simulate", authenticateToken, authorizeRole('admin'), simulateBrackets);
router.post("/commit", authenticateToken, authorizeRole('admin'), commitBrackets);

export default router;