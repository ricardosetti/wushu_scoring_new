<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md border-t-4 border-green-500">
      <h2 class="text-3xl font-bold mb-2 text-center text-gray-800">Athlete Login</h2>
      <p class="text-center text-gray-500 mb-6">Sign in to view profile and register for events</p>
      
      <form @submit.prevent="login">
        <div class="mb-4">
          <label class="block text-gray-700 font-bold mb-2" for="email">Email Address</label>
          <input
            v-model="email"
            type="email"
            id="email"
            class="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-green-500"
            placeholder="athlete@example.com"
            required
          />
        </div>
        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2" for="password">Password</label>
          <input
            v-model="password"
            type="password"
            id="password"
            class="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-green-500"
            required
          />
        </div>
        <button
          type="submit"
          class="w-full bg-green-600 text-white font-bold p-3 rounded hover:bg-green-700 transition"
        >
          Sign In
        </button>
      </form>
      
      <p v-if="error" class="mt-4 text-red-500 text-center bg-red-50 p-2 rounded border border-red-100">{{ error }}</p>
      
      <div class="mt-6 text-center border-t pt-4 space-y-2">
        <p class="text-sm text-gray-600">Don't have an account?</p>
        <router-link to="/register" class="text-green-600 font-bold hover:underline">Register New Account</router-link>
        
        <div class="pt-2">
          <router-link to="/login" class="text-gray-400 text-xs hover:text-gray-600">Staff Login</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const email = ref('');
const password = ref('');
const error = ref('');
const router = useRouter();

const login = async () => {
  try {
    // We send 'email' this time
    const res = await axios.post('/auth/login', {
      email: email.value,
      password: password.value,
    });

    localStorage.setItem('token', res.data.token);
    localStorage.setItem('role', res.data.role);

    router.push('/profile');
  } catch (err) {
    error.value = err.response?.data?.error || 'Login failed';
  }
};
</script>