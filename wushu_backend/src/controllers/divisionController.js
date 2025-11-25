import pool from "../models/db.js"; // <--- THIS WAS MISSING
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
import { toggleTournamentDivision } from "../models/divisionModel.js";

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

export const fetchAllDivisions = async (req, res) => {
  try {
    const { tournament_id } = req.query;
    let targetId = tournament_id;

    // If "active_only" is requested, find the currently active tournament ID
    if (req.query.active_only === 'true') {
        const activeRes = await pool.query("SELECT tournament_id FROM tournaments WHERE is_active = TRUE LIMIT 1");
        targetId = activeRes.rows[0]?.tournament_id;
    }

    const divisions = await getDivisions(targetId);
    res.json(divisions);
  } catch (err) {
    console.error("Error fetching divisions:", err);
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

export const fetchActiveDivision = async (req, res) => {
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
    // Notify clients via Socket.IO
    req.app.get("io").emit("activeDivisionUpdated", division);
    res.json(division);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const clearActiveDivisionController = async (req, res) => {
  try {
    const result = await clearActiveDivision();
    req.app.get("io").emit("activeDivisionUpdated", null);
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

export const deleteDivisionController = async (req, res) => {
  const { id } = req.params;
  try {
    const division = await deleteDivision(id);
    if (!division) {
      return res.status(404).json({ error: "Division not found" });
    }
    res.json({ message: "Division deleted successfully", deleted: division });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const toggleDivisionStatusController = async (req, res) => {
  const { id } = req.params;
  const { is_enabled } = req.body; // true or false

  try {
    await toggleTournamentDivision(id, is_enabled);
    res.json({ message: "Updated successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};