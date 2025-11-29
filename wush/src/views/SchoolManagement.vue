<template>
  <div class="container mx-auto p-4">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-darkgray">School Management</h1>
      <button 
        @click="openAddForm" 
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded shadow transition"
      >
        + Add School
      </button>
    </div>

    <!-- Info Banner -->
    <div class="bg-blue-50 border-l-4 border-blue-500 p-4 mb-6 shadow-sm">
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <p class="text-sm text-blue-700">
            <strong>Tournament Filter:</strong> Use the checkbox on each card to Enable/Disable a school for the <span class="font-bold underline">Active Tournament</span>. Only enabled schools can use their QR codes.
          </p>
        </div>
      </div>
    </div>

    <!-- Schools Grid -->
    <div v-if="schools.length" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div 
        v-for="school in schools" 
        :key="school.id" 
        class="bg-white rounded-lg shadow-md p-5 flex flex-col justify-between transition-all duration-200 border-2"
        :class="school.is_active_in_tournament ? 'border-green-500 opacity-100' : 'border-gray-100 opacity-75 bg-gray-50'"
      >
        <div>
          <!-- Header: Logo + Toggle -->
          <div class="flex justify-between items-start mb-4">
            <div class="flex items-center space-x-3">
              <img 
                v-if="school.school_logo" 
                :src="school.school_logo" 
                alt="Logo" 
                class="h-12 w-12 rounded-full object-cover border border-gray-200"
              />
              <div v-else class="h-12 w-12 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 font-bold text-xl border border-gray-300">
                {{ school.school_name.charAt(0) }}
              </div>
            </div>
            
            <!-- ACTIVE TOGGLE SWITCH -->
            <div class="flex flex-col items-end">
              <label class="inline-flex items-center cursor-pointer">
                <input 
                  type="checkbox" 
                  class="form-checkbox h-6 w-6 text-green-600 rounded focus:ring-green-500 border-gray-300 transition duration-150 ease-in-out"
                  :checked="school.is_active_in_tournament"
                  @change="toggleStatus(school, $event.target.checked)"
                >
              </label>
              <span class="text-[10px] font-bold uppercase mt-1" :class="school.is_active_in_tournament ? 'text-green-600' : 'text-gray-400'">
                {{ school.is_active_in_tournament ? 'Active' : 'Inactive' }}
              </span>
            </div>
          </div>

          <!-- School Details -->
          <div>
            <h2 class="text-xl font-bold text-gray-900 leading-tight mb-1">{{ school.school_name }}</h2>
            <p class="text-sm text-gray-500 font-medium">{{ school.school_contact || 'No Contact Info' }}</p>
            
            <div class="mt-3 space-y-1">
              <p class="text-sm text-gray-600 flex items-center">
                <span class="w-4 h-4 mr-2 text-gray-400">📞</span> {{ school.school_phone || 'N/A' }}
              </p>
              <p class="text-sm text-gray-600 flex items-center truncate" title="Address">
                <span class="w-4 h-4 mr-2 text-gray-400">📍</span> {{ school.school_address || 'N/A' }}
              </p>
            </div>
          </div>
        </div>

        <!-- Actions Footer -->
        <div class="flex justify-between items-center pt-4 border-t border-gray-100 mt-4">
          <div class="flex space-x-3">
            <button @click="editSchool(school)" class="text-gray-600 hover:text-blue-600 text-sm font-medium transition">Edit</button>
            <button @click="deleteSchool(school.id)" class="text-gray-400 hover:text-red-600 text-sm font-medium transition">Delete</button>
          </div>
          
          <!-- INVITE BUTTON (Only visible if active) -->
          <button 
            v-if="school.is_active_in_tournament"
            @click="openInviteModal(school)" 
            class="flex items-center space-x-1 bg-blue-50 text-blue-700 border border-blue-200 px-3 py-1.5 rounded-full text-sm font-medium hover:bg-blue-100 hover:border-blue-300 transition shadow-sm"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            <span>Invite</span>
          </button>
          <span v-else class="text-xs text-gray-400 italic py-1.5 px-2">Disabled for Event</span>
        </div>
      </div>
    </div>
    
    <div v-else class="text-center py-12 bg-white rounded-lg shadow">
      <p class="text-gray-500 text-lg">No schools found.</p>
      <button @click="openAddForm" class="mt-2 text-blue-600 hover:underline">Create your first school</button>
    </div>

    <!-- ================= MODALS ================= -->

    <!-- Invite Modal -->
    <div v-if="showInviteModal" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6 text-center transform transition-all scale-100">
        <h3 class="text-xl font-bold text-gray-900 mb-1">Registration Invite</h3>
        <p class="text-gray-500 mb-6 text-sm">Scan to register students for <br><span class="font-bold text-gray-800">{{ currentSchool.school_name }}</span></p>
        
        <!-- QR Code Display -->
        <div class="flex justify-center mb-4">
          <div v-if="currentSchool.registration_qr_code" class="border-4 border-white shadow-lg rounded-lg p-2 bg-white">
            <img :src="currentSchool.registration_qr_code" alt="School QR Code" class="w-48 h-48" />
          </div>
          <div v-else class="w-48 h-48 bg-gray-100 flex items-center justify-center rounded text-gray-400 animate-pulse">
            Generating...
          </div>
        </div>

        <!-- REGENERATE BUTTON -->
        <button 
          @click="regenerateLink"
          class="text-blue-600 hover:text-blue-800 text-xs font-bold mb-6 flex items-center justify-center mx-auto hover:underline"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Regenerate New Link
        </button>
        
        <div class="bg-gray-50 p-3 rounded-lg mb-6 text-left border border-gray-200">
          <label class="text-xs text-gray-500 font-bold uppercase tracking-wide mb-1 block">Direct Link</label>
          <div class="flex">
            <input readonly :value="currentSchool.registration_link" class="text-sm bg-white border border-gray-300 rounded-l p-2 w-full text-gray-700 truncate focus:outline-none" />
            <button @click="copyLink" class="bg-blue-600 text-white px-3 rounded-r text-sm font-bold hover:bg-blue-700">Copy</button>
          </div>
        </div>
        
        <button @click="showInviteModal = false" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-8 rounded-lg transition">Close</button>
      </div>
    </div>

    <!-- Add/Edit School Modal -->
    <div v-if="showAddForm" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex items-center justify-center z-50 backdrop-blur-sm">
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6">
        <div class="flex justify-between items-center mb-4 border-b pb-2">
          <h3 class="text-xl font-bold text-gray-800">{{ editSchoolId ? 'Edit School' : 'Add New School' }}</h3>
          <button @click="cancelForm" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
        </div>
        
        <form @submit.prevent="handleSubmit">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">School Name *</label>
              <input v-model="newSchool.school_name" required class="w-full border border-gray-300 rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Contact Person</label>
              <input v-model="newSchool.school_contact" class="w-full border border-gray-300 rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Phone</label>
              <input v-model="newSchool.school_phone" class="w-full border border-gray-300 rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none" />
            </div>
            <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Address</label>
              <textarea v-model="newSchool.school_address" rows="3" class="w-full border border-gray-300 rounded-lg p-2 focus:ring-2 focus:ring-blue-500 outline-none"></textarea>
            </div>
            <!-- Logo Input (Optional) -->
             <div>
              <label class="block text-sm font-bold text-gray-700 mb-1">Logo (JPG)</label>
              <input type="file" accept="image/jpeg" @change="handleLogoUpload" class="w-full border border-gray-300 rounded-lg p-2 text-sm" />
            </div>
          </div>
          
          <div class="mt-6 flex justify-end space-x-3 pt-4 border-t">
            <button type="button" @click="cancelForm" class="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium">Cancel</button>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium shadow">{{ editSchoolId ? 'Save Changes' : 'Create School' }}</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';

const schools = ref([]);
const showAddForm = ref(false);
const showInviteModal = ref(false);
const currentSchool = ref({});
const editSchoolId = ref(null);

const newSchool = ref({
  school_name: '',
  school_address: '',
  school_contact: '',
  school_phone: '',
  school_logo: null
});

// Fetch schools from backend (Backend now returns is_active_in_tournament flag)
const fetchSchools = async () => {
  try {
    const response = await axios.get('/schools');
    schools.value = response.data;
  } catch (error) {
    console.error('Error fetching schools:', error);
  }
};

// Handle the checkbox toggle
const toggleStatus = async (school, isChecked) => {
  // 1. Optimistic UI Update (make it feel fast)
  const originalState = school.is_active_in_tournament;
  school.is_active_in_tournament = isChecked;

  try {
    // 2. Call Backend
    await axios.post(`/schools/${school.id}/toggle-status`, { is_enabled: isChecked });
  } catch (error) {
    // 3. Revert on Error
    alert("Failed to update school status.");
    school.is_active_in_tournament = originalState;
  }
};

// --- Invite Logic ---

const openInviteModal = async (school) => {
  currentSchool.value = school;
  showInviteModal.value = true;
  // Auto generate only if missing. Otherwise show existing.
  if (!school.registration_qr_code || !school.registration_link) {
    await callGenerateToken(school);
  }
};

// NEW: Explicitly Regenerate Token (Fixes broken links or rotates security)
const regenerateLink = async () => {
  if(!confirm("Warning: This will invalidate any previously shared links for this school. Generate new link?")) return;
  await callGenerateToken(currentSchool.value);
};

const callGenerateToken = async (school) => {
  try {
    const response = await axios.post(`/schools/${school.id}/generate-token`);
    // Update local data with response
    const updatedSchool = { ...school, ...response.data };
    
    // Update List
    const index = schools.value.findIndex(s => s.id === school.id);
    if (index !== -1) schools.value[index] = updatedSchool;
    
    // Update Modal
    currentSchool.value = updatedSchool;
  } catch (error) {
    console.error("Failed to generate token", error);
    alert("Error generating link");
  }
};

const copyLink = () => {
  if (currentSchool.value.registration_link) {
    navigator.clipboard.writeText(currentSchool.value.registration_link);
    alert("Link copied to clipboard!");
  }
};

const handleLogoUpload = (event) => {
  const file = event.target.files[0];
  if (file) newSchool.value.school_logo = file;
};

const openAddForm = () => {
  editSchoolId.value = null;
  newSchool.value = { school_name: '', school_address: '', school_contact: '', school_phone: '', school_logo: null };
  showAddForm.value = true;
};

const editSchool = (school) => {
  editSchoolId.value = school.id;
  newSchool.value = { ...school, school_logo: null }; // Reset file input
  showAddForm.value = true;
};

const cancelForm = () => {
  showAddForm.value = false;
};

const handleSubmit = async () => {
  const formData = new FormData();
  formData.append('school_name', newSchool.value.school_name);
  formData.append('school_address', newSchool.value.school_address || '');
  formData.append('school_contact', newSchool.value.school_contact || '');
  formData.append('school_phone', newSchool.value.school_phone || '');
  if (newSchool.value.school_logo) {
    formData.append('school_logo', newSchool.value.school_logo);
  }

  try {
    if (editSchoolId.value) {
      await axios.put(`/schools/${editSchoolId.value}`, formData, { headers: { 'Content-Type': 'multipart/form-data' } });
    } else {
      await axios.post('/schools', formData, { headers: { 'Content-Type': 'multipart/form-data' } });
    }
    await fetchSchools();
    showAddForm.value = false;
  } catch (error) {
    alert("Error saving school");
    console.error(error);
  }
};

const deleteSchool = async (id) => {
  if(confirm("Are you sure? This deletes the school permanently.")) {
    try {
      await axios.delete(`/schools/${id}`);
      fetchSchools();
    } catch (e) { alert("Error deleting school"); }
  }
};

onMounted(fetchSchools);
</script>