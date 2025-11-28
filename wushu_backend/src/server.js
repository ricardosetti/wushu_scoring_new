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
import authRoutes from './routes/auth.js';
import { fetchParticipants } from './controllers/participantsController.js';
import registrationRoutes from './routes/registrationRoutes.js';
import tournamentRoutes from './routes/tournamentRoutes.js';
import { authenticateToken } from './routes/auth.js'; // Ensure this is imported for use below
import userRoutes from './routes/userRoutes.js'; // <--- Import

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

// Registration Specifics
app.post('/register', (req, res, next) => {
  req.url = '/';
  registrationRoutes(req, res, next);
});

app.get('/register/validate-token', (req, res, next) => {
  req.url = '/register/validate-token';
  registrationRoutes(req, res, next);
});

// Public Data
app.get('/participants', (req, res) => fetchParticipants(req, res));
app.get('/published-scores/participant/:id', (req, res, next) => publishedScoresRoutes(req, res, next));
app.get('/tournament-details', (req, res, next) => tournamentDetailsRoutes(req, res, next));


// ---------- Semi-Protected Routes ----------

// 1. DIVISIONS: GET is public, everything else protected
app.use('/divisions', (req, res, next) => {
    if (req.method === 'GET') return divisionRoutes(req, res, next);
    authenticateToken(req, res, next);
  }, divisionRoutes
);

// 2. TOURNAMENTS: GET is public, everything else protected
// We delegate to the router, but we can also open GET here for simplicity
app.use('/tournaments', (req, res, next) => {
    if (req.method === 'GET') return next(); // Allow GET to pass through without auth
    authenticateToken(req, res, next);
  }, tournamentRoutes
);

// 3. SCHOOLS: Mixed (Public list vs Admin management)
// We remove authenticateToken here because schoolRoutes.js handles it internally
app.use('/schools', schoolRoutes);


// ---------- Fully Protected Routes ----------
app.use('/registrations', (req, res, next) => {
    if ((req.method === 'POST' && req.path === '/') || req.path === '/register/validate-token') {
      return next();
    }
    authenticateToken(req, res, next);
  }, registrationRoutes
);

app.use('/participants', authenticateToken, (req, res, next) => participantRoutes(req, res, next));
app.use('/scores', authenticateToken, scoreRoutes);
app.use('/active-participant', authenticateToken, activeParticipantRoutes);
app.use('/tournament-details', authenticateToken, tournamentDetailsRoutes);
app.use('/deductions', authenticateToken, deductionRoutes);
app.use('/participant-deductions', authenticateToken, participantDeductionRoutes);
app.use('/published-scores', authenticateToken, publishedScoresRoutes);
app.use('/users', userRoutes); // <--- Add this line


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

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});