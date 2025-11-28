import express from "express";
import { authenticateToken } from "./auth.js"; // <--- IMPORT ADDED HERE
import {
  createDivision,
  fetchAllDivisions,
  fetchDivisionById,
  fetchActiveDivision,
  setActiveDivisionController,
  clearActiveDivisionController,
  updateDivisionController,
  deleteDivisionController,
  toggleDivisionStatusController // <--- Make sure this is imported too
} from "../controllers/divisionController.js";

const router = express.Router();

// Public routes (GETs allow public access now via server.js logic, but we keep structure)
router.get("/", fetchAllDivisions);
router.get("/active", fetchActiveDivision);

// Protected routes
router.post("/", authenticateToken, createDivision); // Added auth here for consistency
router.get("/:id", fetchDivisionById); // Public read is usually fine, but you can add auth if needed
router.put("/:id", authenticateToken, updateDivisionController);
router.delete("/:id", authenticateToken, deleteDivisionController);
router.post("/set-active", authenticateToken, setActiveDivisionController);
router.post("/clear-active", authenticateToken, clearActiveDivisionController);

// NEW: Toggle Division Status for specific tournament
router.post("/:id/toggle-status", authenticateToken, toggleDivisionStatusController);

export default router;