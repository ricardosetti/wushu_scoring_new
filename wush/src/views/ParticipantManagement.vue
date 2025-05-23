<template>
  <div class="container mx-auto p-4">
    <h2 class="text-xl font-bold mb-4">Participant Management</h2>
    <button
      @click="openAddForm"
      class="bg-green-500 text-white px-4 py-2 rounded mb-4 hover:bg-green-600 mr-2"
    >
      Add New Participant
    </button>

    <!-- Modal for Add/Edit Participant -->
    <div v-if="showAddForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <h3 class="text-lg font-bold mb-4">{{ editParticipantId ? 'Edit Participant' : 'Add Participant' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="mb-2">
              <label class="block">First Name *</label>
              <input v-model="newParticipant.first_name" required class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Middle Name</label>
              <input v-model="newParticipant.middle_name" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Last Name *</label>
              <input v-model="newParticipant.last_name" required class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">School *</label>
              <select v-model="newParticipant.school_id" required class="border p-2 w-full rounded">
                <option :value="null" disabled>Select a School</option>
                <option v-for="school in schools" :key="school.id" :value="school.id">
                  {{ school.school_name }}
                </option>
              </select>
              <div v-if="errorMessage && !newParticipant.school_id" class="text-red-500 text-sm mt-1">
                School is required.
              </div>
            </div>
            <div class="mb-2">
              <label class="block">Rank</label>
              <input v-model="newParticipant.participant_rank" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Birthdate *</label>
              <input v-model="newParticipant.birthdate" type="date" required class="border p-2 w-full rounded" />
              <div v-if="errorMessage && !newParticipant.birthdate" class="text-red-500 text-sm mt-1">
                Birthdate is required.
              </div>
            </div>
            <div class="mb-2">
              <label class="block">Height (Feet)</label>
              <input v-model.number="newParticipant.height_feet" type="number" min="0" max="8" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Height (Inches)</label>
              <input v-model.number="newParticipant.height_inches" type="number" min="0" max="11" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Weight (kg)</label>
              <input v-model.number="newParticipant.weight" type="number" step="0.01" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Gender *</label>
              <select v-model="newParticipant.gender" required class="border p-2 w-full rounded">
                <option :value="null" disabled>Select Gender</option>
                <option value="M">Male</option>
                <option value="F">Female</option>
                <option value="O">Other</option>
              </select>
              <div v-if="errorMessage && !newParticipant.gender" class="text-red-500 text-sm mt-1">
                Gender is required.
              </div>
            </div>
            <div class="mb-2">
              <label class="block">Phone</label>
              <input v-model="newParticipant.phone" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Emergency Contact Name</label>
              <input v-model="newParticipant.emergency_contact_name" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Emergency Contact Phone</label>
              <input v-model="newParticipant.emergency_contact_phone" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2 col-span-2">
              <label class="block">Street</label>
              <input v-model="newParticipant.street" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">City</label>
              <input v-model="newParticipant.city" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">State</label>
              <input v-model="newParticipant.state" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">Country</label>
              <input v-model="newParticipant.country" class="border p-2 w-full rounded" />
            </div>
            <div class="mb-2">
              <label class="block">ZIP Code</label>
              <input v-model="newParticipant.zip_code" class="border p-2 w-full rounded" />
            </div>
          </div>
          <div class="mt-4 flex justify-end">
            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              {{ editParticipantId ? 'Update' : 'Save' }}
            </button>
            <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
              Cancel
            </button>
          </div>
          <div v-if="errorMessage" class="mt-2 text-red-500">{{ errorMessage }}</div>
        </form>
      </div>
    </div>

    <!-- Participant List -->
    <div v-if="participants.length">
      <h3 class="text-lg font-bold mb-2">Participants</h3>
      <div v-for="participant in participants" :key="participant.id" class="border p-2 mb-2 flex justify-between items-center">
        <span>
          {{ participant.first_name }} {{ participant.middle_name || '' }} {{ participant.last_name }}
          ({{ participant.divisions?.length ? participant.divisions.map(div => div.division_name).join(', ') : 'No Divisions' }},
          {{ participant.school_name || 'No School' }})
        </span>
        <div>
          <button @click="editParticipant(participant)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">
            Edit
          </button>
          <button @click="manageDivisions(participant)" class="bg-purple-500 text-white px-2 py-1 rounded mr-2 hover:bg-purple-600">
            Manage Divisions
          </button>
          <button @click="deleteParticipant(participant.id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
            Delete
          </button>
        </div>
      </div>
    </div>
    <div v-else>
      <p>No participants found.</p>
    </div>

    <!-- Modal for Managing Divisions -->
    <div v-if="showDivisionForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg max-w-lg w-full">
        <h3 class="text-lg font-bold mb-4">Manage Divisions for {{ selectedParticipant?.first_name }} {{ selectedParticipant?.last_name }}</h3>
        <div class="mb-4">
          <label class="block mb-2">Select Division to Add</label>
          <select v-model="selectedDivisionId" class="border p-2 w-full rounded">
            <option value="">Select a Division</option>
            <option v-for="division in availableDivisions" :key="division.id" :value="division.id">
              {{ division.division_name }}
            </option>
          </select>
          <button
            @click="addDivisionToParticipant"
            :disabled="!selectedDivisionId"
            class="mt-2 bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 disabled:bg-gray-400"
          >
            Add Division
          </button>
        </div>
        <div class="mb-4">
          <h4 class="font-bold mb-2">Current Divisions</h4>
          <div v-if="participantDivisions.length">
            <div v-for="division in participantDivisions" :key="division.id" class="flex justify-between items-center mb-2">
              <span>{{ division.division_name }}</span>
              <button
                @click="removeDivisionFromParticipant(division.id)"
                class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600"
              >
                Remove
              </button>
            </div>
          </div>
          <div v-else>
            <p>No divisions assigned.</p>
          </div>
        </div>
        <div class="flex justify-end">
          <button @click="closeDivisionForm" class="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
            Close
          </button>
        </div>
      </div>
    </div>

    <!-- Logout Button -->
    <button
      @click="logout"
      class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 mt-4"
    >
      Logout
    </button>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const participants = ref([]);
const schools = ref([]);
const showAddForm = ref(false);
const newParticipant = ref({
  first_name: '',
  middle_name: '',
  last_name: '',
  school_id: null,
  birthdate: '',
  height_feet: null,
  height_inches: null,
  weight: null,
  gender: null,
  phone: '',
  emergency_contact_name: '',
  emergency_contact_phone: '',
  street: '',
  city: '',
  state: '',
  country: '',
  zip_code: '',
  participant_rank: '',
});
const editParticipantId = ref(null);
const errorMessage = ref('');
const showDivisionForm = ref(false);
const selectedParticipant = ref(null);
const participantDivisions = ref([]);
const allDivisions = ref([]);
const selectedDivisionId = ref('');

const availableDivisions = computed(() => {
  const currentDivisionIds = participantDivisions.value.map(div => div.id);
  return allDivisions.value.filter(div => !currentDivisionIds.includes(div.id));
});

const fetchParticipants = async () => {
  try {
    console.log('Fetching participants...');
    const response = await axios.get('/participants');
    console.log('Participants response:', response.data);
    const transformedParticipants = response.data.map(participant => ({
      ...participant,
      birthdate: participant.birthdate ? participant.birthdate.split('T')[0] : '',
    }));
    participants.value = transformedParticipants.sort((a, b) => {
      const lastNameA = a.last_name || '';
      const lastNameB = b.last_name || '';
      const firstNameA = a.first_name || '';
      const firstNameB = b.first_name || '';
      return lastNameA.localeCompare(lastNameB) || firstNameA.localeCompare(firstNameB);
    });
  } catch (error) {
    console.error('Error fetching participants:', error.response ? error.response.data : error.message);
    participants.value = [];
  }
};

const fetchSchools = async () => {
  try {
    console.log('Fetching schools...');
    const response = await axios.get('/schools');
    console.log('Schools response:', response.data);
    schools.value = response.data;
  } catch (error) {
    console.error('Error fetching schools:', error.response ? error.response.data : error.message);
    schools.value = [];
  }
};

const fetchAllDivisions = async () => {
  try {
    console.log('Fetching all divisions...');
    const response = await axios.get('/divisions');
    console.log('All divisions response:', response.data);
    allDivisions.value = response.data;
  } catch (error) {
    console.error('Error fetching divisions:', error.response ? error.response.data : error.message);
    allDivisions.value = [];
  }
};

const handleSubmit = () => {
  errorMessage.value = '';
  if (!newParticipant.value.first_name || !newParticipant.value.last_name) {
    errorMessage.value = 'First name and last name are required.';
    return;
  }
  if (!newParticipant.value.school_id) {
    errorMessage.value = 'School is required.';
    return;
  }
  if (!newParticipant.value.birthdate) {
    errorMessage.value = 'Birthdate is required.';
    return;
  }
  if (!newParticipant.value.gender) {
    errorMessage.value = 'Gender is required.';
    return;
  }
  console.log('Submitting form, editParticipantId:', editParticipantId.value, 'Data:', newParticipant.value);
  if (editParticipantId.value) {
    updateParticipant();
  } else {
    addParticipant();
  }
};

const addParticipant = async () => {
  console.log('Adding new participant, Data:', newParticipant.value);
  try {
    const response = await axios.post('/participants', newParticipant.value);
    console.log('Add response:', response.data);
    participants.value.push({
      ...response.data,
      birthdate: response.data.birthdate ? response.data.birthdate.split('T')[0] : '',
      divisions: [], // New participant starts with no divisions
    });
    participants.value.sort((a, b) => {
      const lastNameA = a.last_name || '';
      const lastNameB = b.last_name || '';
      const firstNameA = a.first_name || '';
      const firstNameB = b.first_name || '';
      return lastNameA.localeCompare(lastNameB) || firstNameA.localeCompare(firstNameB);
    });
    showAddForm.value = false;
  } catch (error) {
    console.error('Error adding participant:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to add participant. Please try again.';
  }
};

const editParticipant = (participant) => {
  editParticipantId.value = participant.id;
  newParticipant.value = { ...participant };
  if (newParticipant.value.birthdate instanceof Date) {
    newParticipant.value.birthdate = newParticipant.value.birthdate.toISOString().split('T')[0];
  }
  delete newParticipant.value.divisions;
  delete newParticipant.value.school_name;
  showAddForm.value = true;
};

const updateParticipant = async () => {
  console.log('Updating participant with id:', editParticipantId.value, 'Data:', newParticipant.value);
  try {
    const response = await axios.put(`/participants/${editParticipantId.value}`, newParticipant.value);
    console.log('Update response:', response.data);
    const index = participants.value.findIndex(p => p.id === editParticipantId.value);
    if (index !== -1) {
      const originalParticipant = participants.value[index];
      participants.value[index] = {
        ...response.data,
        birthdate: response.data.birthdate ? response.data.birthdate.split('T')[0] : '',
        divisions: originalParticipant.divisions,
      };
    }
    participants.value.sort((a, b) => {
      const lastNameA = a.last_name || '';
      const lastNameB = b.last_name || '';
      const firstNameA = a.first_name || '';
      const firstNameB = b.first_name || '';
      return lastNameA.localeCompare(lastNameB) || firstNameA.localeCompare(firstNameB);
    });
    showAddForm.value = false;
  } catch (error) {
    console.error('Error updating participant:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to update participant. Please try again.';
  }
};

const deleteParticipant = async (id) => {
  if (confirm('Are you sure you want to delete this participant?')) {
    try {
      await axios.delete(`/participants/${id}`);
      participants.value = participants.value.filter(p => p.id !== id);
    } catch (error) {
      console.error('Error deleting participant:', error.response ? error.response.data : error.message);
    }
  }
};

const manageDivisions = async (participant) => {
  selectedParticipant.value = participant;
  showDivisionForm.value = true;
  try {
    const response = await axios.get(`/participants/${participant.id}/divisions`);
    participantDivisions.value = response.data;
  } catch (error) {
    console.error('Error fetching participant divisions:', error.response ? error.response.data : error.message);
    participantDivisions.value = [];
  }
};

const addDivisionToParticipant = async () => {
  if (!selectedDivisionId.value) return;
  try {
    await axios.post('/participants/division', {
      participant_id: selectedParticipant.value.id,
      division_id: selectedDivisionId.value,
    });
    await fetchParticipants();
    const response = await axios.get(`/participants/${selectedParticipant.value.id}/divisions`);
    participantDivisions.value = response.data;
    selectedDivisionId.value = '';
  } catch (error) {
    console.error('Error adding division to participant:', error.response ? error.response.data : error.message);
  }
};

const removeDivisionFromParticipant = async (divisionId) => {
  console.log('Removing division, divisionId:', divisionId, 'participantId:', selectedParticipant.value.id);
  try {
    await axios.delete('/participants/division', {
      data: { participant_id: selectedParticipant.value.id, division_id: divisionId },
    });
    await fetchParticipants();
    const response = await axios.get(`/participants/${selectedParticipant.value.id}/divisions`);
    participantDivisions.value = response.data;
  } catch (error) {
    console.error('Error removing division from participant:', error.response ? error.response.data : error.message);
  }
};

const closeDivisionForm = () => {
  showDivisionForm.value = false;
  selectedParticipant.value = null;
  participantDivisions.value = [];
  selectedDivisionId.value = '';
};

const resetForm = () => {
  newParticipant.value = {
    first_name: '',
    middle_name: '',
    last_name: '',
    school_id: '',
    birthdate: '',
    height_feet: null,
    height_inches: null,
    weight: null,
    gender: '',
    phone: '',
    emergency_contact_name: '',
    emergency_contact_phone: '',
    street: '',
    city: '',
    state: '',
    country: '',
    zip_code: '',
    participant_rank: '',
  };
  editParticipantId.value = null;
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

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/login');
};

onMounted(() => {
  fetchParticipants();
  fetchSchools();
  fetchAllDivisions();
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