<template>
  <div class="container mx-auto p-4">
    <h2 class="text-xl font-bold mb-4">Tournament Management</h2>
    <button
      @click="openAddForm"
      class="bg-green-500 text-white px-4 py-2 rounded mb-4 hover:bg-green-600 mr-2"
    >
      Add New Tournament
    </button>

    <!-- Modal for Add/Edit Tournament -->
    <div v-if="showAddForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <h3 class="text-lg font-bold mb-4">{{ editTournamentId ? 'Edit Tournament' : 'Add Tournament' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="mb-2 col-span-2">
              <label class="block">Tournament Title *</label>
              <input v-model="newTournament.tournament_title" required class="border p-2 w-full rounded" />
              <div v-if="errorMessage && !newTournament.tournament_title" class="text-red-500 text-sm mt-1">
                Tournament title is required.
              </div>
            </div>
            <div class="mb-2">
              <label class="block">Start Date</label>
              <input v-model="newTournament.tournament_start_date" type="date" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">End Date</label>
              <input v-model="newTournament.tournament_end_date" type="date" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Hours</label>
              <input v-model="newTournament.tournament_hours" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Contact</label>
              <input v-model="newTournament.tournament_contact" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2 col-span-2">
              <label class="block">Address</label>
              <input v-model="newTournament.tournament_address" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">City</label>
              <input v-model="newTournament.tournament_city" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">State</label>
              <input v-model="newTournament.tournament_state" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Country</label>
              <input v-model="newTournament.tournament_country" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Email</label>
              <input v-model="newTournament.tournament_email" type="email" class="border p-2 w-full rounded" />
            </div>
          </div>
          <div class="mt-4 flex justify-end">
            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              {{ editTournamentId ? 'Update' : 'Save' }}
            </button>
            <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
              Cancel
            </button>
          </div>
          <div v-if="errorMessage" class="mt-2 text-red-500">{{ errorMessage }}</div>
        </form>
      </div>
    </div>

    <!-- Tournament List -->
    <div v-if="tournaments.length">
      <h3 class="text-lg font-bold mb-2">Tournaments</h3>
      <div v-for="tournament in tournaments" :key="tournament.tournament_id" class="border p-2 mb-2 flex justify-between items-center">
        <span>
          {{ tournament.tournament_title }}
          ({{ tournament.tournament_start_date ? new Date(tournament.tournament_start_date).toLocaleDateString() : 'N/A' }} -
          {{ tournament.tournament_end_date ? new Date(tournament.tournament_end_date).toLocaleDateString() : 'N/A' }},
          {{ tournament.tournament_city || 'N/A' }}, {{ tournament.tournament_state || 'N/A' }})
        </span>
        <div>
          <button @click="editTournament(tournament)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">
            Edit
          </button>
          <button @click="deleteTournament(tournament.tournament_id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
            Delete
          </button>
        </div>
      </div>
    </div>
    <div v-else>
      <p>No tournaments found.</p>
    </div>

    <!-- Navigation and Logout -->
    <div class="mt-4 flex justify-between">
      <button
        @click="goToAdminDashboard"
        class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600"
      >
        Back to Admin Dashboard
      </button>
      <button
        @click="logout"
        class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
      >
        Logout
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const tournaments = ref([]);
const showAddForm = ref(false);
const newTournament = ref({
  tournament_title: '',
  tournament_start_date: '',
  tournament_end_date: '',
  tournament_hours: '',
  tournament_contact: '',
  tournament_address: '',
  tournament_city: '',
  tournament_state: '',
  tournament_country: '',
  tournament_email: '',
});
const editTournamentId = ref(null);
const errorMessage = ref('');

const fetchTournaments = async () => {
  try {
    console.log('Fetching tournaments...');
    const response = await axios.get('/tournaments');
    console.log('Tournaments response:', response.data);
    tournaments.value = response.data;
  } catch (error) {
    console.error('Error fetching tournaments:', error.response ? error.response.data : error.message);
    tournaments.value = [];
  }
};

const handleSubmit = () => {
  errorMessage.value = '';
  if (!newTournament.value.tournament_title) {
    errorMessage.value = 'Tournament title is required.';
    return;
  }
  console.log('Submitting form, editTournamentId:', editTournamentId.value, 'Data:', newTournament.value);
  if (editTournamentId.value) {
    updateTournament();
  } else {
    addTournament();
  }
};

const addTournament = async () => {
  console.log('Adding new tournament, Data:', newTournament.value);
  try {
    const response = await axios.post('/tournaments', newTournament.value);
    console.log('Add response:', response.data);
    tournaments.value.push(response.data);
    tournaments.value.sort((a, b) => {
      const dateA = a.tournament_start_date ? new Date(a.tournament_start_date) : new Date(0);
      const dateB = b.tournament_start_date ? new Date(b.tournament_start_date) : new Date(0);
      return dateB - dateA || a.tournament_title.localeCompare(b.tournament_title);
    });
    showAddForm.value = false;
  } catch (error) {
    console.error('Error adding tournament:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to add tournament. Please try again.';
  }
};

const editTournament = (tournament) => {
  editTournamentId.value = tournament.tournament_id;
  newTournament.value = {
    tournament_title: tournament.tournament_title,
    tournament_start_date: tournament.tournament_start_date ? tournament.tournament_start_date.split('T')[0] : '',
    tournament_end_date: tournament.tournament_end_date ? tournament.tournament_end_date.split('T')[0] : '',
    tournament_hours: tournament.tournament_hours || '',
    tournament_contact: tournament.tournament_contact || '',
    tournament_address: tournament.tournament_address || '',
    tournament_city: tournament.tournament_city || '',
    tournament_state: tournament.tournament_state || '',
    tournament_country: tournament.tournament_country || '',
    tournament_email: tournament.tournament_email || '',
  };
  showAddForm.value = true;
};

const updateTournament = async () => {
  console.log('Updating tournament with id:', editTournamentId.value, 'Data:', newTournament.value);
  try {
    const response = await axios.put(`/tournaments/${editTournamentId.value}`, newTournament.value);
    console.log('Update response:', response.data);
    const index = tournaments.value.findIndex(t => t.tournament_id === editTournamentId.value);
    if (index !== -1) {
      tournaments.value[index] = response.data;
    }
    tournaments.value.sort((a, b) => {
      const dateA = a.tournament_start_date ? new Date(a.tournament_start_date) : new Date(0);
      const dateB = b.tournament_start_date ? new Date(b.tournament_start_date) : new Date(0);
      return dateB - dateA || a.tournament_title.localeCompare(b.tournament_title);
    });
    showAddForm.value = false;
  } catch (error) {
    console.error('Error updating tournament:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to update tournament. Please try again.';
  }
};

const deleteTournament = async (id) => {
  if (confirm('Are you sure you want to delete this tournament?')) {
    try {
      await axios.delete(`/tournaments/${id}`);
      tournaments.value = tournaments.value.filter(t => t.tournament_id !== id);
    } catch (error) {
      console.error('Error deleting tournament:', error.response ? error.response.data : error.message);
    }
  }
};

const resetForm = () => {
  newTournament.value = {
    tournament_title: '',
    tournament_start_date: '',
    tournament_end_date: '',
    tournament_hours: '',
    tournament_contact: '',
    tournament_address: '',
    tournament_city: '',
    tournament_state: '',
    tournament_country: '',
    tournament_email: '',
  };
  editTournamentId.value = null;
  errorMessage.value = '';
};

const openAddForm = () => {
  showAddForm.value = true;
  resetForm();
};

const cancelForm = () => {
  showAddForm.value = false;
  resetForm();
};

const goToAdminDashboard = () => {
  router.push('/admin');
};

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/login');
};

onMounted(() => {
  fetchTournaments();
});
</script>

<style scoped>
.max-h-90vh {
  max-height: 90vh;
}
.overflow-y-auto::-webkit-scrollbar {
  width: 8px;
}
.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}
.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}
.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>