<template>
  <div class="p-6 max-w-4xl mx-auto bg-white rounded-xl shadow-lg space-y-6">
    <div class="flex justify-between items-center border-b pb-4">
      <h2 class="text-3xl font-bold text-primary">Head Judge Panel</h2>
      <div v-if="tournamentTitle" class="text-sm text-gray-500 font-medium bg-gray-100 px-3 py-1 rounded-full">
        {{ tournamentTitle }}
      </div>
    </div>

    <!-- Loading / Error -->
    <div v-if="loading" class="text-center text-gray-500 text-xl py-10">Loading panel...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded text-center">{{ error }}</div>
    
    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- LEFT COLUMN: Division & Timer -->
      <div class="space-y-6">
        <!-- Active Division Control -->
        <div class="bg-blue-50 p-5 rounded-xl shadow-sm border border-blue-100">
          <h3 class="text-sm font-bold text-blue-800 uppercase tracking-wide mb-2">Current Division</h3>
          <div class="text-xl font-bold text-gray-900 mb-4">
            {{ activeDivision ? activeDivision.division_name : 'None Selected' }}
          </div>
          <button
            @click="showStartDivisionModal = true"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded shadow transition"
          >
            Change Division
          </button>
        </div>

        <!-- Timer -->
        <div class="bg-gray-900 p-5 rounded-xl shadow-md text-center text-white">
          <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wide mb-2">Performance Timer</h3>
          <div class="text-5xl font-mono font-bold mb-4 tracking-widest">{{ formattedTime }}</div>
          <div class="flex justify-center space-x-3">
            <button
              @click="toggleTimer"
              class="w-24 py-2 rounded font-bold transition shadow"
              :class="isTimerRunning ? 'bg-red-500 hover:bg-red-600' : 'bg-green-500 hover:bg-green-600'"
            >
              {{ isTimerRunning ? 'STOP' : 'START' }}
            </button>
            <button
              @click="resetTimer"
              class="w-24 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded font-bold transition shadow"
            >
              RESET
            </button>
          </div>
        </div>
      </div>

      <!-- MIDDLE COLUMN: Participants -->
      <div class="lg:col-span-2 space-y-6">
        
        <!-- Participant Selection List -->
        <div class="bg-white border border-gray-200 rounded-xl shadow-sm flex flex-col h-96">
          <div class="p-4 border-b bg-gray-50 flex justify-between items-center">
            <h3 class="font-bold text-gray-700">Participants Queue</h3>
            <span class="text-xs text-gray-500">{{ filteredParticipants.length }} registered</span>
          </div>
          
          <div class="flex-1 overflow-y-auto p-2 space-y-2">
            <div v-if="filteredParticipants.length === 0" class="text-center text-gray-400 py-10">
              <p>No participants found in this division.</p>
            </div>

            <div 
              v-for="p in filteredParticipants" 
              :key="p.id" 
              class="flex items-center justify-between p-3 rounded-lg border transition"
              :class="{
                'border-green-500 bg-green-50 ring-1 ring-green-500': selectedActiveParticipant === p.id,
                'border-yellow-400 bg-yellow-50': selectedOnDeckParticipant === p.id && selectedActiveParticipant !== p.id,
                'border-gray-200 hover:bg-gray-50': selectedActiveParticipant !== p.id && selectedOnDeckParticipant !== p.id
              }"
            >
              <div>
                <div class="font-bold text-gray-800">{{ p.fullName }}</div>
                <div class="text-xs text-gray-500">{{ p.school_name }}</div>
              </div>
              
              <div class="flex space-x-2">
                <button 
                  @click="setActive(p.id)"
                  class="px-3 py-1 text-xs font-bold rounded transition"
                  :class="selectedActiveParticipant === p.id ? 'bg-green-600 text-white shadow' : 'bg-gray-200 text-gray-600 hover:bg-green-200'"
                >
                  ON MAT
                </button>
                <button 
                  @click="setOnDeck(p.id)"
                  class="px-3 py-1 text-xs font-bold rounded transition"
                  :class="selectedOnDeckParticipant === p.id ? 'bg-yellow-500 text-white shadow' : 'bg-gray-200 text-gray-600 hover:bg-yellow-200'"
                >
                  ON DECK
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Judge Controls -->
        <div class="bg-gray-50 p-5 rounded-xl border border-gray-200">
          <div class="flex justify-between items-center mb-4 min-h-[32px]">
            <h3 class="font-bold text-gray-800">Scoring Control</h3>
            
            <!-- MASTER SWITCH -->
            <button 
              @click="toggleAllJudges"
              class="px-4 py-1 rounded-full text-xs font-bold transition shadow-sm"
              :class="isAnyJudgeOn ? 'bg-red-500 text-white hover:bg-red-600' : 'bg-green-600 text-white hover:bg-green-700'"
            >
              {{ isAnyJudgeOn ? 'CLOSE ALL' : 'OPEN ALL' }}
            </button>
          </div>

          <!-- Dynamic Judge Buttons (Auto-save on click) -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
            <button 
              v-for="judge in judges" 
              :key="judge.id"
              @click="toggleJudge(judge.id)"
              class="py-3 rounded-lg font-bold text-sm transition border shadow-sm flex flex-col items-center justify-center"
              :class="judgeStates[judge.id] ? 'bg-green-100 border-green-400 text-green-800' : 'bg-white border-gray-300 text-gray-400'"
            >
              <span>{{ judge.name }}</span>
              <span class="text-[10px] mt-1 uppercase">{{ judgeStates[judge.id] ? 'Scoring' : 'Locked' }}</span>
            </button>
          </div>

          <div class="grid grid-cols-1">
            <button 
              @click="publishScore" 
              class="w-full bg-orange-500 hover:bg-orange-600 text-white py-4 rounded-lg font-bold shadow transition flex items-center justify-center text-lg"
              :disabled="!selectedActiveParticipant"
              :class="{'opacity-50 cursor-not-allowed': !selectedActiveParticipant}"
            >
              <span class="mr-2">📢</span> Calculate & Publish Score
            </button>
          </div>
        </div>

      </div>
    </div>

    <!-- Modals -->
    <div v-if="showStartDivisionModal" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">Select Division</h3>
        <select v-model="selectedDivisionId" class="w-full border p-3 rounded-lg mb-6 bg-gray-50 focus:ring-2 focus:ring-blue-500">
          <option value="" disabled>Choose a division...</option>
          <option v-for="div in divisions" :key="div.id" :value="div.id">{{ div.division_name }}</option>
        </select>
        <div class="flex justify-end space-x-3">
          <button @click="showStartDivisionModal = false" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
          <button @click="startDivision" class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 shadow">Set Active</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject, computed } from "vue";
import axios from "../axios";
import { useRouter } from 'vue-router';

const socket = inject("socket");
const router = useRouter();

// State
const loading = ref(true);
const error = ref('');
const tournamentTitle = ref('');
const participants = ref([]);
const divisions = ref([]);
const activeDivision = ref(null);
const selectedActiveParticipant = ref(null);
const selectedOnDeckParticipant = ref(null);
const showStartDivisionModal = ref(false);
const selectedDivisionId = ref("");

// Judges
const judgeStates = ref({ Judge_A1: 0, Judge_A2: 0, Judge_B1: 0, Judge_B2: 0 });
const judges = [
  { id: "Judge_A1", name: "Judge A1" },
  { id: "Judge_A2", name: "Judge A2" },
  { id: "Judge_B1", name: "Judge B1" },
  { id: "Judge_B2", name: "Judge B2" },
];

const isAnyJudgeOn = computed(() => {
  return Object.values(judgeStates.value).some(status => status === 1);
});

// Timer
const elapsedTime = ref(0);
const isTimerRunning = ref(false);
let timerInterval = null;

// Computed
const formattedTime = computed(() => {
  const m = Math.floor(elapsedTime.value / 60).toString().padStart(2, '0');
  const s = (elapsedTime.value % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
});

const filteredParticipants = computed(() => {
  if (!activeDivision.value) return [];
  return participants.value.filter((p) =>
    p.divisions.some(d => d.id === activeDivision.value.id)
  );
});

// Data Fetching
const fetchAllData = async () => {
  try {
    loading.value = true;
    const [pRes, dRes, adRes, tdRes, tRes] = await Promise.all([
      axios.get("/participants"), 
      axios.get("/divisions", { params: { active_only: true } }), 
      axios.get("/divisions/active"),
      axios.get("/tournament-details"),
      axios.get("/tournaments")
    ]);

    participants.value = pRes.data.map(p => ({
      ...p,
      fullName: `${p.first_name} ${p.last_name}`
    }));
    
    divisions.value = dRes.data;
    activeDivision.value = adRes.data;
    
    // Parse Details
    if (tdRes.data) {
      selectedActiveParticipant.value = tdRes.data.Active_ID || null;
      selectedOnDeckParticipant.value = tdRes.data.OnDeck_ID || null;
      judgeStates.value.Judge_A1 = tdRes.data.Judge_A1 || 0;
      judgeStates.value.Judge_A2 = tdRes.data.Judge_A2 || 0;
      judgeStates.value.Judge_B1 = tdRes.data.Judge_B1 || 0;
      judgeStates.value.Judge_B2 = tdRes.data.Judge_B2 || 0;
    }

    const activeT = tRes.data.find(t => t.is_active);
    tournamentTitle.value = activeT ? activeT.tournament_title : '';

  } catch (err) {
    console.error(err);
    error.value = "Failed to load system data.";
  } finally {
    loading.value = false;
  }
};

// Actions (Dynamic Saving)
const setActive = async (id) => { 
  selectedActiveParticipant.value = id;
  await saveTournamentDetails(); 
};

const setOnDeck = async (id) => { 
  selectedOnDeckParticipant.value = id;
  await saveTournamentDetails(); 
};

const startDivision = async () => {
  if (!selectedDivisionId.value) return;
  try {
    const res = await axios.post("/divisions/set-active", { division_id: selectedDivisionId.value });
    activeDivision.value = res.data;
    selectedActiveParticipant.value = null; 
    selectedOnDeckParticipant.value = null;
    showStartDivisionModal.value = false;
    
    socket.emit("activeDivisionUpdated", res.data);
    await saveTournamentDetails(); 
  } catch (e) { alert("Error changing division"); }
};

const toggleJudge = async (id) => {
  judgeStates.value[id] = judgeStates.value[id] ? 0 : 1;
  await saveTournamentDetails();
};

const toggleAllJudges = async () => {
  // If ANY are ON, turn all OFF. Otherwise turn all ON.
  const targetState = isAnyJudgeOn.value ? 0 : 1;
  judges.forEach(j => judgeStates.value[j.id] = targetState);
  await saveTournamentDetails();
};

const closeAllJudges = async () => {
  judges.forEach(j => judgeStates.value[j.id] = 0);
  await saveTournamentDetails();
};

// Auto-Save Function
const saveTournamentDetails = async () => {
  try {
    const requests = [
      axios.post("/tournament-details", { argument: "Active_ID", value: selectedActiveParticipant.value || 0 }),
      axios.post("/tournament-details", { argument: "OnDeck_ID", value: selectedOnDeckParticipant.value || 0 }),
      ...judges.map(j => axios.post("/tournament-details", { argument: j.id, value: judgeStates.value[j.id] }))
    ];
    
    await Promise.all(requests);
    
    socket.emit("updateTournamentDetails", {
      Active_ID: selectedActiveParticipant.value,
      OnDeck_ID: selectedOnDeckParticipant.value,
      ...judgeStates.value
    });
  } catch (e) {
    console.error("Save failed", e);
  }
};

const publishScore = async () => {
  if (!selectedActiveParticipant.value) return;
  if(!confirm("Calculate and Publish scores for this athlete?")) return;

  try {
    await axios.post("/published-scores", {
      participant_id: selectedActiveParticipant.value,
      division_id: activeDivision.value.id,
    });
    alert("Score Published!");
    await closeAllJudges(); // Lock panel
  } catch (e) {
    alert("Failed to publish score: " + (e.response?.data?.error || e.message));
  }
};

// Timer logic
const toggleTimer = () => {
  if (isTimerRunning.value) {
    clearInterval(timerInterval);
    isTimerRunning.value = false;
  } else {
    timerInterval = setInterval(() => elapsedTime.value++, 1000);
    isTimerRunning.value = true;
  }
};
const resetTimer = () => {
  clearInterval(timerInterval);
  isTimerRunning.value = false;
  elapsedTime.value = 0;
};

// Lifecycle
onMounted(() => {
  fetchAllData();
  
  socket.on("judgeSubmitted", (data) => {
    judgeStates.value[data.judge] = 0;
  });

  socket.on("tournamentDetailsUpdated", (data) => {
    // Only update if data changed externally (simple sync)
    selectedActiveParticipant.value = data.Active_ID || null;
    selectedOnDeckParticipant.value = data.OnDeck_ID || null;
    judgeStates.value.Judge_A1 = data.Judge_A1 || 0;
    judgeStates.value.Judge_A2 = data.Judge_A2 || 0;
    judgeStates.value.Judge_B1 = data.Judge_B1 || 0;
    judgeStates.value.Judge_B2 = data.Judge_B2 || 0;
  });
});

onUnmounted(() => {
  clearInterval(timerInterval);
  socket.off("judgeSubmitted");
  socket.off("tournamentDetailsUpdated");
});
</script>