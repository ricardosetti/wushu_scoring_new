<template>
  <div class="min-h-screen bg-gray-50 pb-12">
    <!-- Header Section -->
    <div class="bg-white shadow">
      <div class="container mx-auto px-4 py-6">
        <div class="flex flex-col md:flex-row items-center md:items-start space-y-4 md:space-y-0 md:space-x-6">
          <div class="h-20 w-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-3xl font-bold shadow-lg">
            {{ initials }}
          </div>
          
          <div class="text-center md:text-left flex-1">
            <h1 class="text-3xl font-bold text-gray-900">{{ user.first_name }} {{ user.last_name }}</h1>
            <p class="text-gray-500">{{ user.email }}</p>
            <div class="mt-2 flex flex-wrap justify-center md:justify-start gap-2">
              <span class="px-3 py-1 bg-blue-100 text-blue-800 text-xs font-semibold rounded-full">Athlete</span>
              <span v-if="latestRank" class="px-3 py-1 bg-purple-100 text-purple-800 text-xs font-semibold rounded-full">{{ latestRank }}</span>
            </div>
          </div>

          <div class="flex space-x-3">
             <button @click="$router.push('/register/member')" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded shadow font-bold transition flex items-center">
               <span class="mr-2">+</span> Register for Event
             </button>
             <button @click="logout" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded shadow font-bold transition">Logout</button>
          </div>
        </div>

        <div class="mt-8 flex space-x-8 border-b border-gray-200">
          <button @click="activeTab = 'competitions'" class="pb-4 text-sm font-medium border-b-2 transition-colors" :class="activeTab === 'competitions' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'">My Competitions</button>
          <button @click="activeTab = 'info'" class="pb-4 text-sm font-medium border-b-2 transition-colors" :class="activeTab === 'info' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'">Personal Info</button>
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 py-8">
      <div v-if="loading" class="text-center py-12 text-gray-500">Loading profile...</div>
      
      <!-- TAB: COMPETITIONS -->
      <div v-else-if="activeTab === 'competitions'" class="space-y-6">
        <div v-if="registrations.length === 0" class="text-center py-12 bg-white rounded-lg shadow">
          <p class="text-gray-500 text-lg mb-4">You haven't registered for any tournaments yet.</p>
          <button @click="$router.push('/register/member')" class="text-blue-600 hover:underline">Find an event to join</button>
        </div>

        <div v-else class="grid grid-cols-1 gap-6">
          <div v-for="reg in registrations" :key="reg.id" class="bg-white rounded-lg shadow-md overflow-hidden border-l-4 transition hover:shadow-lg" :class="getBorderColor(reg)">
            <div class="p-6">
              <div class="flex justify-between items-start">
                <div>
                  <div class="flex items-center space-x-3">
                    <h3 class="text-xl font-bold text-gray-900">{{ reg.tournament_title }}</h3>
                    <span v-if="reg.is_active" class="px-2 py-0.5 bg-red-100 text-red-800 text-xs font-bold rounded uppercase animate-pulse">Live Now</span>
                  </div>
                  <p class="text-gray-600 text-sm mt-1">{{ formatDate(reg.tournament_start_date) }} • {{ reg.tournament_city }}</p>
                  <p class="text-gray-500 text-sm mt-2">Registered with: <span class="font-medium text-gray-700">{{ reg.school_name }}</span></p>
                </div>
                
                <div class="text-right">
                  <div v-if="reg.total_score" class="flex flex-col items-end">
                    <div class="text-4xl font-extrabold text-blue-600 leading-none">{{ reg.total_score }}</div>
                    <div class="text-[10px] text-gray-400 uppercase font-bold mt-1 tracking-wide">Final Score</div>
                    <div v-if="reg.rank" class="mt-2 px-3 py-1 bg-yellow-100 text-yellow-800 text-xs font-bold rounded-full border border-yellow-200 shadow-sm">Rank: {{ reg.rank }}</div>
                  </div>
                  <span v-else class="inline-block px-3 py-1 text-xs font-bold rounded-full mb-2" :class="reg.status === 1 ? 'bg-green-100 text-green-800 border border-green-200' : 'bg-yellow-100 text-yellow-800 border border-yellow-200'">
                    {{ reg.status === 1 ? 'Approved' : 'Pending Approval' }}
                  </span>
                </div>
              </div>
              
              <div class="mt-6 pt-4 border-t border-gray-100 flex justify-end items-center space-x-4">
                 <button v-if="reg.status === 1 && reg.is_active" @click="$router.push('/scoreboard')" class="text-blue-600 hover:text-blue-800 text-sm font-bold flex items-center transition">
                   <span class="mr-1">📺</span> View Live Board
                 </button>
                 
                 <!-- User Actions (Only if Pending) -->
                 <div v-if="reg.status === 0" class="flex space-x-3">
                   <button @click="openEditModal(reg)" class="text-gray-600 hover:text-blue-600 text-sm font-bold flex items-center transition">
                     <span class="mr-1">✏️</span> Edit
                   </button>
                   <button @click="withdraw(reg)" class="text-gray-600 hover:text-red-600 text-sm font-bold flex items-center transition">
                     <span class="mr-1">🗑️</span> Withdraw
                   </button>
                 </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- TAB: PERSONAL INFO -->
      <div v-else-if="activeTab === 'info'" class="bg-white rounded-lg shadow p-6 max-w-3xl mx-auto">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-bold text-gray-900">Edit Profile</h3>
          <button v-if="!isEditing" @click="isEditing = true" class="text-blue-600 hover:underline text-sm font-bold">Edit Details</button>
        </div>

        <form @submit.prevent="saveProfile">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div><label class="block text-sm font-bold text-gray-700 mb-1">First Name</label><input v-model="form.first_name" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Last Name</label><input v-model="form.last_name" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Birthdate</label><input type="date" v-model="form.birthdate" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Gender</label>
              <select v-model="form.gender" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500">
                <option value="M">Male</option>
                <option value="F">Female</option>
                <option value="O">Other</option>
              </select>
            </div>
            
            <div class="md:col-span-2 border-t pt-4 mt-2"><h4 class="text-gray-500 text-xs font-bold uppercase tracking-wider">Contact Info</h4></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Phone</label><input v-model="form.phone" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Street</label><input v-model="form.street" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">City</label><input v-model="form.city" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            <div class="flex space-x-4">
               <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">State</label><input v-model="form.state" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
               <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">Zip</label><input v-model="form.zip_code" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
            </div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Country</label><input v-model="form.country" :disabled="!isEditing" class="w-full border rounded p-2 bg-white disabled:bg-gray-50 disabled:text-gray-500" /></div>
          </div>

          <div v-if="isEditing" class="mt-8 flex justify-end space-x-3 pt-4 border-t">
            <button type="button" @click="cancelEdit" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded font-medium">Cancel</button>
            <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 shadow font-bold">Save Changes</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Edit Registration Modal -->
    <div v-if="showEditModal" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-lg">
        <h3 class="text-xl font-bold mb-4">Edit Registration</h3>
        <form @submit.prevent="submitEdit">
          <!-- Stats -->
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div><label class="block text-sm font-bold mb-1">Rank/Belt</label><input v-model="editForm.participant_rank" class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold mb-1">Weight (kg)</label><input v-model="editForm.weight" type="number" step="0.1" class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold mb-1">Height (ft)</label><input v-model="editForm.height_feet" type="number" class="w-full border rounded p-2" /></div>
            <div><label class="block text-sm font-bold mb-1">Height (in)</label><input v-model="editForm.height_inches" type="number" class="w-full border rounded p-2" /></div>
          </div>
          
          <!-- School -->
          <div class="mb-4">
            <label class="block text-sm font-bold mb-1">School</label>
            <select v-model="editForm.school_id" class="w-full border rounded p-2">
               <option v-for="s in availableSchools" :key="s.id" :value="s.id">{{ s.school_name }}</option>
            </select>
          </div>

          <!-- Divisions -->
          <div class="mb-6">
            <label class="block text-sm font-bold mb-2">Divisions</label>
            <div class="max-h-40 overflow-y-auto border p-2 rounded">
              <label v-for="div in availableDivisions" :key="div.id" class="flex items-center space-x-2 p-1 hover:bg-gray-50">
                <input type="checkbox" :value="div.id" v-model="editForm.divisions" />
                <span>{{ div.division_name }}</span>
              </label>
            </div>
          </div>

          <div class="flex justify-end space-x-3">
            <button type="button" @click="showEditModal = false" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
            <button type="submit" class="px-6 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 shadow">Save Changes</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref({});
const registrations = ref([]);
const loading = ref(true);
const activeTab = ref('competitions');
const isEditing = ref(false);
const form = ref({});

// Edit Modal State
const showEditModal = ref(false);
const editForm = ref({});
const availableSchools = ref([]);
const availableDivisions = ref([]);

const initials = computed(() => {
  const f = user.value.first_name ? user.value.first_name[0] : '';
  const l = user.value.last_name ? user.value.last_name[0] : '';
  return (f + l).toUpperCase();
});

const latestRank = computed(() => {
  if (registrations.value.length > 0) return registrations.value[0].participant_rank;
  return null;
});

const fetchProfile = async () => {
  try {
    loading.value = true;
    const res = await axios.get('/users/profile');
    user.value = res.data.user;
    registrations.value = res.data.registrations || [];
    
    // Fill Form
    form.value = { ...user.value };
    if (form.value.birthdate) form.value.birthdate = form.value.birthdate.split('T')[0];
  } catch (e) {
    console.error("Error fetching profile:", e);
  } finally {
    loading.value = false;
  }
};

const saveProfile = async () => {
  try {
    const res = await axios.put('/users/profile', form.value);
    user.value = res.data;
    isEditing.value = false;
    alert("Profile updated successfully!");
  } catch (e) {
    console.error(e);
    alert("Failed to update profile.");
  }
};

// --- Withdraw Logic ---
const withdraw = async (reg) => {
  if(!confirm(`Are you sure you want to withdraw from ${reg.tournament_title}? This action cannot be undone.`)) return;
  try {
    await axios.delete(`/registrations/${reg.id}/withdraw`);
    registrations.value = registrations.value.filter(r => r.id !== reg.id);
    alert("Registration withdrawn.");
  } catch (e) {
    alert("Failed to withdraw: " + (e.response?.data?.error || e.message));
  }
};

// --- Edit Logic ---
const openEditModal = async (reg) => {
  // Load context for that tournament
  try {
    const [schoolRes, divRes] = await Promise.all([
      axios.get('/schools/public', { params: { tournament_id: reg.tournament_id } }),
      axios.get('/divisions', { params: { tournament_id: reg.tournament_id } }),
      // Also get current divisions for this registration
      axios.get(`/registrations/${reg.id}/divisions`)
    ]);
    
    availableSchools.value = schoolRes.data;
    availableDivisions.value = divRes.data;
    
    const currentDivIds = divRes.value ? divRes.value.map(d => d.id) : []; // This logic needs fix in next step really
    // Actually we need to fetch the *assigned* divisions.
    // The endpoint `/registrations/:id/divisions` returns array of divisions.
    const assignedDivs = (await axios.get(`/registrations/${reg.id}/divisions`)).data;

    editForm.value = {
      id: reg.id,
      tournament_id: reg.tournament_id,
      participant_rank: reg.participant_rank,
      weight: reg.weight,
      height_feet: reg.height_feet,
      height_inches: reg.height_inches,
      school_id: reg.school_id,
      divisions: assignedDivs.map(d => d.id)
    };

    showEditModal.value = true;
  } catch (e) {
    console.error(e);
    alert("Error loading event details for editing.");
  }
};

const submitEdit = async () => {
  try {
    await axios.put(`/registrations/${editForm.value.id}/edit`, editForm.value);
    showEditModal.value = false;
    alert("Registration updated!");
    fetchProfile(); // Reload to show changes
  } catch (e) {
    alert("Failed to update: " + (e.response?.data?.error || e.message));
  }
};

const cancelEdit = () => {
  isEditing.value = false;
  form.value = { ...user.value };
  if (form.value.birthdate) form.value.birthdate = form.value.birthdate.split('T')[0];
};

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/participant-login'); 
};

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : 'TBD';

const getBorderColor = (reg) => {
  if (reg.total_score) return 'border-blue-600'; 
  if (reg.status === 1) return 'border-green-500'; 
  return 'border-yellow-400'; 
};

onMounted(fetchProfile);
</script>