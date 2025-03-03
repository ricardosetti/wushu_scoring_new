import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { createServer } from "http";
import { Server } from "socket.io";
import participantRoutes from "./routes/participantRoutes.js";
import scoreRoutes from "./routes/scoreRoutes.js";
import activeParticipantRoutes from "./routes/activeParticipantRoutes.js";
import tournamentDetailsRoutes from "./routes/tournamentDetailsRoutes.js";
import deductionRoutes from "./routes/deductionRoutes.js";
import participantDeductionRoutes from "./routes/participantDeductionRoutes.js";
import publishedScoresRoutes from "./routes/publishedScoresRoutes.js";

dotenv.config();
const app = express();
const port = 5000;

const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: ["http://localhost:5173", "http://localhost:5174"], // Allow both ports
    methods: ["GET", "POST"],
  },
});

app.use(cors({
  origin: ["http://localhost:5173", "http://localhost:5174"], // Match for HTTP requests
}));
app.use(express.json());

// Routes
app.use("/participants", participantRoutes);
app.use("/scores", scoreRoutes);
app.use("/active-participant", activeParticipantRoutes);
app.use("/tournament-details", tournamentDetailsRoutes);
app.use("/deductions", deductionRoutes);
app.use("/participant-deductions", participantDeductionRoutes);
app.use("/published-scores", publishedScoresRoutes);

// Socket.IO events
io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  socket.on("updateTournamentDetails", (data) => {
    io.emit("tournamentDetailsUpdated", data);
  });

  socket.on("scoreSubmitted", (data) => {
    io.emit("judgeSubmitted", data);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

server.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});