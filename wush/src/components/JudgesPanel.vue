<template>
  <div class="p-6 max-w-lg mx-auto bg-white rounded-xl shadow-lg space-y-6">
    <h2 class="text-3xl font-bold text-center text-primary">{{ judgeTitle }}</h2>
    
    <div v-if="activeParticipant && isJudgeEnabled" class="bg-gray-50 p-4 rounded-lg">
      <h3 class="text-xl font-semibold text-primary">Participant</h3>
      <p><strong>Name:</strong> {{ activeParticipant.fullName || 'N/A' }}</p>
      <p><strong>School:</strong> {{ activeParticipant.school_name || 'N/A' }}</p>
      <p><strong>Divisions:</strong> {{ activeParticipant.divisions.length ? activeParticipant.divisions.join(', ') : 'N/A' }}</p>
    </div>
    <div v-else-if="!isJudgeEnabled" class="text-center bg-red-100 p-4 rounded-lg">
      <h3 class="text-xl font-semibold text-red-500">Judge Disabled - Waiting for Head Judge</h3>
    </div>
    <div v-else class="text-center bg-gray-100 p-4 rounded-lg">
      <h3 class="text-xl font-semibold text-gray-600">No Active Participant</h3>
    </div>
    
    <input type="hidden" v-model="selectedActiveParticipant" />
    
    <!-- Judges A1 & A2: Deduction System -->
    <div v-if="judgeTitle === 'Judge A1' || judgeTitle === 'Judge A2'" class="space-y-4">
      <h3 class="text-lg font-semibold text-primary">Performance Score</h3>
      <div class="w-full border rounded-lg p-3 text-center bg-gray-100 text-xl">{{ score }}</div>
      
      <h3 class="text-lg font-semibold text-primary">Enter Deduction Code</h3>
      <input 
        type="number" 
        v-model="deductionCode" 
        min="1" 
        max="1000" 
        class="w-full border rounded-lg p-3 focus:ring-2 focus:ring-accent focus:outline-none disabled:bg-gray-200 disabled:text-gray-500" 
        :disabled="!isJudgeEnabled"
        placeholder="Enter code (1-1000)"
      />
      <button 
        @click="applyDeduction" 
        class="w-full bg-red-500 text-white p-3 rounded-lg hover:bg-red-600 transition disabled:bg-gray-400 disabled:cursor-not-allowed"
        :disabled="!isJudgeEnabled"
      >
        Deduct
      </button>

      <h3 class="text-lg font-semibold text-primary mt-4">Deductions Applied ({{ judgeTitle }})</h3>
      <table class="w-full border-collapse bg-gray-50 rounded-lg shadow-inner">
        <thead>
          <tr class="bg-primary text-white">
            <th class="p-3">Code</th>
            <th class="p-3">Category</th>
            <th class="p-3">Criteria</th>
            <th class="p-3">Description</th>
            <th class="p-3">Value</th>
            <th class="p-3">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(deduction, index) in tempDeductions" :key="deduction.participant_deduction_id || deduction.deduction_id" class="hover:bg-gray-100">
            <td class="border p-3">{{ deduction.deduction_code }}</td>
            <td class="border p-3">{{ deduction.deduction_category }}</td>
            <td class="border p-3">{{ deduction.deduction_criteria }}</td>
            <td class="border p-3">{{ deduction.deduction_description }}</td>
            <td class="border p-3 text-center">{{ deduction.deduction_value }}</td>
            <td class="border p-3 text-center">
              <button 
                @click="removeDeduction(index)" 
                class="bg-red-500 text-white p-2 rounded-lg hover:bg-red-600 transition disabled:bg-gray-400 disabled:cursor-not-allowed"
                :disabled="!isJudgeEnabled"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Judges B1 & B2: Performance Scoring (Slider) -->
    <div v-if="judgeTitle === 'Judge B1' || judgeTitle === 'Judge B2'" class="space-y-4">
      <h3 class="text-lg font-semibold text-primary">Performance Score</h3>
      <input 
        type="range" 
        v-model="score" 
        min="0" 
        max="5" 
        step="0.1" 
        class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer disabled:bg-gray-400 disabled:cursor-not-allowed"
        :disabled="!isJudgeEnabled"
      />
      <p class="text-center text-lg">Score: {{ score }}</p>
    </div>
    
    <button 
      v-if="judgeTitle.startsWith('Judge')" 
      @click="submitScore" 
      class="w-full bg-blue-500 text-white p-3 rounded-lg hover:bg-blue-600 transition disabled:bg-gray-400 disabled:cursor-not-allowed"
      :disabled="!isJudgeEnabled"
    >
      Submit Score
    </button>
  </div>
</template>

<script setup>
import { ref, defineProps, onMounted, inject } from 'vue';
import axios from 'axios';

const socket = inject("socket");
const props = defineProps({
  judgeTitle: String,
});

const selectedActiveParticipant = ref(null);
const activeParticipant = ref(null);
const activeDivision = ref(null); // Add active division
const score = ref(5.0);
const deductionCode = ref(null);
const tempDeductions = ref([]);
const removedDeductions = ref([]);
const isJudgeEnabled = ref(false);

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

const fetchActiveParticipant = async () => {
  const res = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`);
  if (res.data) {
    selectedActiveParticipant.value = res.data.Active_ID || null;
    isJudgeEnabled.value = res.data[props.judgeTitle.replace(" ", "_")] === 1;
    if (selectedActiveParticipant.value) {
      const participantRes = await axios.get(
        `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${selectedActiveParticipant.value}`
      );
      const participant = participantRes.data;
      // Compute full name
      participant.fullName = [participant.first_name, participant.middle_name, participant.last_name]
        .filter(part => part)
        .join(' ');
      activeParticipant.value = participant;
    } else {
      activeParticipant.value = null;
    }
  }
};

const fetchLatestScore = async () => {
  if (!selectedActiveParticipant.value || !isJudgeEnabled.value) return;
  console.log(`Fetching latest score for ${props.judgeTitle}`);
  try {
    const judgeIdentifier = props.judgeTitle.replace("Judge ", "");
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores/latest?participant_id=${selectedActiveParticipant.value}&judge=${judgeIdentifier}`
    );
    console.log("Latest score:", res.data);
    if (res.data && res.data.score !== undefined) {
      score.value = res.data.score;
    }
  } catch (err) {
    console.error("Error fetching latest score:", err);
  }
};

const fetchDeductions = async () => {
  if (!selectedActiveParticipant.value || !isJudgeEnabled.value || !activeDivision.value) return;
  console.log(`Fetching deductions for ${props.judgeTitle}`);
  try {
    const judgeIdentifier = props.judgeTitle.replace("Judge ", "");
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participant-deductions/${selectedActiveParticipant.value}/${judgeIdentifier}/${activeDivision.value.id}`
    );
    console.log("Deductions:", res.data);
    tempDeductions.value = res.data.map(deduction => ({
      ...deduction,
      participant_deduction_id: deduction.participant_deduction_id,
      deduction_id: deduction.deduction_id,
    }));
  } catch (err) {
    console.error("Error fetching deductions:", err);
    tempDeductions.value = [];
  }
};

const applyDeduction = async () => {
  if (!deductionCode.value || !activeDivision.value) return;
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/deductions/code/${deductionCode.value}`
    );
    if (res.data && res.data.deduction_value !== undefined) {
      score.value = Math.max(0, score.value - res.data.deduction_value);
      tempDeductions.value.push(res.data);
    } else {
      alert("Invalid Deduction Code");
    }
  } catch (err) {
    alert("Error fetching deduction by code.");
  }
};

const removeDeduction = (index) => {
  const deduction = tempDeductions.value[index];
  score.value = Math.min(5, score.value + deduction.deduction_value); // Add points back
  removedDeductions.value.push(tempDeductions.value[index]);
  tempDeductions.value.splice(index, 1);
};

const submitScore = async () => {
  if (!selectedActiveParticipant.value || !activeDivision.value) {
    alert("No active participant or division selected!");
    return;
  }
  if (!isJudgeEnabled.value) {
    alert("Judge is disabled!");
    return;
  }
  try {
    const judgeIdentifier = props.judgeTitle.replace("Judge ", "");

    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores`,
      {
        participant_id: selectedActiveParticipant.value,
        judge: judgeIdentifier,
        score: score.value,
        division_id: activeDivision.value.id, // Add division_id
      }
    );

    if (tempDeductions.value.length > 0) {
      for (const deduction of tempDeductions.value) {
        if (deduction.deduction_id && !deduction.participant_deduction_id) {
          await axios.post(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participant-deductions`,
            {
              participant_id: selectedActiveParticipant.value,
              deduction_id: deduction.deduction_id,
              judge: judgeIdentifier,
              division_id: activeDivision.value.id, // Add division_id
            }
          );
        }
      }
    }

    if (removedDeductions.value.length > 0) {
      for (const deduction of removedDeductions.value) {
        if (deduction.deduction_id) {
          await axios.delete(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participant-deductions/${selectedActiveParticipant.value}/${deduction.deduction_id}/${judgeIdentifier}/${activeDivision.value.id}` // Add division_id
          );
        }
      }
    }

    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`,
      {
        argument: props.judgeTitle.replace(" ", "_"),
        value: 0,
      }
    );
    isJudgeEnabled.value = false;

    socket.emit("scoreSubmitted", { judge: props.judgeTitle.replace(" ", "_") });

    alert("Score and deductions submitted successfully!");
    tempDeductions.value = [];
    removedDeductions.value = [];
    await fetchDeductions();
  } catch (err) {
    console.error("Error submitting score or deductions:", err.response?.data || err.message);
    alert("Error submitting score or deductions. Check console for details.");
  }
};

onMounted(async () => {
  await fetchActiveDivision();
  await fetchActiveParticipant();
  if (selectedActiveParticipant.value && isJudgeEnabled.value && activeDivision.value) {
    await fetchLatestScore();
    await fetchDeductions();
  }

  socket.on("tournamentDetailsUpdated", (data) => {
    selectedActiveParticipant.value = data.Active_ID || null;
    isJudgeEnabled.value = data[props.judgeTitle.replace(" ", "_")] === 1;
    if (selectedActiveParticipant.value && isJudgeEnabled.value) {
      axios
        .get(
          `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${selectedActiveParticipant.value}`
        )
        .then((res) => {
          const participant = res.data;
          // Compute full name
          participant.fullName = [participant.first_name, participant.middle_name, participant.last_name]
            .filter((part) => part)
            .join(" ");
          activeParticipant.value = participant;
          fetchLatestScore();
          fetchDeductions();
        })
        .catch((err) => {
          console.error("Error fetching participant:", err);
          activeParticipant.value = null;
        });
    } else {
      activeParticipant.value = null;
    }
  });

  socket.on("scorePublished", (data) => {
    console.log("Score published:", data);
    if (data.participantId === selectedActiveParticipant.value) {
      fetchLatestScore();
    }
  });

  socket.on("deductionUpdated", (data) => {
    console.log("Deduction updated:", data);
    if (data.participantId === selectedActiveParticipant.value) {
      fetchDeductions();
    }
  });
});
</script>

<style>
body {
  font-family: Arial, sans-serif;
}
.text-primary {
  color: #1e40af;
}
.bg-primary {
  background-color: #1e40af;
}
.text-accent {
  color: #10b981;
}
input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: #10b981;
  cursor: pointer;
  border-radius: 50%;
}
input[type="range"]:disabled::-webkit-slider-thumb {
  background: #d1d5db;
}
</style>