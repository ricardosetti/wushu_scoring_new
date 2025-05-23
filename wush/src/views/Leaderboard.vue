<template>
  <div class="min-h-screen bg-gray-100 flex justify-center items-center p-4">
    <div class="w-full max-w-5xl bg-white rounded-xl shadow-lg p-6">
      <!-- Loading State -->
      <div v-if="loading" class="text-center text-gray-500 text-xl">
        Loading leaderboard...
      </div>
      <!-- Error State -->
      <div v-else-if="error" class="text-center text-red-500 text-xl">
        {{ error }}
      </div>
      <!-- Main Content -->
      <div v-else>
        <!-- Active Division Header -->
        <div class="text-center mb-6">
          <h2 class="text-4xl sm:text-5xl font-bold text-primary">
            {{ activeDivision ? activeDivision.division_name : 'No Active Division' }}
          </h2>
          <p v-if="!activeDivision" class="text-lg text-gray-500 mt-2">
            Please select an active division from the Head Judge panel.
          </p>
        </div>

        <!-- Leaderboard -->
        <div v-if="activeDivision && rankedParticipants.length" class="space-y-4">
          <!-- Header Row -->
          <div class="flex flex-col sm:flex-row sm:items-center bg-gray-200 p-3 rounded-lg font-semibold text-gray-800">
            <div class="w-16 sm:w-24 text-center">Position</div>
            <div class="flex-1 sm:flex-[2] text-left sm:pl-4">Participant</div>
            <div class="flex-1 text-left sm:pl-4">School</div>
            <div class="w-24 sm:w-32 text-center">Score A</div>
            <div class="w-24 sm:w-32 text-center">Score B</div>
            <div class="w-24 sm:w-32 text-center">Final Score</div>
          </div>
          <!-- Participant Rows -->
          <div
            v-for="(participant, index) in rankedParticipants"
            :key="participant.id"
            :class="[
              'flex flex-col sm:flex-row sm:items-center p-3 rounded-lg transition',
              index === 0 ? 'bg-yellow-100 border-l-4 border-yellow-500' :
              index === 1 ? 'bg-gray-300 border-l-4 border-gray-500' :
              index === 2 ? 'bg-orange-100 border-l-4 border-orange-500' :
              'bg-gray-50 hover:bg-gray-100'
            ]"
          >
            <div class="w-16 sm:w-24 text-center text-lg font-bold text-primary">
              {{ index + 1 }}
            </div>
            <div class="flex-1 sm:flex-[2] text-left sm:pl-4 text-lg text-gray-800">
              {{ participant.fullName }}
            </div>
            <div class="flex-1 text-left sm:pl-4 text-gray-600">
              {{ participant.school_name || 'N/A' }}
            </div>
            <div class="w-24 sm:w-32 text-center text-gray-800">
              {{ participant.scores.FinalA || 'N/A' }}
            </div>
            <div class="w-24 sm:w-32 text-center text-gray-800">
              {{ participant.scores.FinalB || 'N/A' }}
            </div>
            <div class="w-24 sm:w-32 text-center text-lg font-semibold text-primary">
              {{ participant.scores.Final || 'N/A' }}
            </div>
          </div>
        </div>
        <div v-else-if="activeDivision" class="text-center text-gray-500 p-4">
          <p>No participants with published scores in this division.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject, computed } from "vue";
import axios from "../axios";

const socket = inject("socket");
const activeDivision = ref(null);
const participants = ref([]);
const loading = ref(true);
const error = ref('');

const rankedParticipants = computed(() => {
  if (!activeDivision.value) return [];
  const filtered = participants.value
    .filter((participant) =>
      participant.division_ids.includes(activeDivision.value.id)
    )
    .filter((participant) => {
      const finalScore = parseFloat(participant.scores?.Final);
      return finalScore > 0 && !isNaN(finalScore);
    })
    .map((participant) => ({
      ...participant,
      scores: participant.scores || {},
    }));
  return filtered.sort((a, b) => {
    const scoreA = parseFloat(a.scores.Final) || 0;
    const scoreB = parseFloat(b.scores.Final) || 0;
    return scoreB - scoreA;
  });
});

const fetchActiveDivision = async () => {
  try {
    const res = await axios.get("/divisions/active");
    activeDivision.value = res.data;
  } catch (err) {
    error.value = 'Failed to fetch active division: ' + (err.response?.data?.error || err.message);
    activeDivision.value = null;
  }
};

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
      participant.division_ids = participant.divisions?.map(d => d.id) || [];
      participant.scores = {};
      return participant;
    });
    await fetchParticipantScores();
  } catch (err) {
    error.value = 'Failed to fetch participants: ' + (err.response?.data?.error || err.message);
    participants.value = [];
  }
};

const fetchParticipantScores = async () => {
  if (!activeDivision.value) return;
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
      participant.scores = {};
      participant.deduction_codes = [];
    }
  });
  await Promise.all(scorePromises);
};

const refreshData = async () => {
  try {
    loading.value = true;
    error.value = '';
    await Promise.all([fetchActiveDivision(), fetchParticipants()]);
  } catch (err) {
    error.value = 'Failed to load leaderboard: ' + (err.response?.data?.error || err.message);
  } finally {
    loading.value = false;
  }
};

const pollingInterval = ref(null);
const startPolling = () => {
  pollingInterval.value = setInterval(() => {
    refreshData();
  }, 30000);
};

onMounted(() => {
  refreshData();
  startPolling();

  socket.on("activeDivisionUpdated", (data) => {
    activeDivision.value = data;
    fetchParticipants();
  });

  socket.on("scorePublished", (data) => {
    if (!data?.participantId || !data?.division_id || !data?.scores) return;
    if (data.division_id !== activeDivision.value?.id) return;
    const participant = participants.value.find((p) => p.id === data.participantId);
    if (participant) {
      participant.scores = data.scores.reduce((acc, { judge, score }) => {
        acc[judge] = score;
        return acc;
      }, {});
    }
  });

  socket.on("deductionUpdated", (data) => {
    if (!data?.participantId || !data?.division_id) return;
    if (data.division_id !== activeDivision.value?.id) return;
    const participant = participants.value.find((p) => p.id === data.participantId);
    if (participant) {
      participant.deduction_codes = data.deduction_codes || [];
      fetchParticipantScores();
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

<style>
.text-primary {
  color: #1e40af;
}
</style>