import express from "express";
import {
  createDivision,
  fetchAllDivisions,
  fetchDivisionById,
  fetchActiveDivision,
  setActiveDivisionController,
  clearActiveDivisionController,
  updateDivisionController,
  deleteDivisionController,
} from "../controllers/divisionController.js";

const router = express.Router();

// Public routes
router.get("/", fetchAllDivisions);
router.get("/active", fetchActiveDivision);

// Protected routes (authentication required via server.js middleware)
router.post("/", createDivision);
router.get("/:id", fetchDivisionById);
router.put("/:id", updateDivisionController);
router.delete("/:id", deleteDivisionController);
router.post("/set-active", setActiveDivisionController);
router.post("/clear-active", clearActiveDivisionController);

export default router;