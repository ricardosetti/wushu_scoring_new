import {
    addDivision,
    getDivisions,
    getDivisionById,
    updateDivision,
    deleteDivision, // Imported from model
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