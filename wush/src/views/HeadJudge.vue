<template>
  <div class="p-6 max-w-2xl mx-auto bg-white rounded-xl shadow-lg space-y-6">
    <h2 class="text-3xl font-bold text-center text-primary">Head Judge Panel</h2>

    <!-- Loading State -->
    <div v-if="loading" class="text-center text-gray-500 text-xl">
      Loading Head Judge panel...
    </div>
    <!-- Error State -->
    <div v-else-if="error" class="text-center text-red-500 text-xl">
      {{ error }}
    </div>
    <!-- Main Content -->
    <div v-else>
      <!-- Active Division Label -->
      <div class="bg-gray-100 p-4 rounded-lg shadow-inner text-center">
        <h3 class="text-lg font-semibold text-gray-800">
          Active Division: <span class="text-primary">{{ activeDivision ? activeDivision.division_name : 'None' }}</span>
        </h3>
        <button
          @click="showStartDivisionModal = true"
          class="mt-2 bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition"
        >
          Start Division
        </button>
      </div>

      <!-- Start Division Modal -->
      <div
        v-if="showStartDivisionModal"
        class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50"
      >
        <div class="bg-white p-6 rounded-lg shadow-lg max-w-sm w-full">
          <h3 class="text-xl font-bold mb-4 text-gray-800">Select Division to Start</h3>
          <select
            v-model="selectedDivisionId"
            class="border p-2 w-full rounded-md focus:ring-2 focus:ring-blue-500 mb-4"
          >
            <option value="" disabled>Select a division</option>
            <option v-for="division in divisions" :key="division.id" :value="division.id">
              {{ division.division_name }}
            </option>
          </select>
          <div class="flex justify-end space-x-2">
            <button
              @click="startDivision"
              :disabled="!selectedDivisionId"
              class="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition disabled:bg-gray-400"
            >
              OK
            </button>
            <button
              @click="showStartDivisionModal = false"
              class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition"
            >
              Cancel
            </button>
          </div>
        </div>
      </div>

      <!-- Participants List -->
      <div v-if="activeDivision" class="bg-gray-50 p-4 rounded-lg shadow-inner">
        <div v-if="filteredParticipants.length">
          <div class="space-y-4">
            <div v-for="participant in filteredParticipants" :key="participant.id" class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-3 bg-white rounded-lg shadow hover:bg-gray-100 transition">
              <div class="flex-1 mb-2 sm:mb-0">
                <p class="text-lg font-semibold text-gray-800">
                  {{ participant.fullName }}
                </p>
                <p class="text-sm text-gray-600">
                  School: {{ participant.school_name || 'N/A' }}
                </p>
                <p class="text-sm text-gray-600">
                  Divisions: {{ participant.divisions.length ? participant.divisions.map(d => d.division_name).join(', ') : 'N/A' }}
                </p>
              </div>
              <div class="flex space-x-2">
                <label class="text-sm text-gray-700">Active</label>
                <input
                  type="radio"
                  name="activeParticipant"
                  :value="participant.id"
                  v-model="selectedActiveParticipant"
                  class="accent-accent"
                />
                <label class="text-sm text-gray-700">On Deck</label>
                <input
                  type="radio"
                  name="onDeckParticipant"
                  :value="participant.id"
                  v-model="selectedOnDeckParticipant"
                  class="accent-accent"
                />
              </div>
            </div>
          </div>
        </div>
        <div v-else class="text-center text-gray-500">
          <p>No participants registered for this division.</p>
        </div>
      </div>
      <div v-else class="bg-gray-50 p-4 rounded-lg shadow-inner text-center text-gray-500">
        <p>No Active Division</p>
      </div>

      <!-- Judge Controls -->
      <div class="space-y-6">
        <div class="flex justify-between items-center bg-gray-50 p-4 rounded-lg">
          <label class="text-lg font-semibold text-primary">Start Scoring (All):</label>
          <button
            @click="toggleAllJudges"
            :class="allJudgesOn ? 'bg-accent hover:bg-green-700' : 'bg-red-500 hover:bg-red-600'"
            class="text-white px-4 py-2 rounded-lg transition"
          >
            {{ allJudgesOn ? 'On' : 'Off' }}
          </button>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div v-for="judge in judges" :key="judge.id" class="flex justify-between items-center bg-gray-50 p-4 rounded-lg">
            <label class="text-lg font-semibold text-primary">{{ judge.name }}:</label>
            <button
              @click="toggleJudge(judge.id)"
              :class="judgeStates[judge.id] ? 'bg-accent hover:bg-green-700' : 'bg-red-500 hover:bg-red-600'"
              class="text-white px-4 py-2 rounded-lg transition"
            >
              {{ judgeStates[judge.id] ? 'On' : 'Off' }}
            </button>
          </div>
        </div>
      </div>

      <div class="flex space-x-4">
        <button @click="saveTournamentDetails" class="w-full bg-accent text-white p-3 rounded-lg hover:bg-green-700 transition">
          Save
        </button>
        <button @click="calculateFinalScore" class="w-full bg-blue-500 text-white p-3 rounded-lg hover:bg-blue-600 transition">
          Calculate Final Score
        </button>
        <button @click="publishScore" class="w-full bg-secondary text-white p-3 rounded-lg hover:bg-orange-600 transition">
          Publish Score
        </button>
      </div>

      <!-- Logout Button -->
      <button
        @click="logout"
        class="w-full bg-red-500 text-white p-3 rounded-lg hover:bg-red-600 transition"
      >
        Logout
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject, computed } from "vue";
import axios from "../axios";
import { useRouter } from 'vue-router';

const socket = inject("socket");
const router = useRouter();
const participants = ref([]);
const filteredParticipants = computed(() => {
  if (!activeDivision.value) return [];
  return participants.value.filter((participant) =>
    participant.divisions.some(d => d.division_name === activeDivision.value.division_name)
  );
});
const divisions = ref([]);
const activeDivision = ref(null);
const selectedActiveParticipant = ref(null);
const selectedOnDeckParticipant = ref(null);
const judgeStates = ref({
  Judge_A1: 0,
  Judge_A2: 0,
  Judge_B1: 0,
  Judge_B2: 0,
});
const judges = [
  { id: "Judge_A1", name: "Judge A1" },
  { id: "Judge_A2", name: "Judge A2" },
  { id: "Judge_B1", name: "Judge B1" },
  { id: "Judge_B2", name: "Judge B2" },
];
const allJudgesOn = ref(false);
const showStartDivisionModal = ref(false);
const selectedDivisionId = ref("");
const loading = ref(true);
const error = ref('');

const fetchParticipants = async () => {
  try {
    const res = await axios.get("/participants");
    participants.value = res.data.map((participant) => {
      participant.fullName = [
        participant.first_name || '',
        participant.middle_name || '',
        participant.last_name || ''
      ]
        .filter((part) => part)
        .join(" ");
      return participant;
    });
  } catch (err) {
    error.value = 'Failed to fetch participants: ' + (err.response?.data?.error || err.message);
    participants.value = [];
  }
};

const fetchDivisions = async () => {
  try {
    const res = await axios.get("/divisions");
    divisions.value = res.data;
  } catch (err) {
    error.value = 'Failed to fetch divisions: ' + (err.response?.data?.error || err.message);
    divisions.value = [];
  }
};

const fetchActiveDivision = async () => {
  try {
    const res = await axios.get("/divisions/active");
    activeDivision.value = res.data;
  } catch (err) {
    error.value = 'Failed to fetch active division: ' + (err.response?.data?.error || err.message);
    activeDivision.value = null;
  }
};

const startDivision = async () => {
  if (!selectedDivisionId.value) return;
  try {
    const res = await axios.post("/divisions/set-active", { division_id: selectedDivisionId.value });
    activeDivision.value = res.data;
    socket.emit("activeDivisionUpdated", res.data);
    showStartDivisionModal.value = false;
    selectedDivisionId.value = "";
    // Validate selected participants
    validateSelectedParticipants();
  } catch (err) {
    console.error("Error setting active division:", err.response?.data || err.message);
    alert("Error setting active division.");
  }
};

const fetchTournamentDetails = async () => {
  try {
    const res = await axios.get("/tournament-details");
    if (res.data) {
      selectedActiveParticipant.value = res.data.Active_ID || null;
      selectedOnDeckParticipant.value = res.data.OnDeck_ID || null;
      judgeStates.value.Judge_A1 = res.data.Judge_A1 || 0;
      judgeStates.value.Judge_A2 = res.data.Judge_A2 || 0;
      judgeStates.value.Judge_B1 = res.data.Judge_B1 || 0;
      judgeStates.value.Judge_B2 = res.data.Judge_B2 || 0;
      allJudgesOn.value = Object.values(judgeStates.value).every((state) => state === 1);
      // Validate selected participants
      validateSelectedParticipants();
    }
  } catch (err) {
    error.value = 'Failed to fetch tournament details: ' + (err.response?.data?.error || err.message);
  }
};

const validateSelectedParticipants = () => {
  if (!activeDivision.value) {
    selectedActiveParticipant.value = null;
    selectedOnDeckParticipant.value = null;
    return;
  }
  // Ensure selected participants belong to the active division
  if (selectedActiveParticipant.value) {
    const activeParticipant = participants.value.find(p => p.id === selectedActiveParticipant.value);
    if (!activeParticipant || !activeParticipant.divisions.some(d => d.division_name === activeDivision.value.division_name)) {
      selectedActiveParticipant.value = null;
    }
  }
  if (selectedOnDeckParticipant.value) {
    const onDeckParticipant = participants.value.find(p => p.id === selectedOnDeckParticipant.value);
    if (!onDeckParticipant || !onDeckParticipant.divisions.some(d => d.division_name === activeDivision.value.division_name)) {
      selectedOnDeckParticipant.value = null;
    }
  }
};

const toggleJudge = (judgeId) => {
  judgeStates.value[judgeId] = judgeStates.value[judgeId] ? 0 : 1;
};

const toggleAllJudges = () => {
  allJudgesOn.value = !allJudgesOn.value;
  judges.forEach((judge) => {
    judgeStates.value[judge.id] = allJudgesOn.value ? 1 : 0;
  });
};

const saveTournamentDetails = async () => {
  try {
    await axios.post("/tournament-details", {
      argument: "Active_ID",
      value: selectedActiveParticipant.value,
    });
    await axios.post("/tournament-details", {
      argument: "OnDeck_ID",
      value: selectedOnDeckParticipant.value,
    });
    for (const judge of judges) {
      await axios.post("/tournament-details", {
        argument: judge.id,
        value: judgeStates.value[judge.id],
      });
    }
    socket.emit("updateTournamentDetails", {
      Active_ID: selectedActiveParticipant.value,
      OnDeck_ID: selectedOnDeckParticipant.value,
      ...judgeStates.value,
    });
    alert("Tournament details saved successfully!");
    await fetchTournamentDetails();
  } catch (err) {
    console.error("Error saving tournament details:", err.response?.data || err.message);
    alert("Error saving tournament details.");
  }
};

const calculateFinalScore = async () => {
  if (!selectedActiveParticipant.value) {
    alert("No active participant selected!");
    return;
  }
  try {
    const res = await axios.get(`/scores/participant/${selectedActiveParticipant.value}`);
    console.log("Fetched scores:", res.data);
    const scores = res.data.reduce((acc, { judge, score }) => {
      acc[judge] = Number(score);
      return acc;
    }, {});

    const requiredJudges = ["A1", "A2", "B1", "B2"];
    const missingJudges = requiredJudges.filter((judge) => scores[judge] === undefined);
    if (missingJudges.length > 0) {
      alert(`Cannot calculate final score: Missing scores from ${missingJudges.join(", ")}.`);
      return;
    }

    const a1 = scores["A1"];
    const a2 = scores["A2"];
    const finalA = (a1 + a2) / 2;
    console.log(`A1: ${a1}, A2: ${a2}, FinalA: ${finalA}`);

    const b1 = scores["B1"];
    const b2 = scores["B2"];
    const finalB = (b1 + b2) / 2;
    console.log(`B1: ${b1}, B2: ${b2}, FinalB: ${finalB}`);

    const final = finalA + finalB;
    console.log(`Final: ${final}`);

    if (isNaN(finalA) || isNaN(finalB) || isNaN(final)) {
      alert("Cannot calculate final score: Invalid judge scores.");
      return;
    }

    await axios.post("/scores", {
      participant_id: selectedActiveParticipant.value,
      judge: "FinalA",
      score: finalA,
    });
    await axios.post("/scores", {
      participant_id: selectedActiveParticipant.value,
      judge: "FinalB",
      score: finalB,
    });
    await axios.post("/scores", {
      participant_id: selectedActiveParticipant.value,
      judge: "Final",
      score: final,
    });

    alert(`Final Score Calculated: FinalA = ${finalA}, FinalB = ${finalB}, Final = ${final}`);
  } catch (err) {
    console.error("Error calculating final score:", err.response?.data || err.message);
    alert("Error calculating final score. Check console for details.");
  }
};

const publishScore = async () => {
  if (!selectedActiveParticipant.value) {
    alert("No active participant selected!");
    return;
  }
  try {
    const res = await axios.get(`/scores/participant/${selectedActiveParticipant.value}`);
    const scores = res.data.reduce((acc, { judge, score }) => {
      acc[judge] = score;
      return acc;
    }, {});

    const requiredJudges = ["A1", "A2", "B1", "B2", "FinalA", "FinalB", "Final"];
    const missingJudges = requiredJudges.filter((judge) => scores[judge] === undefined);
    if (missingJudges.length > 0) {
      alert(`Cannot publish score: Missing scores from ${missingJudges.join(", ")}.`);
      return;
    }

    const publishData = requiredJudges.map((judge) => ({
      judge,
      score: scores[judge],
    }));

    await axios.post("/published-scores", {
      participant_id: selectedActiveParticipant.value,
      scores: publishData,
      division_id: activeDivision.value.id,
    });

    socket.emit("scorePublished", {
      participantId: selectedActiveParticipant.value,
      division_id: activeDivision.value.id,
      scores: publishData,
    });

    alert("Score published successfully!");
  } catch (err) {
    console.error("Error publishing score:", err.response?.data || err.message);
    alert("Error publishing score. Check console for details.");
  }
};

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/login');
};

// Fetch all data on mount
const fetchAllData = async () => {
  try {
    loading.value = true;
    error.value = '';
    await Promise.all([
      fetchParticipants(),
      fetchDivisions(),
      fetchActiveDivision(),
      fetchTournamentDetails(),
    ]);
  } catch (err) {
    error.value = 'Failed to load Head Judge panel: ' + (err.response?.data?.error || err.message);
  } finally {
    loading.value = false;
  }
};

// Polling fallback
const pollingInterval = ref(null);
const startPolling = () => {
  pollingInterval.value = setInterval(() => {
    fetchAllData();
  }, 30000); // Poll every 30 seconds
};

onMounted(() => {
  fetchAllData();
  startPolling();

  socket.on("judgeSubmitted", (data) => {
    const { judge } = data;
    judgeStates.value[judge] = 0;
    console.log(`${judge} submitted score, turned off`);
  });

  socket.on("tournamentDetailsUpdated", (data) => {
    selectedActiveParticipant.value = data.Active_ID || null;
    selectedOnDeckParticipant.value = data.OnDeck_ID || null;
    judgeStates.value.Judge_A1 = data.Judge_A1 || 0;
    judgeStates.value.Judge_A2 = data.Judge_A2 || 0;
    judgeStates.value.Judge_B1 = data.Judge_B1 || 0;
    judgeStates.value.Judge_B2 = data.Judge_B2 || 0;
    allJudgesOn.value = Object.values(judgeStates.value).every((state) => state === 1);
    validateSelectedParticipants();
  });

  socket.on("activeDivisionUpdated", (data) => {
    activeDivision.value = data;
    validateSelectedParticipants();
  });

  socket.on("scorePublished", (data) => {
    console.log("Score published:", data);
  });

  socket.on("deductionUpdated", (data) => {
    console.log("Deduction updated:", data);
  });
});

onUnmounted(() => {
  if (pollingInterval.value) {
    clearInterval(pollingInterval.value);
  }
  socket.off("judgeSubmitted");
  socket.off("tournamentDetailsUpdated");
  socket.off("activeDivisionUpdated");
  socket.off("scorePublished");
  socket.off("deductionUpdated");
});
</script>

<style>
.text-primary { color: #1E40AF; }
.bg-primary { background-color: #1E40AF; }
.text-secondary { color: #F97316; }
.bg-secondary { background-color: #F97316; }
.text-accent { color: #10B981; }
.bg-accent { background-color: #10B981; }
.bg-red-500 { background-color: #b9103a; }
</style>