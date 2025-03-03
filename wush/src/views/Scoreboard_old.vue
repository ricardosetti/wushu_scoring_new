<template>
 <div class="min-h-screen bg-gray-700 text-black items-baseline p-4 w-full h-full max-w-none">
  <div class="w-full max-w-4xl text-center">
      <div class="mb-0 flex justify-center items-center space-x-4">
        <p class="text-4xl font-bold text-red-500 leading-none"> {{ activeParticipant?.id || 'N/A' }}</p>
        <p class="text-4xl !important font-bold !important text-red !important !important leading-none !important !important"> {{ activeParticipant?.name || 'No Participant' }}</p>
      </div>
      
      <p class="text-lg !important mb-4 !important text-white !important">School: {{ activeParticipant?.school || 'N/A' }}</p>

      <div class="bg-darkgray-dark !important p-4 !important mb-4 !important rounded-lg !important">
        <h3 class="text-lg !important font-bold !important text-blue !important mb-2 !important">Group A</h3>
        <p class="text-base !important text-white !important"><strong>Judge A1:</strong> {{ scores.A1 || 'N/A' }}</p>
        <p class="text-base !important text-white !important"><strong>Judge A2:</strong> {{ scores.A2 || 'N/A' }}</p>
        <p class="text-base !important font-semibold !important text-white !important"><strong>Final A:</strong> {{ scores.FinalA || 'N/A' }}</p>
        <p v-if="deductionCodes.length" class="text-base !important text-white !important mt-2 !important"><strong>Deductions:</strong> {{ deductionCodes.join(', ') }}</p>
      </div>

      <div class="bg-darkgray-dark !important p-4 !important mb-4 !important rounded-lg !important">
        <h3 class="text-lg !important font-bold !important text-blue !important mb-2 !important">Group B</h3>
        <p class="text-base !important text-white !important"><strong>Judge B1:</strong> {{ scores.B1 || 'N/A' }}</p>
        <p class="text-base !important text-white !important"><strong>Judge B2:</strong> {{ scores.B2 || 'N/A' }}</p>
        <p class="text-base !important font-semibold !important text-white !important"><strong>Final B:</strong> {{ scores.FinalB || 'N/A' }}</p>
      </div>

      <p class="text-sm !important text-white !important mb-4 !important">Current Placing: N/A</p>
      <p class="text-4xl !important font-bold !important text-red !important !important leading-none !important !important">Final Score: {{ scores.Final || 'N/A' }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const activeParticipant = ref(null);
const scores = ref({});
const deductionCodes = ref([]);

const fetchScoreboardData = async () => {
  try {
    const res = await axios.get("http://localhost:5000/tournament-details");
    const activeId = res.data.Active_ID;
    if (!activeId) {
      activeParticipant.value = null;
      scores.value = {};
      deductionCodes.value = [];
      return;
    }

    const participantRes = await axios.get(`http://localhost:5000/participants/${activeId}`);
    activeParticipant.value = participantRes.data;

    const scoresRes = await axios.get(`http://localhost:5000/published-scores/participant/${activeId}`);
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
  fetchScoreboardData();
});
</script>

<style>
body {
  font-family: Arial, sans-serif !important;
  background: #374151 !important;
  margin: 0 !important;
  padding: 0 !important;
  min-height: 100vh !important;
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
  width: 100% !important;
  max-width: none !important;
}
#app {
  background: none !important;
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
  height: 100% !important;
  max-width: none !important;
}
.bg-darkgray { background-color: #374151 !important; }
.bg-darkgray-dark { background-color: #4A5568 !important; }
.text-red { color: #EF4444 !important; }
.text-blue { color: #1E3A8A !important; }
.text-white { color: #FFFFFF !important; }
.flex { display: flex !important; }
.items-center { align-items: center !important; }
.justify-center { justify-content: center !important; }
.w-full { width: 100% !important; max-width: none !important; }
.max-w-4xl { max-width: 1024px !important; }
.text-4xl { font-size: 2.25rem !important; line-height: 2.5rem !important; font-family: Arial, sans-serif !important; } /* Explicitly define text-4xl with font */
</style>