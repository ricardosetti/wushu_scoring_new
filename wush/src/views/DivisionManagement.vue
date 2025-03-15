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
            </div>
            <div class="mt-4 flex justify-end">
              <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                {{ editDivisionId ? 'Update' : 'Save' }}
              </button>
              <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
                Cancel
              </button>
            </div>
            <div v-if="errorMessage" class="mt-2 text-red-500">{{ errorMessage }}</div>
          </form>
        </div>
      </div>
  
      <!-- Division List -->
      <div v-if="divisions.length">
        <h3 class="text-lg font-bold mb-2">Divisions</h3>
        <div v-for="division in divisions" :key="division.id" class="border p-2 mb-2 flex justify-between">
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
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        divisions: [],
        showAddForm: false,
        newDivision: {
          division_name: '',
        },
        editDivisionId: null,
        errorMessage: '',
      };
    },
    mounted() {
      this.fetchDivisions();
    },
    methods: {
      async fetchDivisions() {
        try {
          console.log('Fetching divisions...');
          const response = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/divisions`);
          console.log('Divisions response:', response.data);
          this.divisions = response.data;
        } catch (error) {
          console.error('Error fetching divisions:', error.response ? error.response.data : error.message);
          this.divisions = [];
        }
      },
      handleSubmit() {
        this.errorMessage = '';
        console.log('Submitting form, editDivisionId:', this.editDivisionId, 'Data:', this.newDivision);
        if (this.editDivisionId) {
          this.updateDivision();
        } else {
          this.addDivision();
        }
      },
      async addDivision() {
        console.log('Adding new division, Data:', this.newDivision);
        try {
          const response = await axios.post(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/divisions`,
            this.newDivision
          );
          console.log('Add response:', response.data);
          this.divisions.push(response.data);
          this.showAddForm = false;
          this.resetForm();
        } catch (error) {
          console.error('Error adding division:', error.response ? error.response.data : error.message);
          this.errorMessage = error.response?.data?.error || 'Failed to add division. Please try again.';
        }
      },
      editDivision(division) {
        this.editDivisionId = division.id;
        this.newDivision = { ...division };
        this.showAddForm = true;
      },
      async updateDivision() {
        console.log('Updating division with id:', this.editDivisionId, 'Data:', this.newDivision);
        try {
          const response = await axios.put(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/divisions/${this.editDivisionId}`,
            this.newDivision
          );
          console.log('Update response:', response.data);
          const index = this.divisions.findIndex(d => d.id === this.editDivisionId);
          if (index !== -1) this.divisions[index] = response.data;
          this.showAddForm = false;
          this.resetForm();
        } catch (error) {
          console.error('Error updating division:', error.response ? error.response.data : error.message);
          this.errorMessage = error.response?.data?.error || 'Failed to update division. Please try again.';
        }
      },
      async deleteDivision(id) {
        if (confirm('Are you sure you want to delete this division?')) {
          try {
            await axios.delete(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/divisions/${id}`);
            this.divisions = this.divisions.filter(d => d.id !== id);
          } catch (error) {
            console.error('Error deleting division:', error.response ? error.response.data : error.message);
          }
        }
      },
      resetForm() {
        this.newDivision = { division_name: '' };
        this.editDivisionId = null;
        this.errorMessage = '';
      },
      openAddForm() {
        this.showAddForm = true;
        this.resetForm();
      },
      cancelForm() {
        this.showAddForm = false;
        this.resetForm();
      },
    },
  };
  </script>
  
  <style scoped>
  /* No additional styles needed for now */
  </style>