import express from "express";
import cors from "cors";
import dotenv from 'dotenv';
import { createServer } from "http";
import { Server } from "socket.io";
import participantRoutes from "./routes/participantRoutes.js";
import divisionRoutes from "./routes/divisionRoutes.js";
import scoreRoutes from "./routes/scoreRoutes.js";
import activeParticipantRoutes from "./routes/activeParticipantRoutes.js";
import tournamentDetailsRoutes from "./routes/tournamentDetailsRoutes.js";
import deductionRoutes from "./routes/deductionRoutes.js";
import participantDeductionRoutes from "./routes/participantDeductionRoutes.js";
import publishedScoresRoutes from "./routes/publishedScoresRoutes.js";
import schoolRoutes from "./routes/schoolRoutes.js";
import { authRoutes, authenticateToken, authorizeRole } from "./routes/auth.js";
import { fetchParticipants } from "./controllers/participantsController.js"; // Import directly

dotenv.config();
const app = express();
const port = 5000;


const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: "http://localhost:5173", // Allow frontend dev origin
    methods: ["GET", "POST"],
  },
});
app.use(express.json());

app.use((req, res, next) => {
  console.log(`Incoming request: ${req.method} ${req.url}`);
  console.log('Request headers:', req.headers);
  console.log('Request body:', req.body);
  next();
});

app.use(cors({
  origin: "http://localhost:5173", // Allow frontend dev origin
}));


// Attach io to app for route controllers
app.set('io', io);

// Public routes
app.use("/auth", authRoutes);

// Public routes for leaderboard and scoreboard
app.get("/divisions/active", (req, res, next) => {
  console.log("Matched GET /divisions/active");
  divisionRoutes(req, res, next);
});
app.get("/participants", (req, res) => {
  console.log("Matched GET /participants (public route)");
  fetchParticipants(req, res);
});
app.get("/published-scores/participant/:id", (req, res, next) => {
  console.log("Matched GET /published-scores/participant/:id");
  publishedScoresRoutes(req, res, next);
});
app.get("/tournament-details", (req, res, next) => {
  console.log("Matched GET /tournament-details");
  tournamentDetailsRoutes(req, res, next);
});

// Protected routes (require authentication)
app.use("/divisions", authenticateToken, (req, res, next) => {
  console.log("Matched /divisions (protected)");
  divisionRoutes(req, res, next);
});
app.use("/participants", authenticateToken, (req, res, next) => {
  console.log("Matched /participants (protected)");
  participantRoutes(req, res, next);
});
app.use("/scores", authenticateToken, scoreRoutes);
app.use("/active-participant", authenticateToken, activeParticipantRoutes);
app.use("/tournament-details", authenticateToken, tournamentDetailsRoutes);
app.use("/deductions", authenticateToken, deductionRoutes);
app.use("/participant-deductions", authenticateToken, participantDeductionRoutes);
app.use("/published-scores", authenticateToken, publishedScoresRoutes);
app.use("/schools", authenticateToken, schoolRoutes);

// Socket.IO events
io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  socket.on("updateTournamentDetails", (data) => {
    io.emit("tournamentDetailsUpdated", data);
  });

  socket.on("scoreSubmitted", (data) => {
    io.emit("judgeSubmitted", data);
  });

  socket.on("scorePublished", (data) => {
    io.emit("scorePublished", data); // Relay to all clients
  });

  socket.on("deductionUpdated", (data) => {
    io.emit("deductionUpdated", data); // Relay to all clients
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });

  socket.on("activeDivisionUpdated", (data) => {
    io.emit("activeDivisionUpdated", data);
  });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});