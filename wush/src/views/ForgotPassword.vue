<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
      <h2 class="text-2xl font-bold mb-4 text-center text-gray-800">Reset Password</h2>
      <p class="text-gray-600 text-center mb-6 text-sm">Enter your email to receive a password reset link.</p>

      <div v-if="success" class="text-center">
        <div class="text-green-600 bg-green-50 p-4 rounded mb-4">
          <p class="font-bold">Email Sent</p>
          <p class="text-sm">If an account exists for {{ email }}, you will receive instructions shortly.</p>
        </div>
        <router-link to="/participant-login" class="text-blue-600 hover:underline">Return to Login</router-link>
      </div>

      <form v-else @submit.prevent="handleSubmit">
        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">Email Address</label>
          <input 
            v-model="email" 
            type="email" 
            required 
            class="w-full p-3 border rounded focus:ring-2 focus:ring-blue-500"
            placeholder="athlete@example.com"
          />
        </div>
        <button type="submit" :disabled="loading" class="w-full bg-blue-600 text-white font-bold p-3 rounded hover:bg-blue-700 transition disabled:opacity-50">
          {{ loading ? 'Sending...' : 'Send Reset Link' }}
        </button>
      </form>

      <p v-if="error" class="mt-4 text-red-500 text-center">{{ error }}</p>
      
      <div v-if="!success" class="mt-6 text-center">
        <router-link to="/participant-login" class="text-gray-500 hover:text-gray-700 text-sm">Cancel</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from '../axios';

const email = ref('');
const loading = ref(false);
const error = ref('');
const success = ref(false);

const handleSubmit = async () => {
  loading.value = true;
  error.value = '';
  try {
    await axios.post('/auth/forgot-password', { email: email.value });
    success.value = true;
  } catch (err) {
    error.value = err.response?.data?.error || 'Request failed.';
  } finally {
    loading.value = false;
  }
};
</script>