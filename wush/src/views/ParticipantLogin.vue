<template>
    <div class="min-h-screen flex items-center justify-center bg-gray-100">
      <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6 text-center">Participant Login</h2>
        <form @submit.prevent="login">
          <div class="mb-4">
            <label class="block text-gray-700 mb-2" for="email">Email</label>
            <input
              v-model="email"
              type="email"
              id="email"
              class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your email"
              required
            />
          </div>
          <div class="mb-6">
            <label class="block text-gray-700 mb-2" for="password">Password</label>
            <input
              v-model="password"
              type="password"
              id="password"
              class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your password"
              required
            />
          </div>
          <button
            type="submit"
            class="w-full bg-blue-500 text-white p-3 rounded-lg hover:bg-blue-600 transition"
          >
            Login
          </button>
        </form>
        <p v-if="error" class="mt-4 text-red-500 text-center">{{ error }}</p>
        <p class="mt-4 text-center">
          <router-link to="/login" class="text-blue-500 hover:underline">Admin/Judge Login</router-link>
        </p>
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