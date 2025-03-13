<template>
    <div class="container mx-auto p-4">
      <h2 class="text-xl font-bold mb-4">Participant Management</h2>
      <button
        @click="openAddForm"
        class="bg-green-500 text-white px-4 py-2 rounded mb-4 hover:bg-green-600"
      >
        Add New Participant
      </button>
  
      <!-- Add/Edit Participant Form -->
      <div v-if="showAddForm" class="mb-4 p-4 border rounded">
        <h3 class="text-lg font-bold mb-2">{{ editParticipantId ? 'Edit Participant' : 'Add Participant' }}</h3>
        <form @submit.prevent="handleSubmit" enctype="multipart/form-data">
          <div class="mb-2">
            <label class="block">Name *</label>
            <input v-model="newParticipant.name" required class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">Division *</label>
            <input v-model="newParticipant.division" required class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">School</label>
            <select v-model="newParticipant.school_id" class="border p-2 w-full">
              <option value="">Select a School</option>
              <option v-for="school in schools" :key="school.id" :value="school.id">
                {{ school.school_name }}
              </option>
            </select>
          </div>
          <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
            {{ editParticipantId ? 'Update' : 'Save' }}
          </button>
          <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
            Cancel
          </button>
        </form>
      </div>
  
      <!-- Participant List -->
      <div v-if="participants.length">
        <h3 class="text-lg font-bold mb-2">Participants</h3>
        <div v-for="participant in participants" :key="participant.id" class="border p-2 mb-2 flex justify-between">
          <span>{{ participant.name }} ({{ participant.division }}, {{ participant.school_name || 'No School' }})</span>
          <div>
            <button @click="editParticipant(participant)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">
              Edit
            </button>
            <button @click="deleteParticipant(participant.id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        participants: [],
        schools: [],
        showAddForm: false,
        newParticipant: {
          name: '',
          school_id: '',
          division: '',
        },
        editParticipantId: null,
      };
    },
    mounted() {
      this.fetchParticipants();
      this.fetchSchools();
    },
    methods: {
      async fetchParticipants() {
        try {
          const response = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants`);
          this.participants = response.data.sort((a, b) => a.name.localeCompare(b.name)); // Sort alphabetically by name
        } catch (error) {
          console.error('Error fetching participants:', error.response ? error.response.data : error.message);
        }
      },
      async fetchSchools() {
        try {
          const response = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/schools`);
          this.schools = response.data;
        } catch (error) {
          console.error('Error fetching schools:', error.response ? error.response.data : error.message);
        }
      },
      handleSubmit() {
        console.log('Submitting form, editParticipantId:', this.editParticipantId);
        if (this.editParticipantId) {
          this.updateParticipant();
        } else {
          this.addParticipant();
        }
      },
      async addParticipant() {
        console.log('Adding new participant:', this.newParticipant);
        try {
          await axios.post(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants`,
            this.newParticipant
          );
          // Re-fetch participants to ensure correct data and sorting
          await this.fetchParticipants();
          this.resetForm();
        } catch (error) {
          console.error('Error adding participant:', error.response ? error.response.data : error.message);
        }
      },
      editParticipant(participant) {
        this.editParticipantId = participant.id;
        this.newParticipant = { ...participant };
        this.showAddForm = true;
      },
      async updateParticipant() {
        console.log('Updating participant with id:', this.editParticipantId);
        try {
          const response = await axios.put(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${this.editParticipantId}`,
            this.newParticipant
          );
          const index = this.participants.findIndex(p => p.id === this.editParticipantId);
          if (index !== -1) this.participants[index] = response.data;
          this.participants.sort((a, b) => a.name.localeCompare(b.name)); // Sort after update
          this.resetForm();
        } catch (error) {
          console.error('Error updating participant:', error.response ? error.response.data : error.message);
        }
      },
      async deleteParticipant(id) {
        if (confirm('Are you sure you want to delete this participant?')) {
          try {
            await axios.delete(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/participants/${id}`);
            this.participants = this.participants.filter(p => p.id !== id);
          } catch (error) {
            console.error('Error deleting participant:', error.response ? error.response.data : error.message);
          }
        }
      },
      resetForm() {
        this.newParticipant = { name: '', school_id: '', division: '' };
        this.editParticipantId = null;
        // Removed showAddForm = false to keep form open after submission
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
  /* Add any specific styles if needed */
  </style>