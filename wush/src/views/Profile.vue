<template>
  <div class="container mx-auto p-4 max-w-4xl">
    <h2 class="text-2xl font-bold mb-6 text-center">My Profile</h2>
    <div v-if="loading" class="text-center text-gray-500">Loading...</div>
    <div v-else-if="error" class="text-red-500 mb-4 text-center">{{ error }}</div>
    <div v-else class="bg-white p-6 rounded shadow-md">
      <div class="flex justify-end mb-4">
        <button
          v-if="!isEditing"
          @click="startEditing"
          class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition"
        >
          Edit Profile
        </button>
        <div v-else class="space-x-2">
          <button
            @click="saveProfile"
            class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 transition"
          >
            Save
          </button>
          <button
            @click="cancelEditing"
            class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600 transition"
          >
            Cancel
          </button>
        </div>
      </div>

      <!-- View Mode -->
      <div v-if="!isEditing">
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

      <!-- Edit Mode -->
      <div v-else>
        <h3 class="text-xl font-semibold mb-4">Edit Personal Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block font-medium">First Name:</label>
            <input
              v-model="form.first_name"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label class="block font-medium">Middle Name:</label>
            <input
              v-model="form.middle_name"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Last Name:</label>
            <input
              v-model="form.last_name"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label class="block font-medium">Birthdate:</label>
            <input
              v-model="form.birthdate"
              type="date"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label class="block font-medium">Height (Feet):</label>
            <input
              v-model="form.height_feet"
              type="number"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Height (Inches):</label>
            <input
              v-model="form.height_inches"
              type="number"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Weight (kg):</label>
            <input
              v-model="form.weight"
              type="number"
              step="0.01"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Gender:</label>
            <select
              v-model="form.gender"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            >
              <option value="M">Male</option>
              <option value="F">Female</option>
              <option value="O">Other</option>
            </select>
          </div>
          <div>
            <label class="block font-medium">Phone:</label>
            <input
              v-model="form.phone"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Emergency Contact Name:</label>
            <input
              v-model="form.emergency_contact_name"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Emergency Contact Phone:</label>
            <input
              v-model="form.emergency_contact_phone"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Street:</label>
            <input
              v-model="form.street"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">City:</label>
            <input
              v-model="form.city"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">State:</label>
            <input
              v-model="form.state"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Country:</label>
            <input
              v-model="form.country"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Zip Code:</label>
            <input
              v-model="form.zip_code"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label class="block font-medium">Rank:</label>
            <input
              v-model="form.participant_rank"
              type="text"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <h3 class="text-xl font-semibold mt-8 mb-4">Edit Account Info</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block font-medium">Email:</label>
            <input
              v-model="form.email"
              type="email"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <div>
            <label class="block font-medium">Password (leave blank to keep unchanged):</label>
            <input
              v-model="form.password"
              type="password"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div v-if="form.password">
            <label class="block font-medium">Confirm Password:</label>
            <input
              v-model="form.confirmPassword"
              type="password"
              class="w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <p v-if="passwordMismatch" class="text-red-500 text-sm mt-1">Passwords do not match</p>
          </div>
        </div>

        <h3 class="text-xl font-semibold mt-8 mb-4">Edit Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div v-for="division in allDivisions" :key="division.id" class="flex items-center space-x-2">
            <input
              type="checkbox"
              :value="division.id"
              v-model="form.divisions"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            />
            <label>{{ division.division_name }}</label>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from '../axios';

const registration = ref(null);
const divisions = ref([]);
const allDivisions = ref([]);
const error = ref('');
const loading = ref(true);
const isEditing = ref(false);
const form = ref({});

const genderLabel = computed(() => {
  switch (registration.value?.gender) {
    case 'M': return 'Male';
    case 'F': return 'Female';
    case 'O': return 'Other';
    default: return 'N/A';
  }
});

const passwordMismatch = computed(() => {
  return form.value.password && form.value.password !== form.value.confirmPassword;
});

const fetchProfile = async () => {
  try {
    const token = localStorage.getItem('token');
    if (!token) {
      throw new Error('No token found');
    }
    const payload = JSON.parse(atob(token.split('.')[1]));
    const email = payload.email;
    const userId = payload.userId;

    if (!email || !userId) {
      throw new Error('Invalid token payload');
    }

    const [regResponse, divResponse, allDivResponse] = await Promise.all([
      axios.get(`/registrations/email/${email}`),
      axios.get(`/registrations/${userId}/divisions`),
      axios.get('/divisions')
    ]);

    registration.value = regResponse.data;
    divisions.value = divResponse.data;
    allDivisions.value = allDivResponse.data;

    // Initialize form with current data
    form.value = {
      first_name: registration.value.first_name,
      middle_name: registration.value.middle_name || '',
      last_name: registration.value.last_name,
      birthdate: registration.value.birthdate,
      height_feet: registration.value.height_feet || '',
      height_inches: registration.value.height_inches || '',
      weight: registration.value.weight || '',
      gender: registration.value.gender,
      phone: registration.value.phone || '',
      emergency_contact_name: registration.value.emergency_contact_name || '',
      emergency_contact_phone: registration.value.emergency_contact_phone || '',
      street: registration.value.street || '',
      city: registration.value.city || '',
      state: registration.value.state || '',
      country: registration.value.country || '',
      zip_code: registration.value.zip_code || '',
      participant_rank: registration.value.participant_rank || '',
      email: registration.value.email,
      password: '',
      confirmPassword: '',
      divisions: divisions.value.map(d => d.id),
      school_id: registration.value.school_id,
    };
  } catch (err) {
    error.value = err.response?.data?.error || 'Failed to load profile data.';
  } finally {
    loading.value = false;
  }
};

const startEditing = () => {
  isEditing.value = true;
};

const cancelEditing = () => {
  isEditing.value = false;
  // Reset form to original data
  form.value = {
    first_name: registration.value.first_name,
    middle_name: registration.value.middle_name || '',
    last_name: registration.value.last_name,
    birthdate: registration.value.birthdate,
    height_feet: registration.value.height_feet || '',
    height_inches: registration.value.height_inches || '',
    weight: registration.value.weight || '',
    gender: registration.value.gender,
    phone: registration.value.phone || '',
    emergency_contact_name: registration.value.emergency_contact_name || '',
    emergency_contact_phone: registration.value.emergency_contact_phone || '',
    street: registration.value.street || '',
    city: registration.value.city || '',
    state: registration.value.state || '',
    country: registration.value.country || '',
    zip_code: registration.value.zip_code || '',
    participant_rank: registration.value.participant_rank || '',
    email: registration.value.email,
    password: '',
    confirmPassword: '',
    divisions: divisions.value.map(d => d.id),
    school_id: registration.value.school_id,
  };
};

const saveProfile = async () => {
  if (passwordMismatch.value) {
    error.value = 'Passwords do not match';
    return;
  }

  try {
    const token = localStorage.getItem('token');
    const payload = JSON.parse(atob(token.split('.')[1]));
    const userId = payload.userId;

    // Prepare data for update (exclude confirmPassword)
    const updateData = { ...form.value };
    delete updateData.confirmPassword;
    if (!updateData.password) {
      delete updateData.password; // Don't send password if unchanged
    }

    const response = await axios.put(`/registrations/${userId}`, updateData);

    // Update local state with the response
    registration.value = response.data;
    divisions.value = response.data.divisions;

    // Reset form and exit edit mode
    form.value.divisions = divisions.value.map(d => d.id);
    form.value.password = '';
    form.value.confirmPassword = '';
    isEditing.value = false;
    error.value = '';
  } catch (err) {
    error.value = err.response?.data?.error || 'Failed to update profile.';
  }
};

onMounted(fetchProfile);
</script>

<style scoped>
.container {
  max-width: 850px;
}
</style>