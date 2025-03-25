<template>
    <div class="min-h-screen flex items-center justify-center bg-gray-100">
      <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6 text-center">Login</h2>
        <form @submit.prevent="login">
          <div class="mb-4">
            <label class="block text-gray-700 mb-2" for="username">Username</label>
            <input
              v-model="username"
              type="text"
              id="username"
              class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter your username"
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
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  import axios from '../axios'; // Use custom Axios instance
  import { useRouter } from 'vue-router';
  
  const username = ref('');
  const password = ref('');
  const error = ref('');
  const router = useRouter();
  
  const login = async () => {
  try {
    const res = await axios.post(`http://${import.meta.env.VITE_SERVER_HOST}:${import.meta.env.VITE_SERVER_PORT}/auth/login`, {
      username: username.value,
      password: password.value,
    });

    // Store the token and role in localStorage
    localStorage.setItem('token', res.data.token);
    localStorage.setItem('role', res.data.role);

    // Let the navigation guard handle the redirect
    router.push('/'); // Redirect to root, navigation guard will handle the rest
  } catch (err) {
    error.value = err.response?.data?.error || 'Login failed';
  }
};
</script>