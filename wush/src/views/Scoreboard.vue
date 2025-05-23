<template>
  <div class="min-h-screen bg-gray-700 text-white flex justify-center items-center p-4">
    <div class="w-full max-w-4xl text-center">
      <!-- Loading State -->
      <div v-if="loading" class="text-center text-gray-400 text-xl">
        Loading scoreboard...
      </div>
      <!-- Error State -->
      <div v-else-if="error" class="text-center text-red-400 text-xl">
        {{ error }}
      </div>
      <!-- Main Content -->
      <div v-else>
        <!-- Participant Info Section -->
        <div class="bg-gray-700 py-2">
          <!-- Display Active Division -->
          <div class="division text-2xl sm:text-3xl text-white mb-2">
            Division: {{ activeDivision?.division_name || 'No Active Division' }}
          </div>
          <!-- Participant Name -->
          <div class="participant-name text-4xl sm:text-5xl font-bold text-yellow-300 mb-2">
            {{ activeParticipant?.fullName || 'No Active Participant' }}
          </div>
          <!-- School -->
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
                    class="deduction-circle flex items-center justify-center w-16 h-16 sm:w-20 sm:h-20 border-4 border-red-600 rounded-full text-xl sm:text-2xl text-white bg-red-800/50"
                  >
                    {{ code }}
                  </span>
                  <span v-if="!deductionCodes.length" class="text-lg sm:text-xl text-white">
                    No Deductions
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
        <p class="placing text-lg sm:text-xl text-white mt-4">
          Current Placing: {{ currentPlacing !== null ? `#${currentPlacing}` : 'N/A' }}
        </p>
        <p class="final-score text-5xl sm:text-6xl font-bold text-red-500 mt-2 bg-gray-800 py-2 rounded-lg">
          Final Score: {{ scores.Final || 'N/A' }}
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject } from "vue";
import axios from "../axios";

const socket = inject("socket");
const activeParticipant = ref(null);
const activeDivision = ref(null);
const participants = ref([]);
const scores = ref({});
const deductionCodes = ref([]);
const currentPlacing = ref(null);
const loading = ref(true);
const error = ref('');

const fetchScoreboardData = async () => {
  try {
    loading.value = true;
    error.value = '';

    const [divisionRes, tournamentRes] = await Promise.all([
      axios.get("/divisions/active").catch(() => ({ data: null })),
      axios.get("/tournament-details").catch(() => ({ data: { Active_ID: null } })),
    ]);

    activeDivision.value = divisionRes.data;
    const activeId = tournamentRes.data.Active_ID;

    if (!activeId || !activeDivision.value) {
      activeParticipant.value = null;
      participants.value = [];
      scores.value = {};
      deductionCodes.value = [];
      currentPlacing.value = null;
      return;
    }

    const [participantRes, participantsRes] = await Promise.all([
      axios.get(`/participants/${activeId}`).catch(() => ({ data: null })),
      axios.get("/participants").catch(() => ({ data: [] })),
    ]);

    if (!participantRes.data) {
      throw new Error("Failed to fetch participant details");
    }
    activeParticipant.value = participantRes.data;
    activeParticipant.value.fullName = [
      activeParticipant.value.first_name || '',
      activeParticipant.value.middle_name || '',
      activeParticipant.value.last_name || ''
    ]
      .filter(part => part)
      .join(" ");

    let scoresData = { scores: [], deduction_codes: [] };
    try {
      const scoresRes = await axios.get(`/published-scores/participant/${activeId}`, {
        params: { division_id: activeDivision.value.id }
      });
      scoresData = scoresRes.data;
    } catch (err) {
      console.error(`Failed to fetch scores for participant ${activeId} in division ${activeDivision.value.id}:`, err.response?.data || err.message);
    }
    scores.value = scoresData.scores?.reduce((acc, { judge, score }) => {
      acc[judge] = score;
      return acc;
    }, {}) || {};
    deductionCodes.value = scoresData.deduction_codes || [];

    participants.value = participantsRes.data.map((participant) => {
      participant.fullName = [
        participant.first_name || '',
        participant.middle_name || '',
        participant.last_name || ''
      ]
        .filter(part => part)
        .join(" ");
      participant.division_ids = participant.divisions?.map(d => d.id) || [];
      participant.scores = {};
      return participant;
    });

    const scorePromises = participants.value.map(async (participant) => {
      try {
        const res = await axios.get(`/published-scores/participant/${participant.id}`, {
          params: { division_id: activeDivision.value.id }
        });
        participant.scores = res.data.scores?.reduce((acc, { judge, score }) => {
          acc[judge] = score;
          return acc;
        }, {}) || {};
        participant.deduction_codes = res.data.deduction_codes || [];
      } catch (err) {
        console.error(`Failed to fetch scores for participant ${participant.id} in division ${activeDivision.value.id}:`, err.response?.data || err.message);
        participant.scores = {};
        participant.deduction_codes = [];
      }
    });
    await Promise.all(scorePromises);

    const ranked = participants.value
      .filter((participant) =>
        participant.division_ids.includes(activeDivision.value.id)
      )
      .filter((participant) => {
        const finalScore = parseFloat(participant.scores?.Final);
        return finalScore > 0 && !isNaN(finalScore);
      })
      .sort((a, b) => {
        const scoreA = parseFloat(a.scores.Final) || 0;
        const scoreB = parseFloat(b.scores.Final) || 0;
        return scoreB - scoreA;
      });

    const participantIndex = ranked.findIndex(p => p.id === activeId);
    currentPlacing.value = participantIndex >= 0 ? participantIndex + 1 : null;
  } catch (err) {
    error.value = 'Failed to load scoreboard data. Please try again later.';
    console.error("Error in fetchScoreboardData:", err.response?.data || err.message);
    activeParticipant.value = null;
    participants.value = [];
    scores.value = {};
    deductionCodes.value = [];
    currentPlacing.value = null;
  } finally {
    loading.value = false;
  }
};

const pollingInterval = ref(null);
const startPolling = () => {
  pollingInterval.value = setInterval(() => {
    fetchScoreboardData();
  }, 30000);
};

onMounted(() => {
  fetchScoreboardData();
  startPolling();

  socket.on("activeDivisionUpdated", (data) => {
    activeDivision.value = data;
    fetchScoreboardData();
  });

  socket.on("scorePublished", (data) => {
    if (!data?.participantId || !data?.division_id || !data?.scores) return;
    if (data.participantId === activeParticipant.value?.id && data.division_id === activeDivision.value?.id) {
      scores.value = data.scores.reduce((acc, { judge, score }) => {
        acc[judge] = score;
        return acc;
      }, {});
      fetchScoreboardData();
    } else if (data.division_id === activeDivision.value?.id) {
      const participant = participants.value.find((p) => p.id === data.participantId);
      if (participant) {
        participant.scores = data.scores.reduce((acc, { judge, score }) => {
          acc[judge] = score;
          return acc;
        }, {});
        const ranked = participants.value
          .filter((p) => p.division_ids.includes(activeDivision.value.id))
          .filter((p) => {
            const finalScore = parseFloat(p.scores?.Final);
            return finalScore > 0 && !isNaN(finalScore);
          })
          .sort((a, b) => {
            const scoreA = parseFloat(a.scores.Final) || 0;
            const scoreB = parseFloat(b.scores.Final) || 0;
            return scoreB - scoreA;
          });
        const participantIndex = ranked.findIndex(p => p.id === activeParticipant.value?.id);
        currentPlacing.value = participantIndex >= 0 ? participantIndex + 1 : null;
      }
    }
  });

  socket.on("deductionUpdated", (data) => {
    if (!data?.participantId || !data?.division_id) return;
    if (data.participantId === activeParticipant.value?.id && data.division_id === activeDivision.value?.id) {
      deductionCodes.value = data.deduction_codes || [];
      fetchScoreboardData();
    } else if (data.division_id === activeDivision.value?.id) {
      const participant = participants.value.find((p) => p.id === data.participantId);
      if (participant) {
        participant.deduction_codes = data.deduction_codes || [];
        fetchScoreboardData();
      }
    }
  });
});

onUnmounted(() => {
  if (pollingInterval.value) {
    clearInterval(pollingInterval.value);
  }
  socket.off("activeDivisionUpdated");
  socket.off("scorePublished");
  socket.off("deductionUpdated");
});
</script>

<style scoped>
.deduction-circle {
  transition: all 0.3s ease;
}
.deduction-circle:hover {
  transform: scale(1.1);
  background-color: rgba(239, 68, 68, 0.8);
}
.final-score {
  box-shadow: 0 0 15px rgba(239, 68, 68, 0.5);
}
</style>