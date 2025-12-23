<template>
  <div class="container mx-auto p-4">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Roster & Bracket Engine</h2>

    <!-- STEP 1: Select Context -->
    <div class="bg-white p-6 rounded-lg shadow mb-6 border-l-4 border-blue-600">
      <h3 class="text-lg font-bold mb-4">1. Select Tournament</h3>
      <select v-model="selectedTournamentId" @change="resetSimulation" class="w-full border p-3 rounded text-lg">
        <option :value="null" disabled>-- Choose Tournament --</option>
        <option v-for="t in tournaments" :key="t.tournament_id" :value="t.tournament_id">
          {{ t.tournament_title }}
        </option>
      </select>
    </div>

    <!-- STEP 2: Configure Criteria -->
    <div v-if="selectedTournamentId" class="bg-white p-6 rounded-lg shadow mb-6 border-l-4 border-indigo-600">
      <h3 class="text-lg font-bold mb-4">2. Bracket Separation Criteria</h3>
      <p class="text-sm text-gray-600 mb-4">Select how you want to split the participants into brackets. Division is always applied.</p>
      
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <!-- Division (Locked) -->
        <label class="flex items-center space-x-3 p-3 bg-gray-100 rounded border cursor-not-allowed opacity-75">
          <input type="checkbox" checked disabled class="h-5 w-5 text-blue-600" />
          <span class="font-bold text-gray-700">Division</span>
        </label>
        
        <!-- Optional Criteria -->
        <label class="flex items-center space-x-3 p-3 hover:bg-gray-50 rounded border cursor-pointer transition" :class="criteria.useSex ? 'border-indigo-500 bg-indigo-50' : ''">
          <input type="checkbox" v-model="criteria.useSex" class="h-5 w-5 text-indigo-600" />
          <span class="font-medium text-gray-800">Sex (M/F)</span>
        </label>

        <label class="flex items-center space-x-3 p-3 hover:bg-gray-50 rounded border cursor-pointer transition" :class="criteria.useAge ? 'border-indigo-500 bg-indigo-50' : ''">
          <input type="checkbox" v-model="criteria.useAge" class="h-5 w-5 text-indigo-600" />
          <span class="font-medium text-gray-800">Age Groups</span>
        </label>

        <label class="flex items-center space-x-3 p-3 hover:bg-gray-50 rounded border cursor-pointer transition" :class="criteria.useRank ? 'border-indigo-500 bg-indigo-50' : ''">
          <input type="checkbox" v-model="criteria.useRank" class="h-5 w-5 text-indigo-600" />
          <span class="font-medium text-gray-800">Rank/Belt</span>
        </label>
      </div>

      <div class="flex justify-end">
        <button 
          @click="simulate" 
          :disabled="simulating"
          class="bg-indigo-600 text-white px-8 py-3 rounded-lg font-bold shadow hover:bg-indigo-700 transition disabled:opacity-50 flex items-center"
        >
          <span v-if="simulating" class="mr-2 animate-spin">⚙️</span>
          {{ simulating ? 'Calculating...' : 'Simulate Brackets' }}
        </button>
      </div>
    </div>

    <!-- STEP 3: Review Simulation -->
    <div v-if="simulationResults.length > 0" class="bg-white p-6 rounded-lg shadow mb-6 border-l-4 border-green-600">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-bold">3. Proposed Brackets ({{ simulationResults.length }})</h3>
        <button @click="commit" :disabled="committing" class="bg-green-600 text-white px-6 py-2 rounded font-bold hover:bg-green-700 shadow">
          {{ committing ? 'Creating...' : 'Confirm & Create All' }}
        </button>
      </div>

      <div class="space-y-3">
        <div v-for="(bracket, index) in simulationResults" :key="index" class="border p-4 rounded hover:bg-gray-50 flex justify-between items-center">
          <div>
            <div class="font-bold text-lg text-gray-900">{{ bracket.name }}</div>
            <div class="text-sm text-gray-500">
              Matches criteria: {{ formatMeta(bracket.meta) }}
            </div>
          </div>
          <div class="flex items-center space-x-4">
            <div class="text-right">
              <span class="block text-2xl font-bold" :class="bracket.participantCount < 2 ? 'text-red-500' : 'text-blue-600'">
                {{ bracket.participantCount }}
              </span>
              <span class="text-xs text-gray-400 uppercase">Athletes</span>
            </div>
            <!-- Show warning if too few people -->
            <span v-if="bracket.participantCount < 2" class="text-xs bg-red-100 text-red-600 px-2 py-1 rounded font-bold">
              ⚠ Low Count
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';

const tournaments = ref([]);
const selectedTournamentId = ref(null);

// Criteria State
const criteria = ref({
  useDivision: true, // Always true logic handled in backend
  useSex: false,
  useAge: false,
  useRank: false
});

// Simulation State
const simulating = ref(false);
const simulationResults = ref([]);
const committing = ref(false);

const loadTournaments = async () => {
  try {
    const res = await axios.get('/tournaments');
    tournaments.value = res.data;
    // Auto-select active if exists
    const active = res.data.find(t => t.is_active);
    if (active) selectedTournamentId.value = active.tournament_id;
  } catch (e) { console.error(e); }
};

const resetSimulation = () => {
  simulationResults.value = [];
};

const simulate = async () => {
  if (!selectedTournamentId.value) return alert("Select a tournament");
  
  simulating.value = true;
  try {
    const res = await axios.post('/brackets/simulate', {
      tournament_id: selectedTournamentId.value,
      criteria: criteria.value
    });
    simulationResults.value = res.data;
  } catch (e) {
    alert("Error simulating: " + (e.response?.data?.error || e.message));
  } finally {
    simulating.value = false;
  }
};

const commit = async () => {
  if (!confirm(`This will create ${simulationResults.value.length} bracket structures in the database. Continue?`)) return;
  
  committing.value = true;
  try {
    const res = await axios.post('/brackets/commit', {
      tournament_id: selectedTournamentId.value,
      brackets: simulationResults.value
    });
    alert(res.data.message);
    // Could redirect to a Bracket Viewer page here
    simulationResults.value = []; // Clear
  } catch (e) {
    alert("Error saving: " + e.message);
  } finally {
    committing.value = false;
  }
};

const formatMeta = (meta) => {
  // Helper to show what criteria created this bracket
  let parts = [];
  if (meta.sex) parts.push(meta.sex === 'M' ? 'Male' : 'Female');
  if (meta.age_group) parts.push(meta.age_group);
  if (meta.rank) parts.push(meta.rank);
  return parts.join(' • ') || 'Open Class';
};

onMounted(loadTournaments);
</script>