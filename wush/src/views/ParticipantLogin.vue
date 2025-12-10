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
            class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            placeholder="athlete@example.com"
            required
          />
        </div>
        <div class="mb-2">
          <label class="block text-gray-700 font-bold mb-2" for="password">Password</label>
          <input
            v-model="password"
            type="password"
            id="password"
            class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            required
          />
        </div>
        
        <!-- Forgot Password Link -->
        <div class="text-right mb-6">
          <router-link to="/forgot-password" class="text-xs text-blue-600 hover:underline">Forgot Password?</router-link>
        </div>

        <button
          type="submit"
          class="w-full bg-green-600 text-white font-bold p-3 rounded hover:bg-green-700 transition"
        >
          Sign In
        </button>
      </form>
      
      <p v-if="error" class="mt-4 text-red-500 text-center bg-red-50 p-2 rounded border border-red-100">{{ error }}</p>
      
      <div class="mt-6 text-center border-t pt-4 space-y-3">
        <p class="text-sm text-gray-600">Don't have an account?</p>
        <!-- Link to new Signup Page -->
        <router-link to="/signup" class="text-green-600 font-bold hover:underline border border-green-600 px-4 py-2 rounded inline-block">
          Create New Account
        </router-link>
        
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
  error.value = ''; // Clear previous errors
  try {
    const res = await axios.post('/auth/login', {
      email: email.value,
      password: password.value,
    });

    localStorage.setItem('token', res.data.token);
    localStorage.setItem('role', res.data.role);

    // Redirect athletes to their profile
    router.push('/profile');
  } catch (err) {
    // Now that axios.js is fixed, this error will actually show up!
    error.value = err.response?.data?.error || 'Login failed. Please check your credentials.';
  }
};
</script>