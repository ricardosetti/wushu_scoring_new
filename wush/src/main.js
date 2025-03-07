import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import { io } from "socket.io-client";


const app = createApp(App);
app.use(router);

const socket = io('http://localhost:5000', { // Use Pi’s IP and port
  path: '/socket.io', // Match Nginx location
  transports: ['websocket', 'polling'], // Prefer WebSocket, fallback to polling
  cors: {
    origin: '*',
  },
});

socket.on('connect', () => {
  console.log('Socket.IO connected:', socket.id); // Debug log
});

socket.on('connect_error', (err) => {
  console.error('Socket.IO connection error:', err.message); // Debug error
});

socket.on('tournamentDetailsUpdated', (data) => {
  console.log('Tournament details updated:', data);
});

socket.on('judgeSubmitted', (data) => {
  console.log('Judge submitted:', data);
});

app.provide("socket", socket);

app.mount("#app");