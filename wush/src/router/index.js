import { createRouter, createWebHistory } from "vue-router";
import JudgeA1 from "../views/JudgeA1.vue";
import JudgeA2 from "../views/JudgeA2.vue";
import JudgeB1 from "../views/JudgeB1.vue";
import JudgeB2 from "../views/JudgeB2.vue";
import HeadJudge from "../views/HeadJudge.vue";
import Scoreboard from "../views/Scoreboard.vue";
import Admin from '../views/Admin.vue' // New
import SchoolManagement from '../views/SchoolManagement.vue' // New
import ParticipantManagement from '../views/ParticipantManagement.vue' // New

const routes = [
  { path: "/judge-a1", component: JudgeA1 },
  { path: "/judge-a2", component: JudgeA2 },
  { path: "/judge-b1", component: JudgeB1 },
  { path: "/judge-b2", component: JudgeB2 },
  { path: "/head-judge", component: HeadJudge },
  { path: "/scoreboard", component: Scoreboard }, // New route
  { path: "/", redirect: "/head-judge" },
  { path: "/admin", component: Admin }, // New route
  { path: "/admin/schools", component: SchoolManagement }, // New route
  { path: "/admin/participants", component: ParticipantManagement }, // New route
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;