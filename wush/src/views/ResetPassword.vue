<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
      <h2 class="text-2xl font-bold mb-6 text-center text-gray-800">Set New Password</h2>

      <div v-if="success" class="text-center">
        <div class="text-green-600 font-bold mb-4">Password updated successfully!</div>
        <router-link to="/participant-login" class="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700 font-bold">
          Login Now
        </router-link>
      </div>

      <form v-else @submit.prevent="handleSubmit">
        <div class="mb-4">
          <label class="block text-gray-700 font-bold mb-2">New Password</label>
          <input v-model="password" type="password" required minlength="6" class="w-full p-3 border rounded focus:ring-2 focus:ring-blue-500" />
        </div>
        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">Confirm Password</label>
          <input v-model="confirmPassword" type="password" required class="w-full p-3 border rounded focus:ring-2 focus:ring-blue-500" />
          <p v-if="passwordMismatch" class="text-red-500 text-xs mt-1">Passwords do not match.</p>
        </div>
        <button type="submit" :disabled="loading || passwordMismatch" class="w-full bg-blue-600 text-white font-bold p-3 rounded hover:bg-blue-700 transition disabled:opacity-50">
          {{ loading ? 'Resetting...' : 'Update Password' }}
        </button>
      </form>

      <p v-if="error" class="mt-4 text-red-500 text-center">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from '../axios';
import { useRoute } from 'vue-router';

const route = useRoute();
const password = ref('');
const confirmPassword = ref('');
const loading = ref(false);
const error = ref('');
const success = ref(false);

const token = route.query.token;

const passwordMismatch = computed(() => password.value && password.value !== confirmPassword.value);

const handleSubmit = async () => {
  if (!token) return error.value = "Invalid reset link.";
  if (passwordMismatch.value) return;

  loading.value = true;
  error.value = '';
  try {
    await axios.post('/auth/reset-password', { token, newPassword: password.value });
    success.value = true;
  } catch (err) {
    error.value = err.response?.data?.error || 'Reset failed. Link may be expired.';
  } finally {
    loading.value = false;
  }
};
</script>
