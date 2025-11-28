<template>
  <div class="container mx-auto p-4">
    <div class="flex justify-between items-center mb-4">
      <h2 class="text-xl font-bold">Division Management</h2>
      <button
        @click="openAddForm"
        class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded"
      >
        + Add Global Division
      </button>
    </div>

    <div class="bg-blue-50 p-3 rounded border border-blue-200 mb-6 text-sm text-blue-800">
      <p><strong>Note:</strong> Divisions are global. Use the checkboxes below to enable/disable them for the <strong>Currently Active Tournament</strong>.</p>
    </div>

    <div v-if="divisions.length" class="bg-white shadow rounded-lg overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Active?</th>
            <th class="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Division Name</th>
            <th class="px-6 py-3 text-right text-xs font-bold text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="division in divisions" :key="division.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">
              <label class="inline-flex items-center cursor-pointer">
                <input 
                  type="checkbox" 
                  class="form-checkbox h-5 w-5 text-blue-600 rounded focus:ring-blue-500"
                  :checked="activeDivisionIds.includes(division.id)"
                  @change="toggleStatus(division, $event.target.checked)"
                >
                <span class="ml-2 text-sm text-gray-600">
                  {{ activeDivisionIds.includes(division.id) ? 'Enabled' : 'Disabled' }}
                </span>
              </label>
            </td>
            
            <td class="px-6 py-4 font-medium text-gray-900">
              {{ division.division_name }}
            </td>
            
            <td class="px-6 py-4 text-right space-x-2">
              <button @click="editDivision(division)" class="text-indigo-600 hover:text-indigo-900 text-sm font-bold">Edit Name</button>
              <button @click="deleteDivision(division.id)" class="text-red-500 hover:text-red-700 text-sm font-bold">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else class="text-center py-10 text-gray-500">No divisions found.</div>

    <div v-if="showAddForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg max-w-md w-full">
        <h3 class="text-lg font-bold mb-4">{{ editDivisionId ? 'Edit Division' : 'Add Global Division' }}</h3>
        <form @submit.prevent="handleSubmit">
          <div class="mb-4">
            <label class="block text-sm font-bold mb-1">Division Name *</label>
            <input v-model="newDivision.division_name" required class="border p-2 w-full rounded" placeholder="e.g. Northern Fist" />
          </div>
          <div class="flex justify-end space-x-2">
            <button @click="cancelForm" type="button" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancel</button>
            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Save</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '../axios';

const divisions = ref([]);
const activeDivisionIds = ref([]); // Stores IDs of divisions active for the current tournament
const showAddForm = ref(false);
const newDivision = ref({ division_name: '' });
const editDivisionId = ref(null);

const loadData = async () => {
  try {
    // 1. Get ALL global divisions
    const allRes = await axios.get('/divisions');
    divisions.value = allRes.data;

    // 2. Get divisions ONLY for the active tournament
    const activeRes = await axios.get('/divisions', { params: { active_only: true } });
    activeDivisionIds.value = activeRes.data.map(d => d.id);
  } catch (error) {
    console.error('Error loading divisions:', error);
  }
};

const toggleStatus = async (division, isChecked) => {
  try {
    // Optimistic update
    if (isChecked) {
      activeDivisionIds.value.push(division.id);
    } else {
      activeDivisionIds.value = activeDivisionIds.value.filter(id => id !== division.id);
    }

    await axios.post(`/divisions/${division.id}/toggle-status`, { is_enabled: isChecked });
  } catch (error) {
    alert("Failed to update status");
    loadData(); // Revert on error
  }
};

const handleSubmit = async () => {
  try {
    if (editDivisionId.value) {
      await axios.put(`/divisions/${editDivisionId.value}`, newDivision.value);
    } else {
      await axios.post('/divisions', newDivision.value);
    }
    closeForm();
    loadData();
  } catch (error) {
    alert("Error saving division");
  }
};

const editDivision = (d) => {
  editDivisionId.value = d.id;
  newDivision.value = { ...d };
  showAddForm.value = true;
};

const deleteDivision = async (id) => {
  if(confirm("Delete this division globally? This cannot be undone.")) {
    try {
      await axios.delete(`/divisions/${id}`);
      loadData();
    } catch (e) { alert("Error deleting"); }
  }
};

const openAddForm = () => {
  editDivisionId.value = null;
  newDivision.value = { division_name: '' };
  showAddForm.value = true;
};

const closeForm = () => showAddForm.value = false;
const cancelForm = closeForm;

onMounted(loadData);
</script>