<template>
  <div class="container mx-auto p-4 max-w-2xl">
    <div class="bg-white p-8 rounded-lg shadow-lg">
      <h2 class="text-3xl font-bold mb-2 text-center text-green-800">Member Registration</h2>
      
      <div v-if="activeTournament" class="bg-green-50 border border-green-200 rounded-lg p-4 mb-6 text-center">
        <p class="text-green-800 font-medium uppercase tracking-wide text-xs">Registering for</p>
        <h3 class="text-xl font-bold text-green-900 mt-1">{{ activeTournament.tournament_title }}</h3>
      </div>

      <div v-if="loading" class="text-center py-8">Loading...</div>
      <div v-else-if="error" class="bg-red-100 text-red-700 p-4 rounded mb-6">{{ error }}</div>

      <form v-else @submit.prevent="handleSubmit">
        <p class="mb-6 text-gray-600 text-center">
          Welcome back! Please confirm your school and divisions for this event.
        </p>

        <div class="mb-6">
          <label class="block text-sm font-bold text-gray-700 mb-2">School for this Event *</label>
          <select v-model="school_id" required class="w-full border rounded p-3 bg-white focus:ring-2 focus:ring-green-500">
            <option :value="null" disabled>-- Choose a School --</option>
            <option v-for="s in availableSchools" :key="s.id" :value="s.id">{{ s.school_name }}</option>
          </select>
        </div>

        <div class="mb-6">
          <label class="block text-sm font-bold text-gray-700 mb-2">Current Rank / Belt *</label>
          <input v-model="participant_rank" required class="w-full border rounded p-3" placeholder="e.g. Black Belt" />
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Select Divisions</h3>
        <div class="grid grid-cols-1 gap-3 mb-8">
          <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-3 p-3 border rounded hover:bg-gray-50 cursor-pointer">
            <input type="checkbox" :value="division.id" v-model="selectedDivisions" class="h-5 w-5 text-green-600" />
            <span class="font-medium">{{ division.division_name }}</span>
          </label>
        </div>

        <button type="submit" :disabled="submitting" class="w-full bg-green-600 text-white font-bold py-3 rounded hover:bg-green-700 disabled:opacity-50">
          {{ submitting ? 'Registering...' : 'Complete Registration' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const activeTournament = ref(null);
const availableSchools = ref([]);
const divisions = ref([]);
const selectedDivisions = ref([]);
const school_id = ref(null);
const participant_rank = ref('');
const loading = ref(true);
const error = ref('');
const submitting = ref(false);

const fetchData = async () => {
  try {
    // 1. Get Active Tournament
    const tourneyRes = await axios.get('/tournaments');
    activeTournament.value = tourneyRes.data.find(t => t.is_active) || tourneyRes.data[0];
    
    if (!activeTournament.value) throw new Error("No active tournament.");
    const tid = activeTournament.value.tournament_id;

    // 2. Get Data
    const [schoolRes, divRes] = await Promise.all([
      axios.get('/schools/public', { params: { tournament_id: tid } }),
      axios.get('/divisions', { params: { tournament_id: tid } })
    ]);

    availableSchools.value = schoolRes.data;
    divisions.value = divRes.data;

  } catch (e) {
    error.value = "Failed to load event data.";
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  if (!selectedDivisions.value.length) return alert("Select at least one division.");
  
  try {
    submitting.value = true;
    // Call the MEMBER specific endpoint
    await axios.post('/registrations/join', {
      tournament_id: activeTournament.value.tournament_id,
      school_id: school_id.value,
      participant_rank: participant_rank.value,
      divisions: selectedDivisions.value
    });
    
    alert("Registration successful!");
    router.push('/profile');
  } catch (e) {
    error.value = e.response?.data?.error || "Registration failed.";
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchData);
</script>