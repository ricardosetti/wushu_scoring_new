import {
    addDivision,
    getDivisions,
    getDivisionById,
    getActiveDivision,
    setActiveDivision,
    clearActiveDivision,
    updateDivision,
    deleteDivision,
  } from "../models/divisionModel.js";
  
  export const createDivision = async (req, res) => {
    const { division_name } = req.body;
    if (!division_name) {
      return res.status(400).json({ error: "Division name is required" });
    }
    try {
      const division = await addDivision(division_name);
      res.status(201).json(division);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const fetchDivisions = async (req, res) => {
    try {
        const divisions = await getDivisions();
        res.json(divisions);
      } catch (err) {
        res.status(500).json({ error: err.message });
      }
    };
  
  export const fetchDivisionById = async (req, res) => {
    const { id } = req.params;
    try {
      const division = await getDivisionById(id);
      if (!division) {
        return res.status(404).json({ error: "Division not found" });
      }
      res.json(division);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  export const getActiveDivisionController = async (req, res) => {
    try {
      const activeDivision = await getActiveDivision();
      res.json(activeDivision);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  export const setActiveDivisionController = async (req, res) => {
    const { division_id } = req.body;
    if (!division_id) {
      return res.status(400).json({ error: "Division ID is required" });
    }
    try {
      const division = await setActiveDivision(division_id);
      if (!division) {
        return res.status(404).json({ error: "Division not found" });
      }
      res.json(division);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };

  export const clearActiveDivisionController = async (req, res) => {
    try {
      const result = await clearActiveDivision();
      res.json(result || { message: "No active division to clear" });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const updateDivisionController = async (req, res) => {
    const { id } = req.params;
    const { division_name } = req.body;
    if (!division_name) {
      return res.status(400).json({ error: "Division name is required" });
    }
    try {
      const division = await updateDivision(id, division_name);
      if (!division) {
        return res.status(404).json({ error: "Division not found" });
      }
      res.json(division);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  export const deleteDivisionController = async (req, res) => { // Renamed from deleteDivision
    const { id } = req.params;
    try {
      const division = await deleteDivision(id); // Calls the model function
      if (!division) {
        return res.status(404).json({ error: "Division not found" });
      }
      res.json({ message: "Division deleted successfully", deleted: division });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };