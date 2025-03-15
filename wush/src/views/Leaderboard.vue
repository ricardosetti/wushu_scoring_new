<template>
    <div class="min-h-screen bg-gray-100 flex justify-center items-center p-4">
      <div class="w-full max-w-5xl bg-white rounded-xl shadow-lg p-6">
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
            class="flex flex-col sm:flex-row sm:items-center bg-gray-50 p-3 rounded-lg hover:bg-gray-100 transition"
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
  </template>
  
  <script setup>
  import { ref, onMounted, inject, computed } from "vue";
  import axios from "axios";
  
  const socket = inject("socket");
  const activeDivision = ref(null);
  const participants = ref([]);
  const rankedParticipants = computed(() => {
    if (!activeDivision.value) return [];
    // Filter participants by active division and only include those with a Final score
    const filtered = participants.value
      .filter((participant) =>
        participant.divisions.includes(activeDivision.value.division_name)
      )
      .filter((participant) => {
        const finalScore = parseFloat(participant.scores.Final);
        return finalScore > 0 && !isNaN(finalScore); // Only include participants with a valid positive Final score
      })
      .map((participant) => ({
        ...participant,
        scores: participant.scores || {},
      }));
    // Sort by Final score (descending)
    return filtered.sort((a, b) => {
      const scoreA = parseFloat(a.scores.Final) || 0;
      const scoreB = parseFloat(b.scores.Final) || 0;
      return scoreB - scoreA;
    });
  });
  
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
  
  const fetchParticipants = async () => {
    try {
      const res = await axios.get(
        `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants`
      );
      participants.value = res.data.map((participant) => {
        participant.fullName = [participant.first_name, participant.middle_name, participant.last_name]
          .filter((part) => part)
          .join(" ");
        participant.scores = {};
        return participant;
      });
      await fetchParticipantScores();
    } catch (err) {
      console.error("Error fetching participants:", err);
      participants.value = [];
    }
  };
  
  const fetchParticipantScores = async () => {
    for (const participant of participants.value) {
      try {
        const res = await axios.get(
          `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/published-scores/participant/${participant.id}`
        );
        participant.scores = res.data.scores.reduce((acc, { judge, score }) => {
          acc[judge] = score;
          return acc;
        }, {});
      } catch (err) {
        participant.scores = {};
      }
    }
  };
  
  onMounted(() => {
    fetchActiveDivision();
    fetchParticipants();
  
    socket.on("activeDivisionUpdated", (data) => {
      activeDivision.value = data;
      fetchParticipants(); // Refresh participants when division changes
    });
  
    socket.on("scorePublished", (data) => {
      console.log("Score published:", data);
      const participant = participants.value.find((p) => p.id === data.participantId);
      if (participant && data.division_id === activeDivision.value?.id) {
        participant.scores = data.scores.reduce((acc, { judge, score }) => {
          acc[judge] = score;
          return acc;
        }, {});
      }
    });
  });
  </script>
  
  <style>
  .text-primary {
    color: #1e40af;
  }
  </style>