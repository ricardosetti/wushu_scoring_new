<template>
  <div class="min-h-screen bg-gray-700 text-white flex justify-center items-center p-4">
    <div class="w-full max-w-4xl text-center">
      <!-- Participant Info Section -->
      <div class="bg-gray-700 py-2">
        <div class="participant-name text-4xl sm:text-5xl font-bold text-yellow-300 mb-2">
          {{ activeParticipant?.fullName || 'No Participant' }}
        </div>
        <div class="division text-2xl sm:text-3xl text-white mb-2">
          Division: {{ activeParticipant?.divisions.length ? activeParticipant.divisions.join(', ') : 'N/A' }}
        </div>
        <div class="school text-2xl sm:text-3xl text-white mb-2">
          School: {{ activeParticipant?.school_name || 'N/A' }}
        </div>
      </div>
      <hr class="border-red-600 my-4">

      <!-- Score Groups Section -->
      <div class="space-y-4">
        <!-- Group A -->
        <div class="group-box bg-gray-600 p-4 rounded-lg shadow">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start">
            <!-- Group A Scores -->
            <div class="flex-1 mb-4 sm:mb-0">
              <h3 class="group-title text-2xl sm:text-3xl font-bold text-yellow-300 mb-2">Group A</h3>
              <p class="text-lg sm:text-xl text-white mb-1"><strong>Judge A1:</strong> {{ scores.A1 || 'N/A' }}</p>
              <p class="text-lg sm:text-xl text-white mb-1"><strong>Judge A2:</strong> {{ scores.A2 || 'N/A' }}</p>
              <p class="text-lg sm:text-xl text-white mb-1"><strong>Final A:</strong> {{ scores.FinalA || 'N/A' }}</p>
            </div>
            <!-- Deductions -->
            <div class="flex-1">
              <h3 class="group-title text-2xl sm:text-3xl font-bold text-yellow-300 mb-2">Deductions</h3>
              <div class="flex justify-center gap-2 flex-wrap">
                <span
                  v-for="code in deductionCodes"
                  :key="code"
                  class="deduction-circle flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 border-4 border-red-600 rounded-full text-2xl sm:text-3xl text-white"
                >
                  {{ code }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Group B -->
        <div class="group-box bg-gray-600 p-4 rounded-lg shadow">
          <h3 class="group-title text-2xl sm:text-3xl font-bold text-yellow-300 mb-2">Group B</h3>
          <p class="text-lg sm:text-xl text-white mb-1"><strong>Judge B1:</strong> {{ scores.B1 || 'N/A' }}</p>
          <p class="text-lg sm:text-xl text-white mb-1"><strong>Judge B2:</strong> {{ scores.B2 || 'N/A' }}</p>
          <p class="text-lg sm:text-xl text-white mb-1"><strong>Final B:</strong> {{ scores.FinalB || 'N/A' }}</p>
        </div>
      </div>

      <!-- Final Score and Placing -->
      <p class="placing text-sm sm:text-base text-white mt-4">Current Placing: N/A</p>
      <p class="final-score text-4xl sm:text-5xl font-bold text-red-500 mt-2">
        Final Score: {{ scores.Final || 'N/A' }}
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from "vue";
import axios from "axios";

const socket = inject("socket");
const activeParticipant = ref(null);
const activeDivision = ref(null);
const scores = ref({});
const deductionCodes = ref([]);

const fetchActiveDivision = async () => {
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/divisions/active`
    );
    activeDivision.value = res.data;
  } catch (err) {
    console.error("Error fetching active division:", err);
    activeDivision.value = null;
  }
};

const fetchScoreboardData = async () => {
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`
    );
    const activeId = res.data.Active_ID;
    if (!activeId || !activeDivision.value) {
      activeParticipant.value = null;
      scores.value = {};
      deductionCodes.value = [];
      return;
    }

    const participantRes = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${activeId}`
    );
    activeParticipant.value = participantRes.data;
    activeParticipant.value.fullName = [activeParticipant.value.first_name, activeParticipant.value.middle_name, activeParticipant.value.last_name]
      .filter((part) => part)
      .join(" ");

    const scoresRes = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/published-scores/participant/${activeId}`
    );
    scores.value = scoresRes.data.scores.reduce((acc, { judge, score }) => {
      acc[judge] = score;
      return acc;
    }, {});
    deductionCodes.value = scoresRes.data.deduction_codes || [];
  } catch (err) {
    console.error("Error fetching scoreboard data:", err);
    activeParticipant.value = null;
    scores.value = {};
    deductionCodes.value = [];
  }
};

onMounted(() => {
  fetchActiveDivision();
  fetchScoreboardData();

  socket.on("activeDivisionUpdated", (data) => {
    activeDivision.value = data;
    fetchScoreboardData();
  });

  socket.on("scorePublished", (data) => {
    console.log("Score published:", data);
    if (data.participantId === activeParticipant.value?.id && data.division_id === activeDivision.value?.id) {
      fetchScoreboardData();
    }
  });

  socket.on("tournamentDetailsUpdated", (data) => {
    if (data.Active_ID) {
      fetchScoreboardData();
    }
  });
});
</script>