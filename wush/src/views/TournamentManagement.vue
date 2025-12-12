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

    <!-- Tournament List -->
    <div class="bg-white rounded-lg shadow-lg overflow-hidden border border-gray-200">
      <div v-if="tournaments.length">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
             <tr>
              <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Status</th>
              <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase tracking-wider">Tournament Details</th>
              <th class="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase tracking-wider">Public Page</th>
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
              <!-- Status Column -->
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

              <!-- Details Column -->
              <td class="px-6 py-4">
                <div class="text-lg font-bold text-gray-900">{{ tournament.tournament_title }}</div>
                <div class="text-sm text-gray-500 mt-1">
                  📅 {{ formatDate(tournament.tournament_start_date) }} - {{ formatDate(tournament.tournament_end_date) }}
                </div>
                <div class="text-xs text-gray-400 mt-1">
                  {{ tournament.tournament_city || 'Online' }}, {{ tournament.tournament_state }}
                </div>
              </td>

              <!-- Public Page Link -->
              <td class="px-6 py-4 text-right whitespace-nowrap">
                <a 
                  :href="`${baseUrl}t/${tournament.tournament_id}`" 
                  target="_blank" 
                  class="text-blue-600 hover:text-blue-800 font-medium text-sm flex items-center justify-end group"
                >
                  View Page 
                  <span class="ml-1 transition-transform group-hover:translate-x-1">↗</span>
                </a>
              </td>

              <!-- Actions Column -->
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

    <!-- Modal for Add/Edit Tournament -->
    <div v-if="showAddForm" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        
        <!-- Modal Header -->
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h3 class="text-xl font-bold text-gray-800">{{ editTournamentId ? 'Edit Tournament' : 'Create New Tournament' }}</h3>
          <button @click="cancelForm" class="text-gray-400 hover:text-gray-600 transition text-3xl leading-none">&times;</button>
        </div>
        
        <!-- Modal Body -->
        <div class="p-6">
          <!-- Tabs -->
          <div class="flex border-b mb-6">
            <button @click="activeTab = 'general'" class="px-4 py-2 font-medium transition-colors border-b-2" :class="activeTab === 'general' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'">General Info</button>
            <button @click="activeTab = 'design'" class="px-4 py-2 font-medium transition-colors border-b-2" :class="activeTab === 'design' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'">Page Design</button>
          </div>

          <form @submit.prevent="handleSubmit">
            
            <!-- TAB: GENERAL -->
            <div v-show="activeTab === 'general'" class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="md:col-span-2">
                <label class="block text-sm font-bold text-gray-700 mb-1">Tournament Title *</label>
                <input v-model="form.tournament_title" required class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" />
              </div>
              
              <div><label class="block text-sm font-bold text-gray-700 mb-1">Start Date</label><input v-model="form.tournament_start_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              <div><label class="block text-sm font-bold text-gray-700 mb-1">End Date</label><input v-model="form.tournament_end_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              <div class="md:col-span-2 grid grid-cols-2 gap-6 border-t pt-4 mt-2">
                <div class="md:col-span-2 text-sm font-bold text-gray-700">Registration Window (When athletes can sign up)</div>
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Registration Opens</label>
                <input v-model="form.registration_start_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5" />
              </div>
              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Registration Closes</label>
                <input v-model="form.registration_end_date" type="date" class="w-full border border-gray-300 rounded-lg p-2.5" />
              </div>
            </div>

              <div><label class="block text-sm font-bold text-gray-700 mb-1">Email Contact</label><input v-model="form.tournament_email" type="email" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              <div><label class="block text-sm font-bold text-gray-700 mb-1">Phone Contact</label><input v-model="form.tournament_contact" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>

              <div class="md:col-span-2"><label class="block text-sm font-bold text-gray-700 mb-1">Address</label><input v-model="form.tournament_address" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              <div><label class="block text-sm font-bold text-gray-700 mb-1">City</label><input v-model="form.tournament_city" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              <div><label class="block text-sm font-bold text-gray-700 mb-1">State</label><input v-model="form.tournament_state" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" /></div>
              
              <!-- JUDGES CONFIGURATION (NEW) -->
              <div class="md:col-span-2 mt-2 p-4 border rounded-lg bg-gray-50 border-gray-200">
                <label class="block text-sm font-bold text-gray-800 mb-3">Active Judges Panel</label>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <label class="flex items-center space-x-2 cursor-pointer p-2 rounded hover:bg-gray-100 transition">
                    <input v-model="form.judges_config.A1" type="checkbox" class="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500">
                    <span class="text-sm font-medium text-gray-700">Judge A1</span>
                  </label>
                  <label class="flex items-center space-x-2 cursor-pointer p-2 rounded hover:bg-gray-100 transition">
                    <input v-model="form.judges_config.A2" type="checkbox" class="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500">
                    <span class="text-sm font-medium text-gray-700">Judge A2</span>
                  </label>
                  <label class="flex items-center space-x-2 cursor-pointer p-2 rounded hover:bg-gray-100 transition">
                    <input v-model="form.judges_config.B1" type="checkbox" class="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500">
                    <span class="text-sm font-medium text-gray-700">Judge B1</span>
                  </label>
                  <label class="flex items-center space-x-2 cursor-pointer p-2 rounded hover:bg-gray-100 transition">
                    <input v-model="form.judges_config.B2" type="checkbox" class="h-5 w-5 text-blue-600 rounded border-gray-300 focus:ring-blue-500">
                    <span class="text-sm font-medium text-gray-700">Judge B2</span>
                  </label>
                </div>
                <p class="text-xs text-gray-500 mt-2 italic">Unchecked judges will be hidden from the Head Judge panel and Scoreboard calculation.</p>
              </div>

              <!-- ACTIVE TOGGLE -->
              <div class="md:col-span-2 mt-2 bg-yellow-50 p-4 rounded border border-yellow-200">
                <label class="flex items-center space-x-3 cursor-pointer">
                  <input v-model="form.is_active" type="checkbox" class="h-5 w-5 text-green-600 rounded border-gray-300 focus:ring-green-500">
                  <span class="text-gray-900 font-bold">Set as Active Tournament</span>
                </label>
              </div>
            </div>

            <!-- TAB: DESIGN -->
            <div v-show="activeTab === 'design'" class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-bold text-gray-700 mb-1">Primary Color</label>
                  <div class="flex items-center space-x-2">
                    <input v-model="form.color_primary" type="color" class="h-10 w-20 border p-1 rounded cursor-pointer" />
                    <span class="text-sm font-mono bg-gray-100 px-2 py-1 rounded">{{ form.color_primary }}</span>
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-bold text-gray-700 mb-1">Background Color</label>
                  <div class="flex items-center space-x-2">
                    <input v-model="form.color_background" type="color" class="h-10 w-20 border p-1 rounded cursor-pointer" />
                    <span class="text-sm font-mono bg-gray-100 px-2 py-1 rounded">{{ form.color_background }}</span>
                  </div>
                </div>
              </div>

              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Tournament Logo</label>
                <div v-if="logoPreview" class="mb-3 p-2 border rounded bg-gray-50 inline-block">
                  <img :src="logoPreview" class="h-32 object-contain" />
                </div>
                <input type="file" accept="image/*" @change="handleFile" class="w-full border border-gray-300 rounded-lg p-2 text-sm file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
              </div>

              <div>
                <label class="block text-sm font-bold text-gray-700 mb-1">Page Details / Description</label>
                <textarea v-model="form.details_content" rows="6" class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none transition" placeholder="Welcome to the tournament! Here are the rules..."></textarea>
              </div>
            </div>

            <div v-if="errorMessage" class="mt-4 p-3 bg-red-50 text-red-600 border border-red-200 rounded-lg text-sm">
              {{ errorMessage }}
            </div>

            <div class="mt-8 flex justify-end space-x-3 pt-6 border-t border-gray-100">
              <button @click="cancelForm" type="button" class="px-5 py-2.5 rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 font-medium transition">Cancel</button>
              <button type="submit" class="px-6 py-2.5 rounded-lg bg-blue-600 text-white hover:bg-blue-700 font-medium shadow-md hover:shadow-lg transition">
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
const activeTab = ref('general');
const logoPreview = ref(null);

const baseUrl = import.meta.env.BASE_URL;

const form = ref({
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
  is_active: false,
  color_primary: '#1E40AF',
  color_background: '#F3F4F6',
  details_content: '',
  tournament_logo: null,
  judges_config: { A1: true, A2: true, B1: true, B2: true } // Default state
});

const fetchTournaments = async () => {
  try {
    const response = await axios.get('/tournaments');
    tournaments.value = response.data;
  } catch (error) {
    console.error('Error fetching tournaments:', error);
  }
};

const handleFile = (event) => {
  const file = event.target.files[0];
  if (file) {
    form.value.tournament_logo = file;
    logoPreview.value = URL.createObjectURL(file);
  }
};

const setActiveTournament = async (tournament) => {
  if(!confirm(`Set "${tournament.tournament_title}" as the Active Tournament? This will archive all others.`)) return;
  
  try {
    await axios.put(`/tournaments/${tournament.tournament_id}`, {
      ...tournament,
      is_active: true
    });
    await fetchTournaments();
  } catch (error) {
    alert('Failed to set active tournament');
    console.error(error);
  }
};

const handleSubmit = async () => {
  errorMessage.value = '';
  if (!form.value.tournament_title) {
    errorMessage.value = 'Title is required';
    return;
  }

  const formData = new FormData();
  
  for (const key in form.value) {
    if (key === 'judges_config') {
      // Serialize the JSON object for FormData
      formData.append(key, JSON.stringify(form.value[key]));
    } else if (form.value[key] !== null && form.value[key] !== undefined) {
      formData.append(key, form.value[key]);
    }
  }

  try {
    if (editTournamentId.value) {
      await axios.put(`/tournaments/${editTournamentId.value}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
    } else {
      await axios.post('/tournaments', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
    }
    await fetchTournaments();
    closeForm();
  } catch (error) {
    errorMessage.value = error.response?.data?.error || 'Failed to save tournament.';
  }
};

const editTournament = (t) => {
  editTournamentId.value = t.tournament_id;
  logoPreview.value = t.tournament_logo; 
  
  // Clone
  form.value = { ...t, tournament_logo: null }; 
  
  // Dates
  if (form.value.tournament_start_date) form.value.tournament_start_date = form.value.tournament_start_date.split('T')[0];
  if (form.value.tournament_end_date) form.value.tournament_end_date = form.value.tournament_end_date.split('T')[0];
  if (form.value.registration_start_date) form.value.registration_start_date = form.value.registration_start_date.split('T')[0];
  if (form.value.registration_end_date) form.value.registration_end_date = form.value.registration_end_date.split('T')[0];
  
  // Design Defaults
  if (!form.value.color_primary) form.value.color_primary = '#1E40AF';
  if (!form.value.color_background) form.value.color_background = '#F3F4F6';

  // Config Defaults (for legacy records)
  if (!form.value.judges_config) {
    form.value.judges_config = { A1: true, A2: true, B1: true, B2: true };
  }

  activeTab.value = 'general';
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
  logoPreview.value = null;
  activeTab.value = 'general';
  form.value = {
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
    is_active: false,
    color_primary: '#1E40AF',
    color_background: '#F3F4F6',
    details_content: '',
    tournament_logo: null,
    judges_config: { A1: true, A2: true, B1: true, B2: true }
  };
};

const goToAdminDashboard = () => router.push('/admin');

onMounted(fetchTournaments);
</script>