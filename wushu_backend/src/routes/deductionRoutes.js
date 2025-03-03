import express from "express";
import { fetchDeductions, createDeduction, editDeduction, removeDeduction, fetchDeductionById, fetchDeductionByCode } from "../controllers/deductionController.js";

const router = express.Router();

router.get("/", fetchDeductions);
router.post("/", createDeduction);
router.put("/:id", editDeduction);
router.delete("/:id", removeDeduction);
router.get("/:id", fetchDeductionById); // ✅ New route to fetch a deduction by ID
router.get("/code/:code", fetchDeductionByCode); // New route

export default router;
