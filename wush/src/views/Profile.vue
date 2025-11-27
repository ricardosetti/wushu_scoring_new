<template>
  <div class="min-h-screen bg-gray-50 pb-12">
    <!-- Header Section -->
    <div class="bg-white shadow">
      <div class="container mx-auto px-4 py-6">
        <div class="flex flex-col md:flex-row items-center md:items-start space-y-4 md:space-y-0 md:space-x-6">
          <!-- Avatar Placeholder -->
          <div class="h-20 w-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-3xl font-bold shadow-lg">
            {{ initials }}
          </div>
          
          <div class="text-center md:text-left flex-1">
            <h1 class="text-3xl font-bold text-gray-900">{{ user.first_name }} {{ user.last_name }}</h1>
            <p class="text-gray-500">{{ user.email }}</p>
            <div class="mt-2 flex flex-wrap justify-center md:justify-start gap-2">
              <span class="px-3 py-1 bg-blue-100 text-blue-800 text-xs font-semibold rounded-full">
                Athlete
              </span>
              <!-- Show Rank from latest registration if available -->
              <span v-if="latestRank" class="px-3 py-1 bg-purple-100 text-purple-800 text-xs font-semibold rounded-full">
                {{ latestRank }}
              </span>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex space-x-3">
             <button 
               @click="$router.push('/register/member')" 
               class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded shadow font-bold transition flex items-center"
             >
               <span class="mr-2">+</span> Register for Event
             </button>
             
             <!-- NEW: Logout Button -->
             <button 
               @click="logout" 
               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded shadow font-bold transition"
             >
               Logout
             </button>
          </div>
        </div>

        <!-- Tabs -->
        <div class="mt-8 flex space-x-8 border-b border-gray-200">
          <button 
            @click="activeTab = 'competitions'"
            class="pb-4 text-sm font-medium border-b-2 transition-colors"
            :class="activeTab === 'competitions' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          >
            My Competitions
          </button>
          <button 
            @click="activeTab = 'info'"
            class="pb-4 text-sm font-medium border-b-2 transition-colors"
            :class="activeTab === 'info' ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700'"
          >
            Personal Info
          </button>
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
          <div v-for="reg in registrations" :key="reg.id" class="bg-white rounded-lg shadow-md overflow-hidden border-l-4" :class="reg.status === 1 ? 'border-green-500' : 'border-blue-500'">
            <div class="p-6">
              <div class="flex justify-between items-start">
                <div>
                  <div class="flex items-center space-x-3">
                    <h3 class="text-xl font-bold text-gray-900">{{ reg.tournament_title }}</h3>
                    <span v-if="reg.is_active" class="px-2 py-0.5 bg-red-100 text-red-800 text-xs font-bold rounded uppercase">Live Now</span>
                  </div>
                  <p class="text-gray-600 text-sm mt-1">{{ formatDate(reg.tournament_start_date) }} • {{ reg.tournament_city }}</p>
                  <p class="text-gray-500 text-sm mt-2">Registered with: <span class="font-medium text-gray-700">{{ reg.school_name }}</span></p>
                </div>
                <div class="text-right">
                  <span class="inline-block px-3 py-1 text-xs font-bold rounded-full mb-2" :class="reg.status === 1 ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'">
                    {{ reg.status === 1 ? 'Approved' : 'Pending' }}
                  </span>
                </div>
              </div>
              
              <div class="mt-6 pt-4 border-t border-gray-100 flex justify-end">
                 <button 
                   v-if="reg.status === 1 && reg.is_active"
                   @click="$router.push('/scoreboard')" 
                   class="text-blue-600 hover:text-blue-800 text-sm font-bold"
                 >
                   View Live Scores →
                 </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- TAB: PERSONAL INFO -->
      <div v-else-if="activeTab === 'info'" class="bg-white rounded-lg shadow p-6 max-w-3xl mx-auto">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-bold text-gray-900">Edit Profile</h3>
          <button v-if="!isEditing" @click="isEditing = true" class="text-blue-600 hover:underline text-sm">Edit Details</button>
        </div>

        <form @submit.prevent="saveProfile">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Identity -->
            <div><label class="block text-sm font-bold text-gray-700 mb-1">First Name</label><input v-model="form.first_name" :disabled="!isEditing" class="w-full border rounded p-2 bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Last Name</label><input v-model="form.last_name" :disabled="!isEditing" class="w-full border rounded p-2 bg-gray-50 disabled:text-gray-500" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Birthdate</label><input type="date" v-model="form.birthdate" :disabled="!isEditing" class="w-full border rounded p-2 bg-gray-50 disabled:text-gray-500" /></div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Gender</label>
              <select v-model="form.gender" :disabled="!isEditing" class="w-full border rounded p-2 bg-gray-50 disabled:text-gray-500">
                <option value="M">Male</option>
                <option value="F">Female</option>
                <option value="O">Other</option>
              </select>
            </div>

            <!-- Biometrics -->
            <div class="md:col-span-2 border-t pt-4 mt-2"><h4 class="text-gray-500 text-xs font-bold uppercase">Biometrics</h4></div>
            <div class="flex space-x-4">
              <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">Height (ft)</label><input type="number" v-model="form.height_feet" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
              <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">Height (in)</label><input type="number" v-model="form.height_inches" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
            </div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Weight (kg)</label><input type="number" step="0.1" v-model="form.weight" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>

            <!-- Contact -->
            <div class="md:col-span-2 border-t pt-4 mt-2"><h4 class="text-gray-500 text-xs font-bold uppercase">Contact Info</h4></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Phone</label><input v-model="form.phone" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">Street</label><input v-model="form.street" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
            <div><label class="block text-sm font-bold text-gray-700 mb-1">City</label><input v-model="form.city" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
            <div class="flex space-x-4">
               <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">State</label><input v-model="form.state" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
               <div class="w-1/2"><label class="block text-sm font-bold text-gray-700 mb-1">Zip</label><input v-model="form.zip_code" :disabled="!isEditing" class="w-full border rounded p-2 disabled:bg-gray-50" /></div>
            </div>
          </div>

          <div v-if="isEditing" class="mt-8 flex justify-end space-x-3">
            <button type="button" @click="cancelEdit" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
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

const initials = computed(() => {
  const f = user.value.first_name ? user.value.first_name[0] : '';
  const l = user.value.last_name ? user.value.last_name[0] : '';
  return (f + l).toUpperCase();
});

const latestRank = computed(() => {
  if (registrations.value.length > 0) {
    return registrations.value[0].participant_rank;
  }
  return null;
});

const fetchProfile = async () => {
  try {
    loading.value = true;
    const res = await axios.get('/users/profile');
    user.value = res.data.user;
    registrations.value = res.data.registrations;
    
    form.value = { ...user.value };
    if (form.value.birthdate) form.value.birthdate = form.value.birthdate.split('T')[0];
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const saveProfile = async () => {
  try {
    const res = await axios.put('/users/profile', form.value);
    user.value = res.data;
    isEditing.value = false;
    alert("Profile updated!");
  } catch (e) {
    alert("Failed to update profile");
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
  router.push('/participant-login'); // Redirect to athlete login
};

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : 'TBD';

onMounted(fetchProfile);
</script>