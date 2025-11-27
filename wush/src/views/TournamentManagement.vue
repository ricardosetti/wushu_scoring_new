<template>
  <div class="container mx-auto p-4">
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-2xl font-bold text-gray-800">Tournament Management</h2>
      <button @click="openAddForm" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded shadow font-semibold">+ New Tournament</button>
    </div>

    <div class="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
      <div v-if="tournaments.length">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
             <tr>
              <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Status</th>
              <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Details</th>
              <th class="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase">Public Page</th>
              <th class="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase">Actions</th>
             </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="t in tournaments" :key="t.tournament_id" :class="t.is_active ? 'bg-green-50' : 'hover:bg-gray-50'">
              <td class="px-6 py-4">
                <span v-if="t.is_active" class="px-3 py-1 text-xs font-bold rounded-full bg-green-100 text-green-800 border border-green-200">ACTIVE</span>
                <button v-else @click="setActiveTournament(t)" class="text-xs bg-white border border-gray-300 px-3 py-1 rounded-full hover:bg-blue-50 hover:text-blue-600">Set Active</button>
              </td>
              <td class="px-6 py-4">
                <div class="text-lg font-bold text-gray-900">{{ t.tournament_title }}</div>
                <div class="text-xs text-gray-500">{{ formatDate(t.tournament_start_date) }}</div>
              </td>
              <td class="px-6 py-4 text-right">
                <a :href="`/t/${t.tournament_id}`" target="_blank" class="text-blue-600 hover:underline text-sm">View Page ↗</a>
              </td>
              <td class="px-6 py-4 text-right text-sm font-medium">
                <button @click="editTournament(t)" class="text-indigo-600 hover:text-indigo-900 mr-4">Edit</button>
                <button v-if="!t.is_active" @click="deleteTournament(t.tournament_id)" class="text-red-500 hover:text-red-700">Delete</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="p-10 text-center text-gray-500">No tournaments found.</div>
    </div>

    <div v-if="showAddForm" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
          <h3 class="text-xl font-bold text-gray-800">{{ editTournamentId ? 'Edit Tournament' : 'New Tournament' }}</h3>
          <button @click="cancelForm" class="text-gray-400 hover:text-gray-600 text-3xl leading-none">&times;</button>
        </div>
        
        <div class="p-6">
          <div class="flex border-b mb-6">
            <button @click="activeTab = 'general'" class="px-4 py-2 font-medium" :class="activeTab === 'general' ? 'border-b-2 border-blue-500 text-blue-600' : 'text-gray-500'">General Info</button>
            <button @click="activeTab = 'design'" class="px-4 py-2 font-medium" :class="activeTab === 'design' ? 'border-b-2 border-blue-500 text-blue-600' : 'text-gray-500'">Page Design</button>
          </div>

          <form @submit.prevent="handleSubmit">
            <div v-show="activeTab === 'general'" class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="md:col-span-2">
                <label class="block text-sm font-bold text-gray-700 mb-1">Title *</label>
                <input v-model="form.tournament_title" required class="w-full border rounded-lg p-2.5" />
              </div>
              <div><label class="block text-sm font-bold mb-1">Start Date</label><input v-model="form.tournament_start_date" type="date" class="w-full border rounded-lg p-2.5" /></div>
              <div><label class="block text-sm font-bold mb-1">End Date</label><input v-model="form.tournament_end_date" type="date" class="w-full border rounded-lg p-2.5" /></div>
              <div class="md:col-span-2"><label class="block text-sm font-bold mb-1">Address</label><input v-model="form.tournament_address" class="w-full border rounded-lg p-2.5" /></div>
              <div><label class="block text-sm font-bold mb-1">City</label><input v-model="form.tournament_city" class="w-full border rounded-lg p-2.5" /></div>
              <div><label class="block text-sm font-bold mb-1">State</label><input v-model="form.tournament_state" class="w-full border rounded-lg p-2.5" /></div>
              <div class="md:col-span-2 mt-2 bg-yellow-50 p-3 rounded border border-yellow-200">
                <label class="flex items-center space-x-3"><input v-model="form.is_active" type="checkbox" class="h-5 w-5"><span class="font-bold">Set Active</span></label>
              </div>
            </div>

            <div v-show="activeTab === 'design'" class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-bold mb-1">Primary Color (Buttons/Headers)</label>
                  <div class="flex items-center space-x-2">
                    <input v-model="form.color_primary" type="color" class="h-10 w-20 border p-1 rounded" />
                    <span class="text-sm">{{ form.color_primary }}</span>
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-bold mb-1">Background Color</label>
                  <div class="flex items-center space-x-2">
                    <input v-model="form.color_background" type="color" class="h-10 w-20 border p-1 rounded" />
                    <span class="text-sm">{{ form.color_background }}</span>
                  </div>
                </div>
              </div>

              <div>
                <label class="block text-sm font-bold mb-1">Tournament Logo</label>
                <div v-if="logoPreview" class="mb-2"><img :src="logoPreview" class="h-24 object-contain border p-1 bg-gray-100 rounded" /></div>
                <input type="file" accept="image/*" @change="handleFile" class="w-full border p-2 rounded" />
              </div>

              <div>
                <label class="block text-sm font-bold mb-1">Description / Details</label>
                <textarea v-model="form.details_content" rows="5" class="w-full border rounded-lg p-2.5" placeholder="Welcome message, rules, etc..."></textarea>
              </div>
            </div>

            <div class="mt-8 flex justify-end space-x-3 pt-6 border-t">
              <button @click="cancelForm" type="button" class="px-5 py-2.5 border rounded-lg hover:bg-gray-50">Cancel</button>
              <button type="submit" class="px-6 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 shadow">Save</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';

const tournaments = ref([]);
const showAddForm = ref(false);
const editTournamentId = ref(null);
const activeTab = ref('general');
const logoPreview = ref(null);

const form = ref({
  tournament_title: '', tournament_start_date: '', tournament_end_date: '',
  tournament_address: '', tournament_city: '', tournament_state: '',
  color_primary: '#1E40AF', color_background: '#F3F4F6', details_content: '',
  is_active: false, tournament_logo: null
});

const fetchTournaments = async () => {
  try {
    const res = await axios.get('/tournaments');
    tournaments.value = res.data;
  } catch (e) { console.error(e); }
};

const handleFile = (e) => {
  const file = e.target.files[0];
  if (file) {
    form.value.tournament_logo = file;
    logoPreview.value = URL.createObjectURL(file);
  }
};

const openAddForm = () => {
  editTournamentId.value = null;
  logoPreview.value = null;
  form.value = { tournament_title: '', color_primary: '#1E40AF', color_background: '#F3F4F6', is_active: false };
  activeTab.value = 'general';
  showAddForm.value = true;
};

const editTournament = (t) => {
  editTournamentId.value = t.tournament_id;
  logoPreview.value = t.tournament_logo;
  form.value = { ...t, tournament_logo: null }; // Reset file input, keep preview
  if(form.value.tournament_start_date) form.value.tournament_start_date = form.value.tournament_start_date.split('T')[0];
  if(form.value.tournament_end_date) form.value.tournament_end_date = form.value.tournament_end_date.split('T')[0];
  activeTab.value = 'general';
  showAddForm.value = true;
};

const handleSubmit = async () => {
  const formData = new FormData();
  for (const key in form.value) {
    if (form.value[key] !== null && form.value[key] !== undefined) {
      formData.append(key, form.value[key]);
    }
  }

  try {
    if (editTournamentId.value) {
      await axios.put(`/tournaments/${editTournamentId.value}`, formData, { headers: { 'Content-Type': 'multipart/form-data' } });
    } else {
      await axios.post('/tournaments', formData, { headers: { 'Content-Type': 'multipart/form-data' } });
    }
    await fetchTournaments();
    showAddForm.value = false;
  } catch (e) { alert("Error saving"); }
};

const cancelForm = () => showAddForm.value = false;
const formatDate = (d) => d ? new Date(d).toLocaleDateString() : 'TBD';
const setActiveTournament = async (t) => {
    if(confirm("Set Active?")) {
        await axios.put(`/tournaments/${t.tournament_id}`, { ...t, is_active: true });
        fetchTournaments();
    }
}

onMounted(fetchTournaments);
</script>