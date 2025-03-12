import express from "express";
import { fetchSchools, createSchool, updateSchool, deleteSchool, fetchSchoolById } from "../controllers/schoolController.js";
import multer from "multer";

const router = express.Router();

// Configure multer for file uploads
const storage = multer.memoryStorage(); // Stores file in memory as buffer
const upload = multer({ storage });

router.get("/", fetchSchools);
router.post("/", upload.single("school_logo"), createSchool); // Upload logo
router.put("/:id", upload.single("school_logo"), updateSchool); // Optional logo update
router.delete("/:id", deleteSchool);
router.get("/:id", fetchSchoolById);

export default router;