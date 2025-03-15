import express from "express";
import {
  createDivision,
  fetchDivisions,
  fetchDivisionById,
  getActiveDivisionController,
  setActiveDivisionController,
  clearActiveDivisionController,
  updateDivisionController,
  deleteDivisionController,
} from "../controllers/divisionController.js";

const router = express.Router();

router.post("/", createDivision);
router.get("/", fetchDivisions);
router.get("/active", getActiveDivisionController);
router.post("/set-active", setActiveDivisionController);
router.post("/clear-active", clearActiveDivisionController);
router.get("/:id", fetchDivisionById);
router.put("/:id", updateDivisionController);
router.delete("/:id", deleteDivisionController);

export default router;