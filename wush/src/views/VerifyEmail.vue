<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md text-center">
      <h2 class="text-2xl font-bold mb-4 text-gray-800">Verifying Account</h2>
      
      <div v-if="loading" class="text-gray-500">
        <svg class="animate-spin h-8 w-8 mx-auto mb-4 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <p>Please wait...</p>
      </div>

      <div v-else-if="success">
        <div class="text-5xl mb-4">✅</div>
        <h3 class="text-xl font-bold text-green-600 mb-2">Verified!</h3>
        <p class="text-gray-600 mb-6">Your email has been confirmed.</p>
        <router-link to="/participant-login" class="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700 font-bold block">
          Continue to Login
        </router-link>
      </div>

      <div v-else>
        <div class="text-5xl mb-4">❌</div>
        <h3 class="text-xl font-bold text-red-600 mb-2">Verification Failed</h3>
        <p class="text-gray-600 mb-6">{{ error }}</p>
        <router-link to="/login" class="text-blue-600 hover:underline">Back to Home</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';
import { useRoute } from 'vue-router';

const route = useRoute();
const loading = ref(true);
const success = ref(false);
const error = ref('');

onMounted(async () => {
  const token = route.query.token;
  if (!token) {
    error.value = "Invalid verification link.";
    loading.value = false;
    return;
  }

  try {
    await axios.post('/auth/verify-email', { token });
    success.value = true;
  } catch (err) {
    error.value = err.response?.data?.error || 'Verification failed. Token may be expired.';
  } finally {
    loading.value = false;
  }
});
</script>