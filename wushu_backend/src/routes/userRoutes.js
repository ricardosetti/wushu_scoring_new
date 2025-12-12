import express from "express";
import { 
  getUserProfile, 
  updateUserProfile,
  getAllUsers,      // New
  adminCreateUser,  // New
  adminUpdateUser,  // New
  adminDeleteUser,  // New
  adminResetPassword // New
} from "../controllers/userController.js";
import { authenticateToken, authorizeRole } from "./auth.js"; // Import authorizeRole

const router = express.Router();

// User Profile (Self)
router.get("/profile", authenticateToken, getUserProfile);
router.put("/profile", authenticateToken, updateUserProfile);

// Admin User Management
// Note: 'authorizeRole' is a curried function: authorizeRole('admin') returns the middleware
router.get("/", authenticateToken, authorizeRole('admin'), getAllUsers);
router.post("/", authenticateToken, authorizeRole('admin'), adminCreateUser);
router.put("/:id", authenticateToken, authorizeRole('admin'), adminUpdateUser);
router.delete("/:id", authenticateToken, authorizeRole('admin'), adminDeleteUser);
router.put("/:id/reset-password", authenticateToken, authorizeRole('admin'), adminResetPassword);

export default router;