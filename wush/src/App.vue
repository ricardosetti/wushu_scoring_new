<template>
  <div>
    <nav class="bg-darkgray p-4">
      <ul class="flex space-x-4 text-white">
        <!-- Admin: Show all links -->
        <li v-if="role === 'admin' || role === 'head_judge'">
          <router-link to="/head-judge" class="mx-2 hover:underline">Head Judge</router-link>
        </li>
        <li v-if="role === 'admin' || role === 'judge_a'">
          <router-link to="/judge-a1" class="mx-2 hover:underline">Judge A1</router-link>
        </li>
        <li v-if="role === 'admin' || role === 'judge_a'">
          <router-link to="/judge-a2" class="mx-2 hover:underline">Judge A2</router-link>
        </li>
        <li v-if="role === 'admin' || role === 'judge_b'">
          <router-link to="/judge-b1" class="mx-2 hover:underline">Judge B1</router-link>
        </li>
        <li v-if="role === 'admin' || role === 'judge_b'">
          <router-link to="/judge-b2" class="mx-2 hover:underline">Judge B2</router-link>
        </li>
        <li v-if="role === 'admin' || !role">
          <router-link to="/scoreboard" class="mx-2 hover:underline">Scoreboard</router-link>
        </li>
        <li v-if="role === 'admin' || !role">
          <router-link to="/leaderboard" class="mx-2 hover:underline">Leaderboard</router-link>
        </li>
        <li v-if="role === 'admin'">
          <router-link to="/admin" class="mx-2 hover:underline">Admin</router-link>
        </li>
        <li v-if="role">
          <button @click="logout" class="mx-2 hover:underline">Logout</button>
        </li>
        <li v-else>
          <router-link to="/login" class="mx-2 hover:underline">Login</router-link>
        </li>
      </ul>
    </nav>
    <router-view />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();
const role = ref(localStorage.getItem('role') || '');

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  role.value = '';
  router.push('/login');
};

// Watch for route changes to update role (e.g., after login/logout)
watch(
  () => route.path,
  () => {
    role.value = localStorage.getItem('role') || '';
  }
);

onMounted(() => {
  role.value = localStorage.getItem('role') || '';
});
</script>