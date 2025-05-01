import express from "express";
import {
  createRegistration,
  fetchAllRegistrations,
  fetchRegistrationByEmail,
  fetchRegistrationById,
  updateRegistrationStatusController,
  addDivisionToRegistration,
  fetchDivisionsForRegistration,
  removeDivisionFromRegistration,
  fetchRegistrationByToken
} from "../controllers/registrationController.js";

const router = express.Router();

// Registrations CRUD
router.get("/", fetchAllRegistrations);
router.post("/", createRegistration);
router.get("/email/:email", fetchRegistrationByEmail);
router.get("/token/:token", fetchRegistrationByToken);
router.get("/:id", fetchRegistrationById);
router.put("/:id/status", updateRegistrationStatusController);

// Divisions associated with a registration
router.get("/:registration_id/divisions", fetchDivisionsForRegistration);
router.post("/division", addDivisionToRegistration);
router.delete("/division", removeDivisionFromRegistration);

export default router;
