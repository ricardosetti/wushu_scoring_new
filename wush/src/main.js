import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import { io } from "socket.io-client";


const app = createApp(App);
app.use(router);

const socket = io("http://localhost:5000", {
  cors: {
    origin: window.location.origin, // Dynamically use the frontend's origin
  },
});
app.provide("socket", socket);

app.mount("#app");