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
import TournamentManagement from '../views/TournamentManagement.vue';
import RegistrationManagement from '../views/RegistrationManagement.vue';
import Login from '../views/Login.vue';
import ParticipantLogin from '../views/ParticipantLogin.vue';
import Register from '../views/Register.vue';
import Profile from '../views/Profile.vue';
import TournamentLanding from '../views/TournamentLanding.vue'; 
import PublicRegister from '../views/PublicRegister.vue';
import MemberRegister from '../views/MemberRegister.vue';
import UserManagement from '../views/UserManagement.vue'; // <--- Import

// NEW AUTH VIEWS
import SignUp from '../views/SignUp.vue';
import ForgotPassword from '../views/ForgotPassword.vue';
import ResetPassword from '../views/ResetPassword.vue';
import VerifyEmail from '../views/VerifyEmail.vue';

const routes = [
  // Public Landing Page
  { 
    path: '/t/:id', 
    component: TournamentLanding, 
    meta: { requiresAuth: false, hideNavbar: true } 
  },

  // Auth & Account Creation (New)
  { 
    path: '/signup', 
    component: SignUp, 
    meta: { requiresGuest: true, hideNavbar: true } 
  },
  { 
    path: '/forgot-password', 
    component: ForgotPassword, 
    meta: { requiresGuest: true, hideNavbar: true } 
  },
  { 
    path: '/reset-password', 
    component: ResetPassword, 
    meta: { requiresGuest: true, hideNavbar: true } 
  },
  { 
    path: '/verify-email', 
    component: VerifyEmail, 
    meta: { requiresAuth: false, hideNavbar: true } 
  },

  // Existing Routes
  { path: '/judge-a1', component: JudgeA1, meta: { requiresAuth: true, roles: ['judge_a'] } },
  { path: '/judge-a2', component: JudgeA2, meta: { requiresAuth: true, roles: ['judge_a'] } },
  { path: '/judge-b1', component: JudgeB1, meta: { requiresAuth: true, roles: ['judge_b'] } },
  { path: '/judge-b2', component: JudgeB2, meta: { requiresAuth: true, roles: ['judge_b'] } },
  { path: '/head-judge', component: HeadJudge, meta: { requiresAuth: true, roles: ['head_judge'] } },
  { path: '/scoreboard', component: Scoreboard },
  { path: '/leaderboard', component: Leaderboard },
  
  // Admin Routes
  { path: '/admin', component: Admin, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/schools', component: SchoolManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/participants', component: ParticipantManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/divisions', component: DivisionManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/tournaments', component: TournamentManagement, meta: { requiresAuth: true, roles: ['admin'] } },
  { path: '/admin/registrations', component: RegistrationManagement, meta: { requiresAuth: true, roles: ['admin'] } },
    { 
    path: '/admin/users', 
    component: UserManagement, 
    meta: { requiresAuth: true, roles: ['admin'] } 
  },

  // Auth Routes
  { path: '/login', name: 'Login', component: Login, meta: { requiresGuest: true, hideNavbar: true } },
  { path: '/participant-login', name: 'ParticipantLogin', component: ParticipantLogin, meta: { requiresGuest: true, hideNavbar: true } },
  
  // Registration Flow
  { 
    path: '/register', 
    name: 'Register', 
    component: PublicRegister, // Uses the new PublicRegister view
    meta: { requiresGuest: true, hideNavbar: true } 
  },
  { 
    path: '/register/member', 
    name: 'MemberRegister', 
    component: MemberRegister, 
    meta: { requiresAuth: true, roles: ['participant'], hideNavbar: false } 
  },
  
  { path: '/profile', name: 'Profile', component: Profile, meta: { requiresAuth: true, roles: ['participant'] } },
  
  { path: '/', redirect: '/scoreboard' },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
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

      role = decoded.role || role; 
      localStorage.setItem('role', role); 
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

    if (role === 'admin') {
      return next();
    }

    if (to.meta.roles && !to.meta.roles.includes(role)) {
      if (role === 'participant') {
        return next({ path: '/profile' });
      }
      return next({ path: '/scoreboard' });
    }
  }

  // Redirect authenticated users away from guest-only routes
  if (to.meta.requiresGuest && token) {
    if (role === 'admin') return next({ path: '/admin' });
    if (role === 'head_judge') return next({ path: '/head-judge' });
    if (role === 'judge_a') return next({ path: '/judge-a1' }); // Default to A1 logic or dashboard
    if (role === 'participant') return next({ path: '/profile' });
    return next({ path: '/scoreboard' });
  }

  next();
});

export default router;