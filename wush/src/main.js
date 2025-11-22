import { createApp } from "vue";
import App from "./App.vue";
import "./main.css";
import router from "./router";
import { io } from "socket.io-client";

const app = createApp(App);
app.use(router);

// Decide socket URL based on mode
// - DEV: use VITE_SOCKET_URL (http://localhost:5000)
// - PROD: omit URL => same-origin (wss://www.wushutournaments.com)
const socketUrl =
  import.meta.env.MODE === "production"
    ? undefined
    : import.meta.env.VITE_SOCKET_URL || "http://localhost:5000";

const socket = socketUrl
  ? io(socketUrl, {
      path: "/socket.io",
      transports: ["websocket"],
      withCredentials: true,
    })
  : io({
      path: "/socket.io",
      transports: ["websocket"],
      withCredentials: true,
    });

socket.on("connect", () => {
  console.log("Socket.IO connected:", socket.id);
});

socket.on("connect_error", (err) => {
  console.error("Socket.IO connection error:", err.message);
});

socket.on("tournamentDetailsUpdated", (data) => {
  console.log("Tournament details updated:", data);
});

socket.on("judgeSubmitted", (data) => {
  console.log("Judge submitted:", data);
});

socket.on("scorePublished", (data) => {
  console.log("Score published:", data);
});

socket.on("deductionUpdated", (data) => {
  console.log("Deduction updated:", data);
});

app.provide("socket", socket);

app.mount("#app");
