<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4 py-12">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-3xl">
      <h2 class="text-3xl font-bold mb-2 text-center text-blue-800">New Athlete Registration</h2>
      
      <div class="text-center mb-8 text-sm">
        <p class="text-gray-600">Already have an account?</p>
        <router-link to="/participant-login" class="text-blue-600 font-bold hover:underline">Log In to Register Faster</router-link>
      </div>

      <div v-if="loading" class="text-center py-8 text-gray-500">Loading events...</div>
      <div v-else-if="error" class="bg-red-100 text-red-700 p-4 rounded mb-6 text-center">{{ error }}</div>
      
      <div v-else-if="openTournaments.length === 0" class="text-center py-12 text-gray-600">
        <p class="text-xl">No tournaments are currently open for registration.</p>
      </div>

      <form v-else @submit.prevent="handleSubmit">
        
        <!-- STEP 1: EVENT SELECTION -->
        <div class="mb-8 p-5 bg-blue-50 rounded-xl border border-blue-100">
          <h3 class="text-lg font-bold text-blue-900 mb-4 border-b border-blue-200 pb-2">1. Choose Event</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Select Tournament *</label>
              <select 
                v-model="selectedTournamentId" 
                @change="onTournamentChange"
                required 
                class="w-full border rounded p-2.5 bg-white focus:ring-2 focus:ring-blue-500"
              >
                <option :value="null" disabled>-- Select Event --</option>
                <option v-for="t in openTournaments" :key="t.tournament_id" :value="t.tournament_id">
                  {{ t.tournament_title }}
                </option>
              </select>
            </div>
            
            <div v-if="selectedTournamentId">
              <label class="block text-sm font-bold text-gray-700 mb-1">Select School *</label>
              <select v-model="form.school_id" required class="w-full border rounded p-2.5 bg-white focus:ring-2 focus:ring-blue-500">
                <option :value="null" disabled>-- Select School --</option>
                <option v-for="s in availableSchools" :key="s.id" :value="s.id">{{ s.school_name }}</option>
              </select>
            </div>
          </div>
        </div>

        <!-- STEP 2: PERSONAL INFO -->
        <div v-if="selectedTournamentId">
          <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2">2. Personal Details</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
            <InputField label="First Name *" v-model="form.first_name" required />
            <InputField label="Last Name *" v-model="form.last_name" required />
            <InputField label="Date of Birth *" v-model="form.birthdate" type="date" required />
            <SelectField label="Gender *" v-model="form.gender" :options="genderOptions" required />
            <InputField label="Email *" v-model="form.email" type="email" required />
            <InputField label="Password *" v-model="form.password" type="password" required />
          </div>

          <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2 mt-6">3. Athlete Stats (For this event)</h3>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
             <div><label class="block text-sm font-bold text-gray-700 mb-1">Rank/Belt</label><input v-model="form.participant_rank" required class="w-full border rounded p-2" /></div>
             <div><label class="block text-sm font-bold text-gray-700 mb-1">Weight (kg)</label><input v-model="form.weight" type="number" step="0.1" class="w-full border rounded p-2" /></div>
             <div><label class="block text-sm font-bold text-gray-700 mb-1">Height (ft)</label><input v-model="form.height_feet" type="number" class="w-full border rounded p-2" /></div>
             <div><label class="block text-sm font-bold text-gray-700 mb-1">Height (in)</label><input v-model="form.height_inches" type="number" class="w-full border rounded p-2" /></div>
          </div>

          <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2 mt-6">4. Select Divisions</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-8 max-h-60 overflow-y-auto border p-2 rounded">
            <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-3 p-2 hover:bg-gray-50 cursor-pointer">
              <input type="checkbox" :value="division.id" v-model="selectedDivisions" class="h-5 w-5 text-blue-600 rounded" />
              <span class="font-medium text-gray-700">{{ division.division_name }}</span>
            </label>
          </div>

          <button type="submit" :disabled="submitting" class="w-full bg-blue-600 text-white font-bold py-3 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 shadow-md">
            {{ submitting ? 'Creating Account...' : 'Register Now' }}
          </button>
        </div>

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

const openTournaments = ref([]);
const selectedTournamentId = ref(null);
const availableSchools = ref([]);
const divisions = ref([]);
const selectedDivisions = ref([]);
const loading = ref(true);
const error = ref('');
const submitting = ref(false);

const form = ref({ 
  first_name: '', last_name: '', email: '', password: '',
  birthdate: '', gender: '',
  school_id: null, participant_rank: '',
  height_feet: null, height_inches: null, weight: null
});

const genderOptions = [
  { value: 'M', label: 'Male' },
  { value: 'F', label: 'Female' },
  { value: 'O', label: 'Other' }
];

const fetchInitialData = async () => {
  try {
    const res = await axios.get('/tournaments');
    const allTournaments = res.data;
    const today = new Date().toISOString().split('T')[0];

    // Filter Open Tournaments
    openTournaments.value = allTournaments.filter(t => {
       if (!t.registration_start_date || !t.registration_end_date) return false;
       return t.registration_start_date <= today && t.registration_end_date >= today;
    });

    // Auto-select if URL param exists
    if (route.query.tournament_id) {
      const tid = parseInt(route.query.tournament_id);
      if (openTournaments.value.some(t => t.tournament_id === tid)) {
        selectedTournamentId.value = tid;
        await onTournamentChange();
      }
    }
  } catch (e) {
    error.value = "Failed to load events.";
  } finally {
    loading.value = false;
  }
};

const onTournamentChange = async () => {
  if (!selectedTournamentId.value) return;
  try {
    const [schoolRes, divRes] = await Promise.all([
      axios.get('/schools/public', { params: { tournament_id: selectedTournamentId.value } }),
      axios.get('/divisions', { params: { tournament_id: selectedTournamentId.value } })
    ]);
    availableSchools.value = schoolRes.data;
    divisions.value = divRes.data;
    selectedDivisions.value = [];
  } catch (e) {
    console.error(e);
  }
};

const handleSubmit = async () => {
  if (!selectedDivisions.value.length) return alert("Select at least one division.");
  
  try {
    submitting.value = true;
    
    // We send everything to the signup endpoint. 
    // The backend needs to be smart enough to handle registration + signup in one go.
    // OR we chain calls here.
    // Current backend /auth/signup ONLY creates a user. It doesn't register them for an event.
    // FIX: We need a new endpoint or chain calls.
    
    // STRATEGY: 
    // 1. Signup (Create User)
    const signupRes = await axios.post('/auth/signup', form.value);
    const userId = signupRes.data.userId; // Assuming backend returns this
    
    // 2. We can't register immediately because they aren't verified/logged in.
    // User needs to verify email first.
    
    alert("Account created! Please check your email to verify your account, then log in to complete your registration.");
    router.push('/participant-login');

  } catch (e) {
    error.value = e.response?.data?.error || "Registration failed.";
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchInitialData);
</script>