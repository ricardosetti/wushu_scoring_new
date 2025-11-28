<template>
  <div class="container mx-auto p-4">
    <h2 class="text-2xl font-bold mb-6 text-gray-800">Registration Management</h2>

    <div class="flex space-x-4 mb-6 border-b pb-4">
      <button 
        @click="filterStatus = 0" 
        class="px-4 py-2 rounded font-medium transition relative"
        :class="filterStatus === 0 ? 'text-blue-600 bg-blue-50' : 'text-gray-500 hover:text-gray-700'"
      >
        Pending Approval
        <span v-if="pendingCount > 0" class="ml-2 bg-red-500 text-white text-xs px-2 py-0.5 rounded-full">{{ pendingCount }}</span>
      </button>
      <button 
        @click="filterStatus = 1" 
        class="px-4 py-2 rounded font-medium transition"
        :class="filterStatus === 1 ? 'text-green-600 bg-green-50' : 'text-gray-500 hover:text-gray-700'"
      >
        Approved Roster
      </button>
    </div>

    <div v-if="loading" class="text-center text-gray-500 py-8">Loading registrations...</div>
    <div v-else-if="error" class="text-center text-red-500 py-4">{{ error }}</div>

    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Tournament</th> <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Name</th>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">School</th>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Divisions</th>
            <th class="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="reg in filteredRegistrations" :key="reg.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs font-semibold rounded-full bg-indigo-100 text-indigo-800">
                {{ reg.tournament_title || 'Unknown' }}
              </span>
            </td>
            
            <td class="px-6 py-4">
              <div class="font-bold text-gray-900">{{ reg.first_name }} {{ reg.last_name }}</div>
              <div class="text-xs text-gray-500">{{ reg.email }}</div>
              <div class="text-xs text-gray-400 mt-1">{{ reg.participant_rank || 'No Rank' }}</div>
            </td>
            
            <td class="px-6 py-4 text-sm text-gray-700">
              {{ reg.school_name || 'Unknown School' }}
            </td>
            
            <td class="px-6 py-4 text-sm text-gray-700">
              <div v-if="reg.divisions && reg.divisions.length">
                <span v-for="div in reg.divisions" :key="div.id" class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded mr-1 mb-1">
                  {{ div.division_name }}
                </span>
              </div>
              <span v-else class="text-red-400 text-xs italic">No Divisions Selected</span>
            </td>
            
            <td class="px-6 py-4 text-right">
              <button 
                v-if="reg.status === 0"
                @click="approveRegistration(reg)" 
                class="bg-green-600 hover:bg-green-700 text-white text-xs font-bold py-2 px-4 rounded shadow transition"
              >
                Approve
              </button>
              <span v-else class="text-green-600 font-bold text-xs border border-green-600 px-2 py-1 rounded">
                ✓ On Roster
              </span>
            </td>
          </tr>
          <tr v-if="filteredRegistrations.length === 0">
            <td colspan="5" class="px-6 py-8 text-center text-gray-500">
              No registrations found in this category.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <div class="mt-6">
      <button @click="$router.push('/admin')" class="text-gray-600 hover:text-gray-900 font-medium flex items-center">
        <span>←</span> <span class="ml-2">Back to Dashboard</span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from '../axios';

const registrations = ref([]);
const loading = ref(true);
const error = ref('');
const filterStatus = ref(0); // 0 = Pending, 1 = Approved

// Filter list based on tab selection
const filteredRegistrations = computed(() => {
  return registrations.value.filter(r => r.status === filterStatus.value);
});

const pendingCount = computed(() => {
  return registrations.value.filter(r => r.status === 0).length;
});

const fetchData = async () => {
  try {
    loading.value = true;
    // We don't need to fetch schools separately anymore because 
    // the backend joins the school name for us now.
    const regRes = await axios.get('/registrations');
    registrations.value = regRes.data;
  } catch (err) {
    error.value = "Failed to load data.";
    console.error(err);
  } finally {
    loading.value = false;
  }
};

const approveRegistration = async (reg) => {
  if (!confirm(`Approve ${reg.first_name} ${reg.last_name}? This will add them to the official Participant Roster.`)) return;

  try {
    await axios.post(`/registrations/${reg.id}/approve`);
    // Optimistic update
    reg.status = 1; 
    alert("Participant approved and added to scoreboard!");
  } catch (err) {
    alert("Error approving registration: " + (err.response?.data?.error || err.message));
  }
};

onMounted(fetchData);
</script>