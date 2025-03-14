<template>
  <div class="p-6 max-w-2xl mx-auto bg-white rounded-xl shadow-lg space-y-6">
    <h2 class="text-3xl font-bold text-center text-primary">Head Judge Panel</h2>

    <div class="bg-gray-50 p-4 rounded-lg shadow-inner">
      <table class="w-full border-collapse">
        <thead>
          <tr class="bg-primary text-white">
            <th class="p-3">Participant</th>
            <th class="p-3">School</th>
            <th class="p-3">Divisions</th>
            <th class="p-3">Active</th>
            <th class="p-3">On Deck</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="participant in participants" :key="participant.id" class="hover:bg-gray-100">
            <td class="border p-3">{{ participant.fullName || 'N/A' }}</td>
            <td class="border p-3">{{ participant.school_name || 'N/A' }}</td>
            <td class="border p-3">{{ participant.divisions.length ? participant.divisions.join(', ') : 'N/A' }}</td>
            <td class="border p-3 text-center">
              <input type="radio" name="activeParticipant" :value="participant.id" v-model="selectedActiveParticipant" class="accent-accent" />
            </td>
            <td class="border p-3 text-center">
              <input type="radio" name="onDeckParticipant" :value="participant.id" v-model="selectedOnDeckParticipant" class="accent-accent" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>

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
      <div class="grid grid-cols-2 gap-4">
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
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from "vue";
import axios from "axios";

const socket = inject("socket");
const participants = ref([]);
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

const fetchParticipants = async () => {
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants`
    );
    participants.value = res.data.map((participant) => {
      // Compute full name
      participant.fullName = [participant.first_name, participant.middle_name, participant.last_name]
        .filter((part) => part)
        .join(" ");
      return participant;
    });
  } catch (err) {
    console.error("Error fetching participants:", err.response?.data || err.message);
    participants.value = [];
  }
};

const fetchTournamentDetails = async () => {
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`
    );
    if (res.data) {
      selectedActiveParticipant.value = res.data.Active_ID || null;
      selectedOnDeckParticipant.value = res.data.OnDeck_ID || null;
      judgeStates.value.Judge_A1 = res.data.Judge_A1 || 0;
      judgeStates.value.Judge_A2 = res.data.Judge_A2 || 0;
      judgeStates.value.Judge_B1 = res.data.Judge_B1 || 0;
      judgeStates.value.Judge_B2 = res.data.Judge_B2 || 0;
      allJudgesOn.value = Object.values(judgeStates.value).every((state) => state === 1);
    }
  } catch (err) {
    console.error("Error fetching tournament details:", err.response?.data || err.message);
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
    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`,
      {
        argument: "Active_ID",
        value: selectedActiveParticipant.value,
      }
    );
    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`,
      {
        argument: "OnDeck_ID",
        value: selectedOnDeckParticipant.value,
      }
    );
    for (const judge of judges) {
      await axios.post(
        `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`,
        {
          argument: judge.id,
          value: judgeStates.value[judge.id],
        }
      );
    }
    socket.emit("updateTournamentDetails", {
      Active_ID: selectedActiveParticipant.value,
      OnDeck_ID: selectedOnDeckParticipant.value,
      ...judgeStates.value,
    });
    alert("Tournament details saved successfully!");
    await fetchTournamentDetails();
  } catch (err) {
    alert("Error saving tournament details.");
  }
};

const calculateFinalScore = async () => {
  if (!selectedActiveParticipant.value) {
    alert("No active participant selected!");
    return;
  }
  try {
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores/participant/${selectedActiveParticipant.value}`
    );
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

    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores`,
      {
        participant_id: selectedActiveParticipant.value,
        judge: "FinalA",
        score: finalA,
      }
    );
    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores`,
      {
        participant_id: selectedActiveParticipant.value,
        judge: "FinalB",
        score: finalB,
      }
    );
    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores`,
      {
        participant_id: selectedActiveParticipant.value,
        judge: "Final",
        score: final,
      }
    );

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
    const res = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/scores/participant/${selectedActiveParticipant.value}`
    );
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

    await axios.post(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/published-scores`,
      {
        participant_id: selectedActiveParticipant.value,
        scores: publishData,
      }
    );

    // Emit WebSocket event to update scoreboard
    socket.emit("scorePublished", {
      participantId: selectedActiveParticipant.value,
      scores: publishData,
    });

    alert("Score published successfully!");
  } catch (err) {
    console.error("Error publishing score:", err.response?.data || err.message);
    alert("Error publishing score. Check console for details.");
  }
};

onMounted(() => {
  fetchParticipants();
  fetchTournamentDetails();

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
  });

  socket.on("scorePublished", (data) => {
    console.log("Score published:", data);
    // Optionally refresh tournament details if needed
  });

  socket.on("deductionUpdated", (data) => {
    console.log("Deduction updated:", data);
    // Optionally refresh if deductions affect Head Judge view
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
.text-secondary {
  color: #f97316;
}
.bg-secondary {
  background-color: #f97316;
}
.text-accent {
  color: #10b981;
}
.bg-accent {
  background-color: #10b981;
}
</style>