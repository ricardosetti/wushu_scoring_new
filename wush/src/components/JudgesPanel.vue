<template>
  <div class="p-6 max-w-lg mx-auto bg-white rounded-xl shadow-lg space-y-6">
    <div class="text-center border-b pb-4">
      <h2 class="text-3xl font-bold text-primary">{{ judgeTitle }}</h2>
      <div v-if="activeParticipant" class="mt-2 inline-block bg-blue-50 text-blue-800 px-3 py-1 rounded-full text-sm font-semibold">
        {{ activeParticipant.fullName }}
      </div>
    </div>
    
    <!-- WAITING STATE -->
    <div v-if="!isJudgeEnabled || !activeParticipant" class="text-center py-10 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300">
      <div v-if="!activeParticipant" class="text-gray-400 font-medium">Waiting for Head Judge to select participant...</div>
      <div v-else class="text-red-500 font-bold text-lg">Scoring Locked</div>
      <p class="text-xs text-gray-400 mt-2">Panel will activate when Head Judge opens scoring.</p>
    </div>

    <!-- SCORING INTERFACE -->
    <div v-else class="space-y-6">
      
      <!-- JUDGE A (Quality) -->
      <div v-if="judgeType === 'A'" class="space-y-6">
        <div class="bg-gray-100 p-4 rounded-lg text-center">
          <p class="text-gray-500 text-sm uppercase font-bold">Current Score</p>
          <div class="text-5xl font-mono font-bold text-primary">{{ currentScore.toFixed(2) }}</div>
          <p class="text-xs text-gray-400 mt-1">Starts at 5.00</p>
        </div>

        <div class="space-y-2">
          <label class="block text-sm font-bold text-gray-700">Add Deduction Code</label>
          <div class="flex space-x-2">
            <input 
              type="number" 
              v-model="deductionCode" 
              @keyup.enter="applyDeduction"
              placeholder="Code (e.g. 71)"
              class="flex-1 border p-3 rounded-lg focus:ring-2 focus:ring-blue-500 text-lg shadow-sm"
            />
            <!-- Restore Apply Button (Green) -->
            <button 
              @click="applyDeduction" 
              class="bg-green-600 text-white px-6 rounded-lg font-bold hover:bg-green-700 transition shadow-sm"
            >
              Apply
            </button>
          </div>
        </div>

        <!-- Deduction List -->
        <div v-if="deductionsList.length > 0" class="border rounded-lg overflow-hidden">
          <table class="w-full text-sm">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-3 py-2 text-left">Code</th>
                <th class="px-3 py-2 text-left">Desc</th>
                <th class="px-3 py-2 text-right">Value</th>
                <th class="px-3 py-2"></th>
              </tr>
            </thead>
            <tbody class="divide-y">
              <tr v-for="(d, index) in deductionsList" :key="index" class="bg-white">
                <td class="px-3 py-2 font-mono font-bold">{{ d.deduction_code }}</td>
                <td class="px-3 py-2 text-gray-600 truncate max-w-[120px]">{{ d.deduction_description }}</td>
                <td class="px-3 py-2 text-right text-red-600 font-bold">-{{ d.deduction_value }}</td>
                <td class="px-3 py-2 text-center">
                  <button @click="removeDeduction(d)" class="text-red-400 hover:text-red-700 text-lg font-bold">&times;</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- JUDGE B (Overall) -->
      <div v-if="judgeType === 'B'" class="space-y-8 py-4">
        <div class="bg-gray-100 p-4 rounded-lg text-center">
          <p class="text-gray-500 text-sm uppercase font-bold">Your Score</p>
          <div class="text-6xl font-mono font-bold text-primary">{{ currentScore.toFixed(2) }}</div>
        </div>

        <div>
          <input 
            type="range" 
            v-model.number="currentScore" 
            min="0" 
            max="5" 
            step="0.01" 
            class="w-full h-4 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-blue-600"
          />
          <div class="flex justify-between text-xs text-gray-400 mt-2">
            <span>0.0</span>
            <span>1.0</span>
            <span>2.0</span>
            <span>3.0</span>
            <span>4.0</span>
            <span>5.0</span>
          </div>
        </div>
      </div>

      <!-- SUBMIT BUTTON -->
      <button 
        @click="submitScore" 
        class="w-full bg-green-600 text-white py-4 rounded-xl font-bold text-xl shadow-lg hover:bg-green-700 transition transform active:scale-95"
      >
        Submit Score
      </button>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject } from 'vue';
import axios from '../axios';

const props = defineProps({
  judgeTitle: String, // e.g. "Judge A1"
  judgeType: String   // "A" or "B"
});

const socket = inject("socket");

const activeParticipant = ref(null);
const activeDivision = ref(null);
const isJudgeEnabled = ref(false);

// State
const currentScore = ref(5.00); 
const deductionCode = ref('');
const deductionsList = ref([]); 

const judgeKey = props.judgeTitle.replace(" ", "_"); // "Judge_A1"

// --- Data Fetching ---

const fetchContext = async () => {
  try {
    const [statusRes, divRes] = await Promise.all([
      axios.get('/tournament-details'),
      axios.get('/divisions/active')
    ]);

    // 1. Check if Enabled
    const wasEnabled = isJudgeEnabled.value;
    isJudgeEnabled.value = statusRes.data[judgeKey] === 1;
    
    const participantId = statusRes.data.Active_ID;
    activeDivision.value = divRes.data;

    // 2. Load Participant
    if (participantId) {
      // Only re-fetch if the participant changed to avoid resetting state during minor updates
      if (activeParticipant.value?.id !== participantId) {
        const pRes = await axios.get(`/participants/${participantId}`);
        const p = pRes.data;
        activeParticipant.value = { 
          ...p, 
          fullName: `${p.first_name} ${p.last_name}` 
        };
        
        // Reset defaults for new participant
        currentScore.value = 5.00;
        deductionsList.value = [];
        
        // If judge is enabled, check for saved data
        if (isJudgeEnabled.value) {
          await loadExistingState();
        }
      } else if (!wasEnabled && isJudgeEnabled.value) {
        // Participant didn't change, but Judge just got enabled -> Load state
        await loadExistingState();
      }
    } else {
      activeParticipant.value = null;
    }

  } catch (err) {
    console.error("Context Error:", err);
  }
};

const loadExistingState = async () => {
  if (!activeParticipant.value || !activeDivision.value) return;

  if (props.judgeType === 'A') {
    // Load Deductions
    const judgeId = props.judgeTitle.replace("Judge ", ""); 
    const res = await axios.get(`/participant-deductions/${activeParticipant.value.id}/${judgeId}`, {
      params: { division_id: activeDivision.value.id }
    });
    deductionsList.value = res.data;
    recalculateScoreA();
  } else {
    // Load Score for B
    const judgeId = props.judgeTitle.replace("Judge ", ""); 
    const res = await axios.get(`/scores/latest`, {
      params: { 
        participant_id: activeParticipant.value.id,
        judge: judgeId
      }
    });
    if (res.data && res.data.score) {
      currentScore.value = parseFloat(res.data.score);
    } 
  }
};

// --- Actions ---

const recalculateScoreA = () => {
  const totalDeductions = deductionsList.value.reduce((sum, d) => sum + parseFloat(d.deduction_value || 0), 0);
  currentScore.value = Math.max(0, 5.0 - totalDeductions);
};

const applyDeduction = async () => {
  if (!deductionCode.value) return;
  
  try {
    const res = await axios.get(`/deductions/code/${deductionCode.value}`);
    const deduction = res.data;

    const judgeId = props.judgeTitle.replace("Judge ", "");
    const saveRes = await axios.post('/participant-deductions', {
      participant_id: activeParticipant.value.id,
      deduction_id: deduction.deduction_id,
      judge: judgeId,
      division_id: activeDivision.value.id
    });

    deductionsList.value.unshift(saveRes.data); 
    recalculateScoreA();
    deductionCode.value = ''; 

  } catch (err) {
    alert("Invalid Code");
  }
};

const removeDeduction = async (deduction) => {
  try {
    const judgeId = props.judgeTitle.replace("Judge ", "");
    
    // We use deduction_id + params to ensure we delete the correct one for this event
    await axios.delete(`/participant-deductions/${activeParticipant.value.id}/${deduction.deduction_id}/${judgeId}`, {
      params: { division_id: activeDivision.value.id }
    });

    deductionsList.value = deductionsList.value.filter(d => d !== deduction);
    recalculateScoreA();

  } catch (err) {
    console.error(err);
    alert("Failed to remove deduction");
  }
};

const submitScore = async () => {
  if(!confirm("Confirm Score Submission?")) return;

  try {
    const judgeId = props.judgeTitle.replace("Judge ", "");
    
    await axios.post('/scores', {
      participant_id: activeParticipant.value.id,
      judge: judgeId,
      score: currentScore.value,
      division_id: activeDivision.value.id,
    });

    // Lock the Panel
    await axios.post('/tournament-details', { argument: judgeKey, value: 0 });
    isJudgeEnabled.value = false;

    socket.emit("scoreSubmitted", { judge: judgeKey });
    alert("Score Submitted!");

  } catch (e) {
    alert("Submission Failed");
  }
};

// --- Lifecycle ---

onMounted(() => {
  fetchContext();

  socket.on("tournamentDetailsUpdated", (data) => {
    const newParticipantId = data.Active_ID || null;
    const newJudgeState = data[judgeKey] === 1;

    // Refresh context if participant changed or lock status changed
    if (newParticipantId !== activeParticipant.value?.id) {
        fetchContext();
    } else if (newJudgeState !== isJudgeEnabled.value) {
        isJudgeEnabled.value = newJudgeState;
        if (newJudgeState) loadExistingState();
    }
  });
});

onUnmounted(() => {
  socket.off("tournamentDetailsUpdated");
});
</script>