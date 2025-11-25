import { createRouter, createWebHistory } from 'vue-router';
import JudgeA1 from '../views/JudgeA1.vue';
import JudgeA2 from '../views/JudgeA2.vue';
import JudgeB1 from '../views/JudgeB1.vue';
import JudgeB2 from '../views/JudgeB2.vue';
import HeadJudge from '../views/HeadJudge.vue';
import Scoreboard from '../views/Scoreboard.vue';
import Leaderboard from '../views/Leaderboard.vue';
import Admin from '../views/Admin.vue';
import SchoolManagement from '../views/SchoolManagement.vue';
import ParticipantManagement from '../views/ParticipantManagement.vue';
import DivisionManagement from '../views/DivisionManagement.vue';
import TournamentManagement from '../views/TournamentManagement.vue'; // Added import
import Login from '../views/Login.vue';
import ParticipantLogin from '../views/ParticipantLogin.vue';
import Register from '../views/Register.vue';
import Profile from '../views/Profile.vue';
import RegistrationManagement from '../views/RegistrationManagement.vue'; // <--- Import

const routes = [
  { path: '/judge-a1', component: JudgeA1, meta: { requiresAuth: true, roles: ['judge_a'] } },
  { path: '/judge-a2', component: JudgeA2, meta: { requiresAuth: true, roles: ['judge_a'] } },
  { path: '/judge-b1', component: JudgeB1, meta: { requiresAuth: true, roles: ['judge_b'] } },
  { path: '/judge-b2', component: JudgeB2, meta: { requiresAuth: true, roles: ['judge_b'] } },
  { path: '/head-judge', component: HeadJudge, meta: { requiresAuth: true, roles: ['head_judge'] } },
  { path: '/scoreboard', component: Scoreboard },
  { path: '/leaderboard', component: Leaderboard },
  { path: '/admin', component: Admin, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/schools', component: SchoolManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/participants', component: ParticipantManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/divisions', component: DivisionManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/tournaments', component: TournamentManagement, meta: { requiresAuth: true, roles: ['admin'] } }, // Added route
  { path: '/login', name: 'Login', component: Login, meta: { requiresGuest: true } },
  { path: '/participant-login', name: 'ParticipantLogin', component: ParticipantLogin, meta: { requiresGuest: true } },
  { path: '/register', name: 'Register', component: Register, meta: { requiresGuest: true } },
  { path: '/profile', name: 'Profile', component: Profile, meta: { requiresAuth: true, roles: ['participant'] } },
  { path: '/', redirect: '/scoreboard' },
  { path: '/admin/registrations', component: RegistrationManagement, meta: { requiresAuth: true, roles: ['admin'] } },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  let role = localStorage.getItem('role');

  // Check token expiration and role
  if (token) {
    try {
      const decoded = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Math.floor(Date.now() / 1000);

      if (decoded.exp < currentTime) {
        localStorage.removeItem('token');
        localStorage.removeItem('role');
        return next({ name: 'Login' });
      }

      role = decoded.role || role; // Ensure role is up-to-date from token
      localStorage.setItem('role', role); // Sync localStorage
    } catch (err) {
      localStorage.removeItem('token');
      localStorage.removeItem('role');
      return next({ name: 'Login' });
    }
  }

  // Protect routes that require authentication
  if (to.meta.requiresAuth) {
    if (!token) {
      return next({ name: 'Login' });
    }

    // Allow Admin role to access all protected routes
    if (role === 'admin') {
      return next();
    }

    // Check role-based access for non-Admin users
    if (to.meta.roles && !to.meta.roles.includes(role)) {
      if (role === 'participant') {
        return next({ path: '/profile' });
      }
      return next({ path: '/scoreboard' });
    }
  }

  // Redirect authenticated users away from guest-only routes (login, participant-login, register)
  if (to.meta.requiresGuest && token) {
    if (role === 'admin') return next({ path: '/admin' });
    if (role === 'head_judge') return next({ path: '/head-judge' });
    if (role === 'judge_a') {
      const username = JSON.parse(atob(token.split('.')[1])).username;
      if (username === 'judgea1') return next({ path: '/judge-a1' });
      if (username === 'judgea2') return next({ path: '/judge-a2' });
    }
    if (role === 'judge_b') {
      const username = JSON.parse(atob(token.split('.')[1])).username;
      if (username === 'judgeb1') return next({ path: '/judge-b1' });
      if (username === 'judgeb2') return next({ path: '/judge-b2' });
    }
    if (role === 'participant') return next({ path: '/profile' });
    return next({ path: '/scoreboard' });
  }

  next();
});

export default router;