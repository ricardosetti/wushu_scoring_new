import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';

// Routes
import participantRoutes from './routes/participantRoutes.js';
import divisionRoutes from './routes/divisionRoutes.js';
import scoreRoutes from './routes/scoreRoutes.js';
import activeParticipantRoutes from './routes/activeParticipantRoutes.js';
import tournamentDetailsRoutes from './routes/tournamentDetailsRoutes.js';
import deductionRoutes from './routes/deductionRoutes.js';
import participantDeductionRoutes from './routes/participantDeductionRoutes.js';
import publishedScoresRoutes from './routes/publishedScoresRoutes.js';
import schoolRoutes from './routes/schoolRoutes.js';
import authRoutes, { authenticateToken } from './routes/auth.js';
import registrationRoutes from './routes/registrationRoutes.js';
import tournamentRoutes from './routes/tournamentRoutes.js';
import userRoutes from './routes/userRoutes.js';

// Specific Controllers needed for public access
import { fetchParticipants, fetchParticipantById } from './controllers/participantsController.js';

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

// Request Logger (Dev only)
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

// ==========================================
// 1. PUBLIC ROUTES (No Auth Required)
// ==========================================

// Auth & Account
app.use('/auth', authRoutes);

// Registration Aliases (So /register works publicly)
app.post('/register', (req, res, next) => {
  req.url = '/';
  registrationRoutes(req, res, next);
});

app.get('/register/validate-token', (req, res, next) => {
  req.url = '/register/validate-token';
  registrationRoutes(req, res, next);
});

// Public Data for Scoreboard, Leaderboard & Landing Pages
app.get('/participants', fetchParticipants); // List
app.get('/participants/:id', fetchParticipantById); // <--- ADDED: Details for Scoreboard
app.get('/published-scores/participant/:id', (req, res, next) => publishedScoresRoutes(req, res, next));
app.get('/tournament-details', (req, res, next) => tournamentDetailsRoutes(req, res, next));


// ==========================================
// 2. MIXED ACCESS (Public READ, Protected WRITE)
// ==========================================

// Divisions: GET is public, everything else protected
app.use('/divisions', (req, res, next) => {
    if (req.method === 'GET') return divisionRoutes(req, res, next);
    authenticateToken(req, res, next);
  }, divisionRoutes
);

// Tournaments: GET is public (Landing Page), everything else protected
app.use('/tournaments', (req, res, next) => {
    if (req.method === 'GET') return tournamentRoutes(req, res, next);
    authenticateToken(req, res, next);
  }, tournamentRoutes
);

// Schools: Router handles its own auth (Public List vs Admin Actions)
app.use('/schools', schoolRoutes);


// ==========================================
// 3. PROTECTED ROUTES (Auth Required)
// ==========================================

// Registrations (Catch-all for non-public paths)
app.use('/registrations', (req, res, next) => {
    // Double check we aren't blocking the public aliases just in case
    if ((req.method === 'POST' && req.path === '/') || req.path === '/register/validate-token') {
      return next();
    }
    authenticateToken(req, res, next);
  }, registrationRoutes
);

// User Profile
app.use('/users', userRoutes);

// Core Logic (Judges/Admin)
app.use('/participants', authenticateToken, participantRoutes); // POST/PUT/DELETE
app.use('/scores', authenticateToken, scoreRoutes);
app.use('/active-participant', authenticateToken, activeParticipantRoutes);
app.use('/tournament-details', authenticateToken, tournamentDetailsRoutes); // POST (updates)
app.use('/deductions', authenticateToken, deductionRoutes);
app.use('/participant-deductions', authenticateToken, participantDeductionRoutes);
app.use('/published-scores', authenticateToken, publishedScoresRoutes); // POST (publish)


// ==========================================
// SOCKET.IO
// ==========================================
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  socket.on('updateTournamentDetails', (data) => io.emit('tournamentDetailsUpdated', data));
  socket.on('scoreSubmitted', (data) => io.emit('judgeSubmitted', data));
  socket.on('scorePublished', (data) => io.emit('scorePublished', data));
  socket.on('deductionUpdated', (data) => io.emit('deductionUpdated', data));
  socket.on('activeDivisionUpdated', (data) => io.emit('activeDivisionUpdated', data));
  socket.on('disconnect', () => console.log('Client disconnected:', socket.id));
});

// Start
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});