import express from "express";
import {
  createDivision,
  fetchDivisions,
  fetchDivisionById,
  updateDivisionController,
  deleteDivisionController,
} from "../controllers/divisionController.js";

const router = express.Router();

router.post("/", createDivision);
router.get("/", fetchDivisions);
router.get("/:id", fetchDivisionById);
router.put("/:id", updateDivisionController);
router.delete("/:id", deleteDivisionController);

export default router;