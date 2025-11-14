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
const port = 5000;

const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: 'http://localhost:5173',
    methods: ['GET', 'POST'],
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
  origin: 'http://localhost:5173',
}));

app.set('io', io);

// Public Routes
app.use('/auth', authRoutes);

// Public Routes for Leaderboard, Scoreboard, and Registration
app.get('/divisions/active', (req, res, next) => {
  console.log('Matched GET /divisions/active');
  req.url = '/active'; // Explicitly set the URL for divisionRoutes
  divisionRoutes(req, res, next);
});
app.get('/divisions', (req, res, next) => {
  console.log('Matched GET /divisions (public route)');
  req.url = '/'; // Explicitly set the URL for divisionRoutes
  divisionRoutes(req, res, next);
});
app.get('/participants', (req, res) => {
  console.log('Matched GET /participants (public route)');
  fetchParticipants(req, res);
});
app.get('/published-scores/participant/:id', (req, res, next) => {
  console.log('Matched GET /published-scores/participant/:id');
  publishedScoresRoutes(req, res, next);
});
app.get('/tournament-details', (req, res, next) => {
  console.log('Matched GET /tournament-details');
  tournamentDetailsRoutes(req, res, next);
});

// Public Registration Routes
app.post('/register', (req, res, next) => {
  req.url = '/';
  registrationRoutes(req, res, next);
});
app.get('/register/validate-token', (req, res, next) => {
  req.url = '/register/validate-token';
  registrationRoutes(req, res, next);
});

// Protected Routes (require authentication)
// Add protected /divisions routes
app.use('/divisions', (req, res, next) => {
  // Skip middleware for explicitly defined public routes
  if (req.method === 'GET' && (req.url === '/' || req.url === '/active')) {
    console.log('Skipping auth middleware for public /divisions route:', req.url);
    return divisionRoutes(req, res, next);
  }
  console.log('Matched /divisions (protected)');
  authenticateToken(req, res, next);
}, divisionRoutes);

app.use('/participants', authenticateToken, (req, res, next) => {
  console.log('Matched /participants (protected)');
  participantRoutes(req, res, next);
});
app.use('/scores', authenticateToken, scoreRoutes);
app.use('/active-participant', authenticateToken, activeParticipantRoutes);
app.use('/tournament-details', authenticateToken, tournamentDetailsRoutes);
app.use('/deductions', authenticateToken, deductionRoutes);
app.use('/participant-deductions', authenticateToken, participantDeductionRoutes);
app.use('/published-scores', authenticateToken, publishedScoresRoutes);
app.use('/schools', authenticateToken, schoolRoutes);
app.use('/tournaments', authenticateToken, tournamentRoutes); // Added authentication middleware

// Protected Registration Routes
app.use('/registrations', (req, res, next) => {
  // Allow public routes to pass through
  if (req.method === 'POST' && req.url === '/' || req.url === '/register/validate-token') {
    return next();
  }
  // Require authentication for all other routes
  authenticateToken(req, res, next);
}, registrationRoutes);

// Socket.IO Events
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('updateTournamentDetails', (data) => {
    io.emit('tournamentDetailsUpdated', data);
  });

  socket.on('scoreSubmitted', (data) => {
    io.emit('judgeSubmitted', data);
  });

  socket.on('scorePublished', (data) => {
    io.emit('scorePublished', data);
  });

  socket.on('deductionUpdated', (data) => {
    io.emit('deductionUpdated', data);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });

  socket.on('activeDivisionUpdated', (data) => {
    io.emit('activeDivisionUpdated', data);
  });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});