<template>
  <div class="container mx-auto p-4">
    <h2 class="text-xl font-bold mb-4">Division Management</h2>
    <button
      @click="openAddForm"
      class="bg-green-500 text-white px-4 py-2 rounded mb-4 hover:bg-green-600"
    >
      Add New Division
    </button>

    <!-- Modal for Add/Edit Division -->
    <div v-if="showAddForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg max-w-md w-full">
        <h3 class="text-lg font-bold mb-4">{{ editDivisionId ? 'Edit Division' : 'Add Division' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="mb-2">
            <label class="block">Division Name *</label>
            <input v-model="newDivision.division_name" required class="border p-2 w-full rounded" />
            <div v-if="errorMessage && !newDivision.division_name" class="text-red-500 text-sm mt-1">
              Division name is required.
            </div>
          </div>
          <div class="mt-4 flex justify-end">
            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              {{ editDivisionId ? 'Update' : 'Save' }}
            </button>
            <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
              Cancel
            </button>
          </div>
          <div v-if="errorMessage && newDivision.division_name" class="mt-2 text-red-500">{{ errorMessage }}</div>
        </form>
      </div>
    </div>

    <!-- Division List -->
    <div v-if="divisions.length">
      <h3 class="text-lg font-bold mb-2">Divisions</h3>
      <div v-for="division in divisions" :key="division.id" class="border p-2 mb-2 flex justify-between items-center">
        <span>{{ division.division_name }}</span>
        <div>
          <button @click="editDivision(division)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">
            Edit
          </button>
          <button @click="deleteDivision(division.id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
            Delete
          </button>
        </div>
      </div>
    </div>
    <div v-else>
      <p>No divisions found.</p>
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
import { ref, onMounted } from 'vue'; // Added onMounted import
import axios from '../axios'; // Use custom Axios instance
import { useRouter } from 'vue-router';

const router = useRouter();
const divisions = ref([]);
const showAddForm = ref(false);
const newDivision = ref({
  division_name: '',
});
const editDivisionId = ref(null);
const errorMessage = ref('');

const fetchDivisions = async () => {
  try {
    console.log('Fetching divisions...');
    const response = await axios.get('/divisions');
    console.log('Divisions response:', response.data);
    divisions.value = response.data;
  } catch (error) {
    console.error('Error fetching divisions:', error.response ? error.response.data : error.message);
    divisions.value = [];
  }
};

const handleSubmit = () => {
  errorMessage.value = '';
  if (!newDivision.value.division_name) {
    errorMessage.value = 'Division name is required.';
    return;
  }
  console.log('Submitting form, editDivisionId:', editDivisionId.value, 'Data:', newDivision.value);
  if (editDivisionId.value) {
    updateDivision();
  } else {
    addDivision();
  }
};

const addDivision = async () => {
  console.log('Adding new division, Data:', newDivision.value);
  try {
    const response = await axios.post('/divisions', newDivision.value);
    console.log('Add response:', response.data);
    divisions.value.push(response.data);
    showAddForm.value = false;
    resetForm();
  } catch (error) {
    console.error('Error adding division:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to add division. Please try again.';
  }
};

const editDivision = (division) => {
  editDivisionId.value = division.id;
  newDivision.value = { ...division };
  showAddForm.value = true;
};

const updateDivision = async () => {
  console.log('Updating division with id:', editDivisionId.value, 'Data:', newDivision.value);
  try {
    const response = await axios.put(`/divisions/${editDivisionId.value}`, newDivision.value);
    console.log('Update response:', response.data);
    const index = divisions.value.findIndex(d => d.id === editDivisionId.value);
    if (index !== -1) {
      divisions.value[index] = response.data;
    }
    showAddForm.value = false;
    resetForm();
  } catch (error) {
    console.error('Error updating division:', error.response ? error.response.data : error.message);
    errorMessage.value = error.response?.data?.error || 'Failed to update division. Please try again.';
  }
};

const deleteDivision = async (id) => {
  if (confirm('Are you sure you want to delete this division?')) {
    try {
      await axios.delete(`/divisions/${id}`);
      divisions.value = divisions.value.filter(d => d.id !== id);
    } catch (error) {
      console.error('Error deleting division:', error.response ? error.response.data : error.message);
    }
  }
};

const resetForm = () => {
  newDivision.value = { division_name: '' };
  editDivisionId.value = null;
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
  fetchDivisions();
});
</script>

<style scoped>
/* No additional styles needed for now */
</style>