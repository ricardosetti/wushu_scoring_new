<template>
    <div class="container mx-auto p-4">
      <h2 class="text-xl font-bold mb-4">School Management</h2>
      <button
        @click="openAddForm"
        class="bg-green-500 text-white px-4 py-2 rounded mb-4 hover:bg-green-600"
      >
        Add New School
      </button>
  
      <!-- Add/Edit School Form -->
      <div v-if="showAddForm" class="mb-4 p-4 border rounded">
        <h3 class="text-lg font-bold mb-2">{{ editSchoolId ? 'Edit School' : 'Add School' }}</h3>
        <!-- Display Logo -->
        <div v-if="getLogoPreview" class="mb-4">
          <img :src="getLogoPreview" alt="School Logo" class="w-12 h-12 object-cover rounded" />
        </div>
        <div v-else-if="editSchoolId && schools.find(s => s.id === editSchoolId)?.school_logo" class="mb-4 text-sm text-gray-600">
          Existing Logo: {{ newSchool.school_name }}_logo.jpg
        </div>
        <form @submit.prevent="handleSubmit" enctype="multipart/form-data">
          <div class="mb-2">
            <label class="block">School Name *</label>
            <input v-model="newSchool.school_name" required class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">Address</label>
            <input v-model="newSchool.school_address" class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">Contact</label>
            <input v-model="newSchool.school_contact" class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">Phone</label>
            <input v-model="newSchool.school_phone" class="border p-2 w-full" />
          </div>
          <div class="mb-2">
            <label class="block">Logo (JPG)</label>
            <input type="file" accept="image/jpeg" @change="handleLogoUpload" class="border p-2 w-full" />
          </div>
          <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
            {{ editSchoolId ? 'Update' : 'Save' }}
          </button>
          <button @click="cancelForm" class="ml-2 bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
            Cancel
          </button>
        </form>
      </div>
  
      <!-- School List -->
      <div v-if="schools.length">
        <h3 class="text-lg font-bold mb-2">Schools</h3>
        <div v-for="school in schools" :key="school.id" class="border p-2 mb-2 flex justify-between">
          <span>{{ school.school_name }}</span>
          <div>
            <button @click="editSchool(school)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">
              Edit
            </button>
            <button @click="deleteSchool(school.id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
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
        schools: [],
        showAddForm: false,
        newSchool: {
          school_name: '',
          school_address: '',
          school_contact: '',
          school_phone: '',
          school_logo: null,
        },
        editSchoolId: null,
        logoPreview: null,
      };
    },
    computed: {
      getLogoPreview() {
        if (this.logoPreview) {
          return this.logoPreview;
        }
        return null;
      },
    },
    mounted() {
      this.fetchSchools();
    },
    beforeUnmount() {
      if (this.logoPreview && typeof this.logoPreview === 'string' && this.logoPreview.startsWith('blob:')) {
        URL.revokeObjectURL(this.logoPreview);
      }
    },
    methods: {
      async fetchSchools() {
        try {
          const response = await axios.get(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/schools`);
          this.schools = response.data;
        } catch (error) {
          console.error('Error fetching schools:', error.response ? error.response.data : error.message);
        }
      },
      handleLogoUpload(event) {
        const file = event.target.files[0];
        if (file && file.type === 'image/jpeg') {
          this.newSchool.school_logo = file;
          this.logoPreview = URL.createObjectURL(file);
        } else {
          this.newSchool.school_logo = this.editSchoolId ? this.schools.find(s => s.id === this.editSchoolId)?.school_logo || null : null;
          this.logoPreview = this.newSchool.school_logo; // Use base64 string for existing logo
          console.warn('Please upload a valid JPEG file.');
        }
      },
      handleSubmit() {
        console.log('Submitting form, editSchoolId:', this.editSchoolId, 'newSchool:', this.newSchool);
        if (this.editSchoolId) {
          this.updateSchool();
        } else {
          this.addSchool();
        }
      },
      async addSchool() {
        console.log('Adding new school:', this.newSchool);
        const formData = new FormData();
        formData.append('school_name', this.newSchool.school_name);
        formData.append('school_address', this.newSchool.school_address);
        formData.append('school_contact', this.newSchool.school_contact);
        formData.append('school_phone', this.newSchool.school_phone);
        if (this.newSchool.school_logo && this.newSchool.school_logo.type) {
          formData.append('school_logo', this.newSchool.school_logo);
        }
  
        try {
          const response = await axios.post(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/schools`,
            formData,
            {
              headers: { 'Content-Type': 'multipart/form-data' },
            }
          );
          this.schools.push(response.data);
          this.resetForm();
        } catch (error) {
          console.error('Error adding school:', error.response ? error.response.data : error.message);
        }
      },
      editSchool(school) {
        this.editSchoolId = school.id;
        this.newSchool = { ...school };
        this.showAddForm = true;
        this.logoPreview = school.school_logo; // Set base64 string for preview
      },
      async updateSchool() {
        console.log('Updating school with id:', this.editSchoolId);
        const formData = new FormData();
        formData.append('school_name', this.newSchool.school_name);
        formData.append('school_address', this.newSchool.school_address);
        formData.append('school_contact', this.newSchool.school_contact);
        formData.append('school_phone', this.newSchool.school_phone);
        if (this.newSchool.school_logo && this.newSchool.school_logo.type) {
          formData.append('school_logo', this.newSchool.school_logo);
        } else {
          // Do not append school_logo to preserve the existing one
        }
  
        try {
          const response = await axios.put(
            `http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/schools/${this.editSchoolId}`,
            formData,
            {
              headers: { 'Content-Type': 'multipart/form-data' },
            }
          );
          const index = this.schools.findIndex(s => s.id === this.editSchoolId);
          if (index !== -1) this.schools[index] = response.data;
          this.resetForm();
        } catch (error) {
          console.error('Error updating school:', error.response ? error.response.data : error.message);
        }
      },
      async deleteSchool(id) {
        if (confirm('Are you sure you want to delete this school?')) {
          try {
            await axios.delete(`http://${process.env.VITE_SERVER_HOST}:${process.env.VITE_SERVER_PORT}/schools/${id}`);
            this.schools = this.schools.filter(s => s.id !== id);
          } catch (error) {
            console.error('Error deleting school:', error.response ? error.response.data : error.message);
          }
        }
      },
      resetForm() {
        this.newSchool = { school_name: '', school_address: '', school_contact: '', school_phone: '', school_logo: null };
        this.editSchoolId = null;
        if (this.logoPreview && typeof this.logoPreview === 'string' && this.logoPreview.startsWith('blob:')) {
          URL.revokeObjectURL(this.logoPreview);
        }
        this.logoPreview = null;
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
  /* Constrain logo size to 50x50 pixels */
  img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
  }
  </style>