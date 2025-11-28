import { getUserById, updateUser } from "../models/userModel.js";
import { getRegistrationsByUser } from "../models/registrationModel.js";

// Get Profile + Registration History
export const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [user, registrations] = await Promise.all([
      getUserById(userId),
      getRegistrationsByUser(userId)
    ]);

    if (!user) return res.status(404).json({ error: "User not found" });

    // Remove password hash for security
    delete user.password;

    res.json({ user, registrations });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Update Profile Data
export const updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updatedUser = await updateUser(userId, req.body);
    delete updatedUser.password;
    res.json(updatedUser);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};