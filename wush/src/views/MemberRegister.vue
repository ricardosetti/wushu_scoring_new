<template>
  <div class="container mx-auto p-4 max-w-2xl">
    <div class="bg-white p-8 rounded-lg shadow-lg">
      <h2 class="text-3xl font-bold mb-6 text-center text-green-800">Event Registration</h2>

      <div v-if="loading" class="text-center py-8 text-gray-500">Loading open events...</div>
      <div v-else-if="error" class="bg-red-100 text-red-700 p-4 rounded mb-6 text-center">{{ error }}</div>

      <!-- No Events Open -->
      <div v-else-if="openTournaments.length === 0" class="text-center py-12 text-gray-600">
        <p class="text-xl mb-4">No tournaments are currently open for registration.</p>
        <button @click="$router.push('/profile')" class="text-blue-600 hover:underline">Back to Profile</button>
      </div>

      <!-- Registration Form -->
      <form v-else @submit.prevent="handleSubmit">
        
        <!-- TOURNAMENT SELECTION -->
        <div class="mb-6">
          <label class="block text-sm font-bold text-gray-700 mb-2">Select Event *</label>
          <select 
            v-model="selectedTournamentId" 
            @change="onTournamentChange" 
            required 
            class="w-full border rounded p-3 bg-white focus:ring-2 focus:ring-green-500"
          >
            <option :value="null" disabled>-- Choose an Event --</option>
            <option v-for="t in openTournaments" :key="t.tournament_id" :value="t.tournament_id">
              {{ t.tournament_title }} (Ends: {{ formatDate(t.registration_end_date) }})
            </option>
          </select>
        </div>

        <div v-if="selectedTournamentId">
          <!-- School Selection -->
          <div class="mb-4">
            <label class="block text-sm font-bold text-gray-700 mb-2">School for this Event *</label>
            <select v-model="form.school_id" required class="w-full border rounded p-3 bg-white">
              <option :value="null" disabled>-- Choose a School --</option>
              <option v-for="s in availableSchools" :key="s.id" :value="s.id">{{ s.school_name }}</option>
            </select>
          </div>

          <!-- Event Specific Stats -->
          <h3 class="text-lg font-bold text-gray-700 mb-3 border-b pb-2 mt-6">Athlete Stats (Current)</h3>
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Rank/Belt *</label><input v-model="form.participant_rank" required class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Weight (kg)</label><input v-model="form.weight" type="number" step="0.1" class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Height (ft)</label><input v-model="form.height_feet" type="number" class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Height (in)</label><input v-model="form.height_inches" type="number" class="w-full border rounded p-2" /></div>
          </div>

          <!-- Divisions -->
          <h3 class="text-lg font-bold text-gray-700 mb-3 border-b pb-2 mt-6">Select Divisions</h3>
          <div class="grid grid-cols-1 gap-2 mb-8 max-h-60 overflow-y-auto border p-2 rounded">
            <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-3 p-2 hover:bg-gray-50 cursor-pointer">
              <input type="checkbox" :value="division.id" v-model="selectedDivisions" class="h-5 w-5 text-green-600 rounded" />
              <span class="font-medium text-gray-700">{{ division.division_name }}</span>
            </label>
            <div v-if="divisions.length === 0" class="text-gray-500 italic p-2">No active divisions found for this event.</div>
          </div>

          <button type="submit" :disabled="submitting" class="w-full bg-green-600 text-white font-bold py-3 rounded hover:bg-green-700 disabled:opacity-50 transition shadow-lg">
            {{ submitting ? 'Registering...' : 'Complete Registration' }}
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

// Form defaults
const form = ref({
  school_id: null,
  participant_rank: '',
  height_feet: null, 
  height_inches: null, 
  weight: null
});

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : 'TBD';

const fetchInitialData = async () => {
  try {
    // 1. Get Open Tournaments (Public Endpoint)
    // Note: Ensure your backend has /tournaments/open implemented
    // If not, we can filter client-side for now
    const res = await axios.get('/tournaments'); 
    const allTournaments = res.data;
    
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

    // Filter logic: Start Date <= Today <= End Date
    openTournaments.value = allTournaments.filter(t => {
       if (!t.registration_start_date || !t.registration_end_date) return false;
       return t.registration_start_date <= today && t.registration_end_date >= today;
    });

    // 2. Pre-select if passed in URL (from Landing Page)
    if (route.query.tournament_id) {
      const tid = parseInt(route.query.tournament_id);
      if (openTournaments.value.some(t => t.tournament_id === tid)) {
        selectedTournamentId.value = tid;
        await onTournamentChange(); // Load context
      }
    }

    // 3. Pre-fill user data from profile (optional convenience)
    const profileRes = await axios.get('/users/profile');
    const u = profileRes.data.user;
    if (u) {
      form.value.height_feet = u.height_feet;
      form.value.height_inches = u.height_inches;
      form.value.weight = u.weight;
      // rank usually changes per event, so leave blank or last value
    }

  } catch (e) {
    console.error(e);
    error.value = "Failed to load events.";
  } finally {
    loading.value = false;
  }
};

const onTournamentChange = async () => {
  if (!selectedTournamentId.value) return;
  try {
    // Load context for this specific tournament
    // Note: We use public endpoints or ensure these are accessible
    const [schoolRes, divRes] = await Promise.all([
      // Fetch schools active for this tournament
      axios.get('/schools/public', { params: { tournament_id: selectedTournamentId.value } }),
      // Fetch divisions active for this tournament
      axios.get('/divisions', { params: { tournament_id: selectedTournamentId.value } })
    ]);
    
    availableSchools.value = schoolRes.data;
    divisions.value = divRes.data;
    selectedDivisions.value = []; // Reset choices
  } catch (e) {
    console.error(e);
    alert("Error loading event details");
  }
};

const handleSubmit = async () => {
  if (!selectedTournamentId.value) return alert("Select an event.");
  if (!form.value.school_id) return alert("Select a school.");
  if (!selectedDivisions.value.length) return alert("Select at least one division.");
  
  try {
    submitting.value = true;
    await axios.post('/registrations/join', {
      tournament_id: selectedTournamentId.value,
      divisions: selectedDivisions.value,
      ...form.value
    });
    
    alert("Registration successful!");
    router.push('/profile');
  } catch (e) {
    error.value = e.response?.data?.error || "Registration failed.";
    window.scrollTo(0,0);
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchInitialData);
</script>