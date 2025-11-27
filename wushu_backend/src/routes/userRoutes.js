import express from "express";
import { getUserProfile, updateUserProfile } from "../controllers/userController.js";
import { authenticateToken } from "./auth.js";

const router = express.Router();

router.get("/profile", authenticateToken, getUserProfile);
router.put("/profile", authenticateToken, updateUserProfile);

export default router;