<template>
  <div class="container mx-auto p-4">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Roster & Bracket Management</h2>

    <!-- Context Selection -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 bg-white p-4 rounded shadow">
      <div>
        <label class="block text-sm font-bold text-gray-700 mb-1">Select Tournament</label>
        <select v-model="selectedTournamentId" @change="onTournamentChange" class="w-full border p-2 rounded">
          <option :value="null" disabled>Select Tournament</option>
          <option v-for="t in tournaments" :key="t.tournament_id" :value="t.tournament_id">
            {{ t.tournament_title }}
          </option>
        </select>
      </div>
      <div>
        <label class="block text-sm font-bold text-gray-700 mb-1">Select Division</label>
        <select v-model="selectedDivisionId" @change="fetchData" class="w-full border p-2 rounded" :disabled="!selectedTournamentId">
          <option :value="null" disabled>Select Division</option>
          <option v-for="d in divisions" :key="d.id" :value="d.id">
            {{ d.division_name }}
          </option>
        </select>
      </div>
    </div>

    <div v-if="selectedDivisionId">
      <!-- Actions Toolbar -->
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-xl font-bold">Existing Brackets</h3>
        <button 
          @click="showGenerateModal = true" 
          class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 shadow"
        >
          + Generate New Bracket
        </button>
      </div>

      <!-- Brackets List -->
      <div v-if="brackets.length === 0" class="text-gray-500 italic mb-8 bg-gray-50 p-4 rounded text-center">
        No brackets created for this division yet.
      </div>
      <div v-else class="grid gap-4 mb-8">
        <div v-for="b in brackets" :key="b.id" class="bg-white p-4 rounded shadow border-l-4 border-indigo-500 flex justify-between items-center">
          <div>
            <h4 class="font-bold text-lg text-gray-900">{{ b.name }}</h4>
            <span class="text-xs font-bold uppercase bg-gray-200 text-gray-600 px-2 py-1 rounded">{{ b.bracket_type.replace('_', ' ') }}</span>
          </div>
          <button class="text-blue-600 hover:underline font-medium">View/Edit</button>
        </div>
      </div>

      <!-- Participants List (Reference) -->
      <h3 class="text-xl font-bold mb-4">Registered Participants ({{ participants.length }})</h3>
      <div class="bg-white rounded shadow overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">School</th>
              <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Rank</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="p in participants" :key="p.id" class="hover:bg-gray-50">
              <td class="px-6 py-3 font-medium text-gray-900">{{ p.first_name }} {{ p.last_name }}</td>
              <td class="px-6 py-3 text-sm text-gray-600">{{ p.school_name }}</td>
              <td class="px-6 py-3 text-sm">{{ p.participant_rank }}</td>
            </tr>
            <tr v-if="participants.length === 0">
              <td colspan="3" class="px-6 py-8 text-center text-gray-500">No participants registered in this division for this tournament.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Generate Modal -->
    <div v-if="showGenerateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">Generate Bracket</h3>
        <form @submit.prevent="generate">
          <div class="mb-4">
            <label class="block text-sm font-bold mb-1">Bracket Name</label>
            <input v-model="newBracket.name" class="w-full border p-2 rounded" placeholder="e.g. Main Draw" required />
          </div>
          <div class="mb-6">
            <label class="block text-sm font-bold mb-1">Type</label>
            <select v-model="newBracket.bracket_type" class="w-full border p-2 rounded bg-white">
              <option value="single_elimination">Single Elimination</option>
              <option value="round_robin">Round Robin</option>
            </select>
          </div>
          <div class="flex justify-end space-x-2">
            <button type="button" @click="showGenerateModal = false" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
            <button type="submit" class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700 font-bold">Generate</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';

const tournaments = ref([]);
const divisions = ref([]);
const brackets = ref([]);
const participants = ref([]);

const selectedTournamentId = ref(null);
const selectedDivisionId = ref(null);
const showGenerateModal = ref(false);

const newBracket = ref({ name: 'Main Bracket', bracket_type: 'single_elimination' });

const loadTournaments = async () => {
  try {
    const res = await axios.get('/tournaments');
    tournaments.value = res.data;
    const active = res.data.find(t => t.is_active);
    if (active) {
      selectedTournamentId.value = active.tournament_id;
      onTournamentChange();
    }
  } catch (e) { console.error(e); }
};

const onTournamentChange = async () => {
  if (!selectedTournamentId.value) return;
  try {
    const res = await axios.get('/divisions', { params: { active_only: true } }); 
    divisions.value = res.data;
    selectedDivisionId.value = null;
    brackets.value = [];
    participants.value = [];
  } catch (e) { console.error(e); }
};

const fetchData = async () => {
  if (!selectedTournamentId.value || !selectedDivisionId.value) return;
  
  try {
    // 1. Get Brackets
    const bRes = await axios.get('/brackets', {
      params: { tournament_id: selectedTournamentId.value, division_id: selectedDivisionId.value }
    });
    brackets.value = bRes.data;

    // 2. Get Participants (Using new specific endpoint)
    const pRes = await axios.get('/brackets/participants', {
      params: { 
        tournament_id: selectedTournamentId.value,
        division_id: selectedDivisionId.value 
      }
    });
    
    participants.value = pRes.data;
  } catch (e) { console.error(e); }
};

const generate = async () => {
  try {
    await axios.post('/brackets/generate', {
      tournament_id: selectedTournamentId.value,
      division_id: selectedDivisionId.value,
      ...newBracket.value
    });
    alert("Bracket generated successfully!");
    showGenerateModal.value = false;
    fetchData();
  } catch (e) {
    alert("Error generating bracket: " + (e.response?.data?.error || e.message));
  }
};

onMounted(loadTournaments);
</script>