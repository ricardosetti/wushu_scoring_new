<template>
  <div class="scoreboard-container">
    <div class="scoreboard-content">
      <table class="scoreboard-table">
        <tr>
          <td class="header-cell">
            <span class="participant-name">{{ activeParticipant?.fullName || 'No Participant' }}</span>
          </td>
        </tr>
        <tr>
          <td class="header-cell">
            <div class="division">Division: {{ activeParticipant?.divisions.length ? activeParticipant.divisions.join(', ') : 'N/A' }}</div>
          </td>
        </tr>
        <tr>
          <td class="header-cell">
            <div class="school">School: {{ activeParticipant?.school_name || 'N/A' }}</div>
          </td>
        </tr>
      </table>
      <hr color="red">

      <table class="group-table">
        <tr>
          <td>
            <div class="group-box group-a">
              <table class="inner-table">
                <tr>
                  <td class="group-title-cell">
                    <h3 class="group-title">Group A</h3>
                  </td>
                  <td class="group-title-cell">
                    <div class="group-title">Deductions</div>
                  </td>
                </tr>
                <tr>
                  <td>
                    <p><strong>Judge A1:</strong> {{ scores.A1 || 'N/A' }}</p>
                    <p><strong>Judge A2:</strong> {{ scores.A2 || 'N/A' }}</p>
                    <p><strong>Final A:</strong> {{ scores.FinalA || 'N/A' }}</p>
                  </td>
                  <td>
                    <div class="deductions-container" v-if="deductionCodes.length">
                      <span v-for="code in deductionCodes" :key="code" class="deduction-circle">{{ code }}</span>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
          </td>
        </tr>
        <tr>
          <td>
            <div class="group-box group-b">
              <h3 class="group-title">Group B</h3>
              <p><strong>Judge B1:</strong> {{ scores.B1 || 'N/A' }}</p>
              <p><strong>Judge B2:</strong> {{ scores.B2 || 'N/A' }}</p>
              <p><strong>Final B:</strong> {{ scores.FinalB || 'N/A' }}</p>
            </div>
          </td>
        </tr>
      </table>

      <p class="placing">Current Placing: N/A</p>
      <p class="final-score">Final Score: {{ scores.Final || 'N/A' }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue';
import axios from 'axios';

const socket = inject('socket');
const activeParticipant = ref(null);
const scores = ref({});
const deductionCodes = ref([]);

const fetchScoreboardData = async () => {
  try {
    const res = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/tournament-details`);
    const activeId = res.data.Active_ID;
    if (!activeId) {
      activeParticipant.value = null;
      scores.value = {};
      deductionCodes.value = [];
      return;
    }

    const participantRes = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${activeId}`
    );
    let participant = participantRes.data;
    // Compute full name
    participant.fullName = [participant.first_name, participant.middle_name, participant.last_name]
      .filter((part) => part)
      .join(' ');
    activeParticipant.value = participant;

    const scoresRes = await axios.get(
      `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/published-scores/participant/${activeId}`
    );
    scores.value = scoresRes.data.scores.reduce((acc, { judge, score }) => {
      acc[judge] = score;
      return acc;
    }, {});
    deductionCodes.value = scoresRes.data.deduction_codes || [];
  } catch (err) {
    console.error('Error fetching scoreboard data:', err);
    activeParticipant.value = null;
    scores.value = {};
    deductionCodes.value = [];
  }
};

onMounted(() => {
  fetchScoreboardData();

  socket.on('scorePublished', (data) => {
    console.log('Score published:', data);
    if (data.participantId === activeParticipant.value?.id) {
      fetchScoreboardData(); // Refresh scoreboard when score is published
    }
  });
});
</script>

<style scoped>
.scoreboard-container {
  min-height: 100vh;
  background-color: #374151; /* Dark gray background */
  color: #ffffff; /* White text */
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  margin: 0;
  box-sizing: border-box;
}

.scoreboard-content {
  width: 100%;
  max-width: 1024px; /* Matches previous max-w-4xl */
  text-align: center;
}

.scoreboard-table, .group-table, .inner-table {
  width: 100%;
  border-collapse: collapse;
}

.header-cell, .group-title-cell {
  padding: 0.5rem;
  vertical-align: middle;
}

.participant-name {
  font-size: 2.25rem; /* Matches text-4xl (36px) */
  font-weight: bold;
  font-family: Arial, sans-serif;
  color: #ffff00; /* Yellow (updated from your layout) */
}

.school, .division {
  font-size: 2rem; /* Larger for visibility */
  color: #ffffff;
  margin-left: 0; /* Removed margin for centering */
  margin-bottom: 0.5rem; /* Adjusted for better spacing */
}

.division {
  margin-bottom: 0.5rem; /* Space between Division and School */
}

.group-box {
  font-size: 2rem;
  background-color: #4A5568; /* Darker gray for boxes */
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 0.5rem; /* Rounded corners */
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Subtle shadow */
}

.group-title {
  font-size: 2rem; /* Matches text-lg (18px) */
  font-weight: bold;
  margin: 0.5rem 0;
  color: #ffff00; /* Yellow for both groups (updated from your layout) */
}

.deductions-container {
  display: flex;
  justify-content: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.deduction-circle {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  width: 4rem; /* Adjustable size */
  height: 4rem; /* Adjustable size */
  border: 4px solid #ff0000; /* Red border, no background (updated from your layout) */
  border-radius: 50%; /* Circular shape */
  font-size: 2rem; /* Matches text-base (16px) */
  color: #ffffff; /* White text */
  font-family: Arial, sans-serif;
  margin: 0.25rem;
}

.group-box p {
  font-size: 1.5rem; /* Matches text-base (16px) */
  color: #ffffff;
  margin: 0.25rem 0;
}

.group-box p strong {
  font-weight: bold;
}

.final-score, .placing {
  font-size: 0.875rem; /* Matches text-sm (14px) for placing */
  margin-bottom: 1rem;
  color: #ffffff;
}

.final-score {
  font-size: 2.25rem; /* Matches text-4xl (36px) */
  font-weight: bold;
  color: #EF4444; /* Red */
}

/* Responsive Design */
@media (max-width: 640px) { /* Mobile (sm) */
  .scoreboard-content {
    max-width: 100%; /* Full width on mobile */
    padding: 0.5rem;
  }

  .participant-name, .final-score {
    font-size: 1.5rem; /* Smaller on mobile */
  }

  .school, .division {
    font-size: 1rem; /* Smaller on mobile */
    margin-left: 0; /* Remove margin for centering */
  }

  .group-title {
    font-size: 1rem;
  }

  .deduction-circle {
    width: 2rem; /* Smaller on mobile */
    height: 2rem; /* Smaller on mobile */
    font-size: 0.875rem; /* Smaller on mobile */
  }

  .group-box p {
    font-size: 0.875rem; /* Smaller on mobile */
  }

  .placing {
    font-size: 0.75rem; /* Smaller on mobile */
  }

  .group-box {
    padding: 0.5rem;
  }
}

@media (min-width: 641px) and (max-width: 1024px) { /* Tablet (md) */
  .scoreboard-content {
    max-width: 800px; /* Slightly narrower on tablets */
    padding: 0.75rem;
  }

  .participant-name, .final-score {
    font-size: 2rem; /* Slightly smaller on tablets */
  }

  .school, .division {
    font-size: 1.125rem;
  }

  .group-title {
    font-size: 1.125rem;
  }

  .deduction-circle {
    width: 2.25rem; /* Slightly smaller on tablets */
    height: 2.25rem; /* Slightly smaller on tablets */
    font-size: 1rem; /* Matches text-base (16px) */
  }

  .group-box p {
    font-size: 1rem;
  }

  .placing {
    font-size: 0.875rem;
  }

  .group-box {
    padding: 0.75rem;
  }
}
</style>