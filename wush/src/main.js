import { createApp } from "vue";
import App from "./App.vue";
import './main.css';
import router from "./router";
import { io } from "socket.io-client";

const app = createApp(App);
app.use(router);

const socket = io(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}`, {
  path: '/socket.io',
  transports: ['websocket', 'polling'],
  cors: {
    origin: '*',
  },
});

socket.on('connect', () => {
  console.log('Socket.IO connected:', socket.id);
});

socket.on('connect_error', (err) => {
  console.error('Socket.IO connection error:', err.message);
});

socket.on('tournamentDetailsUpdated', (data) => {
  console.log('Tournament details updated:', data);
});

socket.on('judgeSubmitted', (data) => {
  console.log('Judge submitted:', data);
});

socket.on('scorePublished', (data) => {
  console.log('Score published:', data);
});

socket.on('deductionUpdated', (data) => {
  console.log('Deduction updated:', data);
});

app.provide("socket", socket);

app.mount("#app");