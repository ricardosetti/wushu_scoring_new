import {
    addRegistration,
    getRegistrationByEmail,
    getAllRegistrations,
    updateRegistrationStatus,
    getRegistrationById,
    getRegistrationByToken
  } from "../models/registrationModel.js";
  import {
    addRegistrationDivision,
    getDivisionsForRegistration,
    removeRegistrationDivision
  } from "../models/registrationDivisionsModel.js";
  
  export const createRegistration = async (req, res) => {
    try {
      const registration = await addRegistration(req.body);
      res.status(201).json(registration);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchAllRegistrations = async (req, res) => {
    try {
      const registrations = await getAllRegistrations();
      res.json(registrations);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchRegistrationByEmail = async (req, res) => {
    const { email } = req.params;
    try {
      const registration = await getRegistrationByEmail(email);
      if (!registration) {
        return res.status(404).json({ error: "Registration not found" });
      }
      res.json(registration);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchRegistrationById = async (req, res) => {
    const { id } = req.params;
    try {
      const registration = await getRegistrationById(id);
      if (!registration) {
        return res.status(404).json({ error: "Registration not found" });
      }
      res.json(registration);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const updateRegistrationStatusController = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    if (status === undefined) {
      return res.status(400).json({ error: "Missing status field" });
    }
    try {
      const updated = await updateRegistrationStatus(id, status);
      res.json(updated);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const addDivisionToRegistration = async (req, res) => {
    const { registration_id, division_id } = req.body;
    if (!registration_id || !division_id) {
      return res.status(400).json({ error: "Missing registration_id or division_id" });
    }
    try {
      const relation = await addRegistrationDivision(registration_id, division_id);
      res.status(201).json(relation);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchDivisionsForRegistration = async (req, res) => {
    const { registration_id } = req.params;
    try {
      const divisions = await getDivisionsForRegistration(registration_id);
      res.json(divisions);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const removeDivisionFromRegistration = async (req, res) => {
    const { registration_id, division_id } = req.body;
    if (!registration_id || !division_id) {
      return res.status(400).json({ error: "Missing registration_id or division_id" });
    }
    try {
      const relation = await removeRegistrationDivision(registration_id, division_id);
      res.json({ message: "Division removed from registration", deleted: relation });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  export const fetchRegistrationByToken = async (req, res) => {
    const { token } = req.params;
    try {
      const school = await getRegistrationByToken(token);
      if (!school) {
        return res.status(404).json({ error: "Invalid or expired token." });
      }
      res.json(school);
    } catch (err) {
      console.error("Error fetching registration by token:", err);
      res.status(500).json({ error: "Internal server error." });
    }
  };
  