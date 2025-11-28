<template>
  <div class="container mx-auto p-4 max-w-4xl">
    <div class="bg-white p-8 rounded-lg shadow-lg">
      <h2 class="text-3xl font-bold mb-2 text-center text-blue-800">New Athlete Registration</h2>
      
      <div class="text-center mb-6">
        <p class="text-gray-600">Already have an account?</p>
        <router-link to="/login" class="text-blue-600 font-bold hover:underline">Log In to Register Faster</router-link>
      </div>

      <div v-if="activeTournament" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 text-center">
        <p class="text-blue-800 font-medium uppercase tracking-wide text-xs">Registering for</p>
        <h3 class="text-xl font-bold text-blue-900 mt-1">{{ activeTournament.tournament_title }}</h3>
      </div>

      <div v-if="loading" class="text-center py-8 text-gray-500">Loading...</div>
      <div v-else-if="error" class="bg-red-100 text-red-700 p-4 rounded mb-6">{{ error }}</div>

      <form v-else @submit.prevent="handleSubmit">
        <div class="mb-8 p-4 bg-gray-50 rounded border border-gray-200">
          <label class="block text-sm font-bold text-gray-700 mb-2">Select Your School *</label>
          <select v-model="form.school_id" required class="w-full border rounded p-2 bg-white">
            <option :value="null" disabled>-- Choose a School --</option>
            <option v-for="s in availableSchools" :key="s.id" :value="s.id">{{ s.school_name }}</option>
          </select>
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Student Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <InputField label="First Name *" v-model="form.first_name" required />
          <InputField label="Last Name *" v-model="form.last_name" required />
          <InputField label="Birthdate *" v-model="form.birthdate" type="date" required />
          <SelectField label="Gender *" v-model="form.gender" :options="genderOptions" required />
          <InputField label="Email *" v-model="form.email" type="email" required />
          <InputField label="Create Password *" v-model="form.password" type="password" required />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
           <InputField label="Height (ft)" v-model="form.height_feet" type="number" />
           <InputField label="Height (in)" v-model="form.height_inches" type="number" />
           <InputField label="Weight (kg)" v-model="form.weight" type="number" step="0.1" />
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Select Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-8">
          <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-3 p-3 border rounded hover:bg-gray-50 cursor-pointer">
            <input type="checkbox" :value="division.id" v-model="selectedDivisions" class="h-5 w-5 text-blue-600" />
            <span>{{ division.division_name }}</span>
          </label>
        </div>

        <button type="submit" :disabled="submitting" class="w-full bg-blue-600 text-white font-bold py-3 rounded hover:bg-blue-700 disabled:opacity-50">
          {{ submitting ? 'Creating Account...' : 'Create Account & Register' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';
import { useRouter, useRoute } from 'vue-router';
import InputField from '../components/InputField.vue';
import SelectField from '../components/SelectField.vue';

const router = useRouter();
const route = useRoute();
const activeTournament = ref(null);
const availableSchools = ref([]);
const divisions = ref([]);
const selectedDivisions = ref([]);
const loading = ref(true);
const error = ref('');
const submitting = ref(false);

// Check for pre-filled token
const token = route.query.token; 

const form = ref({
  first_name: '', last_name: '', birthdate: '', gender: '', 
  email: '', password: '', school_id: null, 
  height_feet: null, height_inches: null, weight: null
});

const genderOptions = [{ value: 'M', label: 'Male' }, { value: 'F', label: 'Female' }, { value: 'O', label: 'Other' }];

const fetchData = async () => {
  try {
    // 1. Get Active Tournament
    const tourneyRes = await axios.get('/tournaments');
    activeTournament.value = tourneyRes.data.find(t => t.is_active) || tourneyRes.data[0];
    if (!activeTournament.value) throw new Error("No active tournament.");

    const tid = activeTournament.value.tournament_id;

    // 2. Get Schools & Divisions
    const [schoolRes, divRes] = await Promise.all([
      axios.get('/schools/public', { params: { tournament_id: tid } }),
      axios.get('/divisions', { params: { tournament_id: tid } })
    ]);

    availableSchools.value = schoolRes.data;
    divisions.value = divRes.data;

    // 3. Handle Invite Token (Auto-select school)
    if (token) {
       const tokenRes = await axios.get(`/register/validate-token?token=${token}`);
       form.value.school_id = tokenRes.data.school.id;
    }

  } catch (e) {
    error.value = "Failed to load event details.";
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  if (!selectedDivisions.value.length) return alert("Select at least one division.");
  try {
    submitting.value = true;
    await axios.post('/register', {
      ...form.value,
      divisions: selectedDivisions.value,
      tournament_id: activeTournament.value.tournament_id
    });
    alert("Account created! Please login.");
    router.push('/participant-login');
  } catch (e) {
    error.value = e.response?.data?.error || "Registration failed.";
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchData);
</script>