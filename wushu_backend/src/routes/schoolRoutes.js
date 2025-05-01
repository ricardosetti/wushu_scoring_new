import express from "express";
import {
  fetchSchools,
  createSchool,
  updateSchool,
  deleteSchool,
  fetchSchoolById,
  generateRegistrationLink
} from "../controllers/schoolController.js";
import multer from "multer";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

router.get("/", fetchSchools);
router.post("/", upload.single("school_logo"), createSchool);
router.put("/:id", upload.single("school_logo"), updateSchool);
router.delete("/:id", deleteSchool);
router.get("/:id", fetchSchoolById);

// New route to generate registration link + QR code
router.post("/:schoolId/generate-registration-link", generateRegistrationLink);

export default router;
