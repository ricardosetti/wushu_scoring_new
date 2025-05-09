<template>
    <div class="container mx-auto p-4 max-w-4xl">
      <h2 class="text-2xl font-bold mb-6 text-center">My Profile</h2>
      <div v-if="loading" class="text-center text-gray-500">Loading...</div>
      <div v-else-if="error" class="text-red-500 mb-4 text-center">{{ error }}</div>
      <div v-else class="bg-white p-6 rounded shadow-md">
        <h3 class="text-xl font-semibold mb-4">Personal Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block font-medium">Full Name:</label>
            <p>{{ registration.first_name }} {{ registration.middle_name }} {{ registration.last_name }}</p>
          </div>
          <div>
            <label class="block font-medium">School:</label>
            <p>{{ registration.school_name }}</p>
          </div>
          <div>
            <label class="block font-medium">Rank:</label>
            <p>{{ registration.participant_rank || 'N/A' }}</p>
          </div>
          <div>
            <label class="block font-medium">Birthdate:</label>
            <p>{{ registration.birthdate }}</p>
          </div>
          <div>
            <label class="block font-medium">Height:</label>
            <p>{{ registration.height_feet }} ft {{ registration.height_inches }} in</p>
          </div>
          <div>
            <label class="block font-medium">Weight:</label>
            <p>{{ registration.weight }} kg</p>
          </div>
          <div>
            <label class="block font-medium">Gender:</label>
            <p>{{ genderLabel }}</p>
          </div>
          <div>
            <label class="block font-medium">Phone:</label>
            <p>{{ registration.phone || 'N/A' }}</p>
          </div>
          <div>
            <label class="block font-medium">Emergency Contact:</label>
            <p>{{ registration.emergency_contact_name || 'N/A' }} ({{ registration.emergency_contact_phone || 'N/A' }})</p>
          </div>
          <div>
            <label class="block font-medium">Address:</label>
            <p>{{ registration.street || '' }}, {{ registration.city || '' }}, {{ registration.state || '' }}, {{ registration.country || '' }} {{ registration.zip_code || '' }}</p>
          </div>
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Account Info</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block font-medium">Email:</label>
            <p>{{ registration.email }}</p>
          </div>
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <p v-for="division in divisions" :key="division.id" class="flex items-center space-x-2">
            {{ division.division_name }}
          </p>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, onMounted } from 'vue';
  import axios from '../axios';
  
  const registration = ref(null);
  const divisions = ref([]);
  const error = ref('');
  const loading = ref(true);
  
  const genderLabel = computed(() => {
    switch (registration.value?.gender) {
      case 'M': return 'Male';
      case 'F': return 'Female';
      case 'O': return 'Other';
      default: return 'N/A';
    }
  });
  
  const fetchProfile = async () => {
    try {
      const token = localStorage.getItem('token');
      if (!token) {
        throw new Error('No token found');
      }
      const payload = JSON.parse(atob(token.split('.')[1]));
      const email = payload.email;
      const userId = payload.userId; // Use userId instead of id

      if (!email || !userId) {
        throw new Error('Invalid token payload');
      }

      const [regResponse, divResponse] = await Promise.all([
        axios.get(`/registrations/email/${email}`),
        axios.get(`/registrations/${userId}/divisions`)
      ]);

      registration.value = regResponse.data;
      divisions.value = divResponse.data;
    } catch (err) {
      error.value = err.response?.data?.error || 'Failed to load profile data.';
    } finally {
      loading.value = false;
    }
  };
  
  onMounted(fetchProfile);
  </script>
  
  <style scoped>
  .container {
    max-width: 850px;
  }
  </style>