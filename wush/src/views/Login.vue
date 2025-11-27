<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-800">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md border-t-4 border-blue-600">
      <h2 class="text-2xl font-bold mb-2 text-center text-gray-800">Staff Login</h2>
      <p class="text-center text-gray-500 mb-6 text-sm">Admin • Head Judge • Judges</p>
      
      <form @submit.prevent="login">
        <div class="mb-4">
          <label class="block text-gray-700 font-bold mb-2" for="username">Username</label>
          <input
            v-model="username"
            type="text"
            id="username"
            class="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="e.g. admin, judge_a1"
            required
          />
        </div>
        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2" for="password">Password</label>
          <input
            v-model="password"
            type="password"
            id="password"
            class="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>
        <button
          type="submit"
          class="w-full bg-blue-600 text-white font-bold p-3 rounded hover:bg-blue-700 transition"
        >
          System Login
        </button>
      </form>
      
      <p v-if="error" class="mt-4 text-red-500 text-center bg-red-50 p-2 rounded border border-red-100">{{ error }}</p>
      
      <div class="mt-6 text-center border-t pt-4">
        <p class="text-sm text-gray-600">Are you an Athlete?</p>
        <router-link to="/participant-login" class="text-blue-600 font-bold hover:underline">Go to Participant Login</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const username = ref('');
const password = ref('');
const error = ref('');
const router = useRouter();

const login = async () => {
  try {
    const res = await axios.post('/auth/login', {
      username: username.value,
      password: password.value,
    });

    localStorage.setItem('token', res.data.token);
    localStorage.setItem('role', res.data.role);

    // Redirect based on role
    if (res.data.role === 'admin') router.push('/admin');
    else if (res.data.role === 'head_judge') router.push('/head-judge');
    else if (res.data.role.startsWith('judge')) router.push(`/${res.data.role.replace('_', '-')}`); // e.g. /judge-a1
    else router.push('/scoreboard');

  } catch (err) {
    error.value = err.response?.data?.error || 'Login failed';
  }
};
</script>