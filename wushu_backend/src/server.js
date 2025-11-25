import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';

import participantRoutes from './routes/participantRoutes.js';
import divisionRoutes from './routes/divisionRoutes.js';
import scoreRoutes from './routes/scoreRoutes.js';
import activeParticipantRoutes from './routes/activeParticipantRoutes.js';
import tournamentDetailsRoutes from './routes/tournamentDetailsRoutes.js';
import deductionRoutes from './routes/deductionRoutes.js';
import participantDeductionRoutes from './routes/participantDeductionRoutes.js';
import publishedScoresRoutes from './routes/publishedScoresRoutes.js';
import schoolRoutes from './routes/schoolRoutes.js';
import authRoutes, { authenticateToken, authorizeRole } from './routes/auth.js';
import { fetchParticipants } from './controllers/participantsController.js';
import registrationRoutes from './routes/registrationRoutes.js';
import tournamentRoutes from './routes/tournamentRoutes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;
const FRONTEND_ORIGIN = process.env.FRONTEND_ORIGIN || 'http://localhost:5173';

const server = createServer(app);

const io = new Server(server, {
  cors: {
    origin: FRONTEND_ORIGIN,
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

app.use(express.json());

// Optional Logging
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(`Incoming request: ${req.method} ${req.url}`);
    next();
  });
}

app.use(
  cors({
    origin: FRONTEND_ORIGIN,
    credentials: true,
  })
);

app.set('io', io);

// ---------- Public Routes ----------
app.use('/auth', authRoutes);

// Explicit public handlers for Registration that don't fit the /registrations prefix logic easily
app.post('/register', (req, res, next) => {
  req.url = '/';
  registrationRoutes(req, res, next);
});

app.get('/register/validate-token', (req, res, next) => {
  req.url = '/register/validate-token';
  registrationRoutes(req, res, next);
});

// Public Data for Scoreboard/Leaderboard
app.get('/participants', (req, res) => fetchParticipants(req, res));
app.get('/published-scores/participant/:id', (req, res, next) => publishedScoresRoutes(req, res, next));
app.get('/tournament-details', (req, res, next) => tournamentDetailsRoutes(req, res, next));


// ---------- Protected Routes (With Exceptions) ----------

// 1. DIVISIONS: Public GET (including query params), Protected Mutations
app.use(
  '/divisions',
  (req, res, next) => {
    // Allow GET requests to /, /active, and /?active_only=true
    if (req.method === 'GET') {
      return divisionRoutes(req, res, next);
    }
    authenticateToken(req, res, next);
  },
  divisionRoutes
);

// 2. TOURNAMENTS: Public GET (List), Protected Mutations
app.use('/tournaments', (req, res, next) => {
    if (req.method === 'GET') {
      // Allow guests to see the list of tournaments (needed for Registration page)
      return next();
    }
    authenticateToken(req, res, next);
  },
  tournamentRoutes
);

// 3. REGISTRATIONS: Specific Public Endpoints, otherwise Protected
app.use(
  '/registrations',
  (req, res, next) => {
    // Use req.path to ignore query strings (like ?token=...)
    if ((req.method === 'POST' && req.path === '/') || req.path === '/register/validate-token') {
      return next();
    }
    authenticateToken(req, res, next);
  },
  registrationRoutes
);

// 4. OTHER PROTECTED ROUTES
app.use('/participants', authenticateToken, (req, res, next) => participantRoutes(req, res, next));
app.use('/scores', authenticateToken, scoreRoutes);
app.use('/active-participant', authenticateToken, activeParticipantRoutes);
app.use('/tournament-details', authenticateToken, tournamentDetailsRoutes);
app.use('/deductions', authenticateToken, deductionRoutes);
app.use('/participant-deductions', authenticateToken, participantDeductionRoutes);
app.use('/published-scores', authenticateToken, publishedScoresRoutes);
app.use('/schools', authenticateToken, schoolRoutes);


// ---------- Socket.IO ----------
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  socket.on('updateTournamentDetails', (data) => io.emit('tournamentDetailsUpdated', data));
  socket.on('scoreSubmitted', (data) => io.emit('judgeSubmitted', data));
  socket.on('scorePublished', (data) => io.emit('scorePublished', data));
  socket.on('deductionUpdated', (data) => io.emit('deductionUpdated', data));
  socket.on('activeDivisionUpdated', (data) => io.emit('activeDivisionUpdated', data));
  socket.on('disconnect', () => console.log('Client disconnected:', socket.id));
});

// ---------- Start Server ----------
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});