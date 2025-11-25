<template>
  <div class="container mx-auto p-4">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-3xl font-bold text-gray-800">Tournament Management</h2>
      <button
        @click="openAddForm"
        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded shadow transition font-semibold"
      >
        + New Tournament
      </button>
    </div>

    <div class="bg-white rounded-lg shadow-lg overflow-hidden border border-gray-200">
      <div v-if="tournaments.length">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
             <tr>
              <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Tournament Details</th>
              <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Location</th>
              <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Actions</th>
             </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr 
              v-for="tournament in tournaments" 
              :key="tournament.tournament_id" 
              :class="tournament.is_active ? 'bg-green-50' : 'hover:bg-gray-50'"
              class="transition-colors duration-150"
            >
              <td class="px-6 py-4 whitespace-nowrap">
                <div v-if="tournament.is_active" class="flex items-center">
                  <span class="h-3 w-3 rounded-full bg-green-500 mr-2 animate-pulse"></span>
                  <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800 border border-green-200">
                    CURRENTLY ACTIVE
                  </span>
                </div>
                <button 
                  v-else 
                  @click="setActiveTournament(tournament)"
                  class="group flex items-center px-3 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-600 border border-gray-300 hover:bg-blue-50 hover:text-blue-600 hover:border-blue-300 transition"
                >
                  <span class="h-2 w-2 rounded-full bg-gray-400 mr-2 group-hover:bg-blue-500"></span>
                  Set as Active
                </button>
              </td>

              <td class="px-6 py-4">
                <div class="text-lg font-bold text-gray-900">{{ tournament.tournament_title }}</div>
                <div class="text-sm text-gray-500 mt-1">
                  📅 {{ formatDate(tournament.tournament_start_date) }} - {{ formatDate(tournament.tournament_end_date) }}
                </div>
              </td>

              <td class="px-6 py-4 text-sm text-gray-600">
                <div class="font-medium">{{ tournament.tournament_city || 'Online' }}</div>
                <div class="text-xs">{{ tournament.tournament_state }}</div>
              </td>

              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button 
                  @click="editTournament(tournament)" 
                  class="text-indigo-600 hover:text-indigo-900 mr-6 font-semibold"
                >
                  Edit
                </button>
                <button 
                  v-if="!tournament.is_active" 
                  @click="deleteTournament(tournament.tournament_id)" 
                  class="text-red-500 hover:text-red-700 font-semibold"
                >
                  Delete
                </button>
                <span v-else class="text-gray-300 cursor-not-allowed font-semibold" title="Cannot delete active tournament">
                  Delete
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="p-10 text-center text-gray-500 bg-gray-50">
        <p class="text-xl font-medium">No tournaments found.</p>
        <p class="mt-2 text-sm">Click the button above to create your first event.</p>
      </div>
    </div>

    <div v-if="showAddForm" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h3 class="text-xl font-bold text-gray-800">{{ editTournamentId ? 'Edit Tournament' : 'Create New Tournament' }}</h3>
          <button @click="cancelForm" class="text-gray-400 hover:text-gray-600 transition text-3xl leading-none">&times;</button>
        </div>
        
        <div class="p-6">
          <form @submit.prevent="handleSubmit">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="md:col-span-2">
                <label class="block text-sm font-bold text-gray-700 mb-1">Tournament Title *</label>
                <input 
                  v-model="newTournament.tournament_title" 
                  required 
                  class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
                  placeholder="e.g. Winter Open 2025"
                />
              </div>
              
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Start Date</label>
                <input v-model="newTournament.tournament_start_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">End Date</label>
                <input v-model="newTournament.tournament_end_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>

              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Email Contact</label>
                <input v-model="newTournament.tournament_email" type="email" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
               <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Phone Contact</label>
                <input v-model="newTournament.tournament_contact" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>

              <div class="md:col-span-2">
                <label class="block text-sm font-bold text-gray-700 mb-1">Address</label>
                <input v-model="newTournament.tournament_address" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">City</label>
                <input v-model="newTournament.tournament_city" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">State</label>
                <input v-model="newTournament.tournament_state" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
            </div>

            <div v-if="errorMessage" class="mt-4 p-3 bg-red-50 text-red-600 border border-red-200 rounded-lg text-sm">
              {{ errorMessage }}
            </div>

            <div class="mt-8 flex justify-end space-x-3 pt-6 border-t border-gray-100">
              <button 
                @click="cancelForm" 
                type="button" 
                class="px-5 py-2.5 rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 font-medium transition"
              >
                Cancel
              </button>
              <button 
                type="submit" 
                class="px-6 py-2.5 rounded-lg bg-blue-600 text-white hover:bg-blue-700 font-medium shadow-md hover:shadow-lg transition"
              >
                {{ editTournamentId ? 'Save Changes' : 'Create Tournament' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    
    <div class="mt-8">
      <button @click="goToAdminDashboard" class="text-gray-500 hover:text-gray-800 flex items-center font-medium transition">
        <span class="mr-2">←</span> Back to Admin Dashboard
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
const editTournamentId = ref(null);
const errorMessage = ref('');

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
  is_active: false
});

const fetchTournaments = async () => {
  try {
    const response = await axios.get('/tournaments');
    tournaments.value = response.data;
  } catch (error) {
    console.error('Error fetching tournaments:', error);
  }
};

const setActiveTournament = async (tournament) => {
  if(!confirm(`Set "${tournament.tournament_title}" as the Active Tournament? This will archive all others.`)) return;
  
  try {
    // We update the specific tournament to be active
    // The backend handles setting others to inactive
    await axios.put(`/tournaments/${tournament.tournament_id}`, {
      ...tournament,
      is_active: true
    });
    await fetchTournaments(); // Refresh list to show new status
  } catch (error) {
    alert('Failed to set active tournament');
    console.error(error);
  }
};

const handleSubmit = async () => {
  errorMessage.value = '';
  if (!newTournament.value.tournament_title) {
    errorMessage.value = 'Title is required';
    return;
  }

  try {
    if (editTournamentId.value) {
      await axios.put(`/tournaments/${editTournamentId.value}`, newTournament.value);
    } else {
      await axios.post('/tournaments', newTournament.value);
    }
    await fetchTournaments();
    closeForm();
  } catch (error) {
    errorMessage.value = error.response?.data?.error || 'Failed to save tournament.';
  }
};

const editTournament = (t) => {
  editTournamentId.value = t.tournament_id;
  newTournament.value = {
    ...t,
    tournament_start_date: t.tournament_start_date ? t.tournament_start_date.split('T')[0] : '',
    tournament_end_date: t.tournament_end_date ? t.tournament_end_date.split('T')[0] : '',
    is_active: t.is_active
  };
  showAddForm.value = true;
};

const deleteTournament = async (id) => {
  if (confirm('Are you sure? This will delete the tournament and ALL associated registrations permanently.')) {
    try {
      await axios.delete(`/tournaments/${id}`);
      fetchTournaments();
    } catch (error) {
      alert('Failed to delete tournament');
    }
  }
};

const formatDate = (dateStr) => {
  if (!dateStr) return 'TBD';
  return new Date(dateStr).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
};

const openAddForm = () => {
  resetForm();
  showAddForm.value = true;
};

const cancelForm = () => {
  closeForm();
};

const closeForm = () => {
  showAddForm.value = false;
  resetForm();
};

const resetForm = () => {
  editTournamentId.value = null;
  errorMessage.value = '';
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
    is_active: false
  };
};

const goToAdminDashboard = () => router.push('/admin');

onMounted(fetchTournaments);
</script>