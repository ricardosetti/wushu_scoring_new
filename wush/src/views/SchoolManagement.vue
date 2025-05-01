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
      <div v-for="school in schools" :key="school.id" class="border p-4 mb-4 rounded-lg shadow-sm bg-white">
        <div class="flex justify-between items-center">
          <div>
            <h3 class="font-semibold">{{ school.school_name }}</h3>
            <p class="text-gray-600 text-sm">{{ school.school_address }}</p>
          </div>
          <div class="flex gap-2">
            <button @click="editSchool(school)" class="bg-yellow-500 text-white px-3 py-1 rounded hover:bg-yellow-600">
              Edit
            </button>
            <button @click="deleteSchool(school.id)" class="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600">
              Delete
            </button>
            <button @click="generateLink(school)" class="bg-blue-600 text-white px-3 py-1 rounded hover:bg-blue-700">
              Generate Link
            </button>
          </div>
        </div>

        <div v-if="school.registration_link" class="mt-3 p-3 bg-gray-50 rounded">
          <p class="text-sm font-medium">Registration Link:</p>
          <input class="border p-2 w-full rounded text-sm bg-white" :value="school.registration_link" readonly @click="$event.target.select()" />
          <div class="flex justify-center mt-3">
            <img v-if="school.qr_code_data_url" :src="school.qr_code_data_url" alt="QR Code" class="w-32 h-32" />
          </div>
        </div>
      </div>
    </div>

    <!-- Logout Button -->
    <button @click="logout" class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 mt-4">
      Logout
    </button>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import axios from '../axios';
import { useRouter } from 'vue-router';

const router = useRouter();
const schools = ref([]);
const showAddForm = ref(false);
const newSchool = ref({
  school_name: '',
  school_address: '',
  school_contact: '',
  school_phone: '',
  school_logo: null,
});
const editSchoolId = ref(null);
const logoPreview = ref(null);

const getLogoPreview = computed(() => logoPreview.value || null);

const fetchSchools = async () => {
  try {
    const response = await axios.get('/schools');
    schools.value = response.data.map(school => ({
      ...school,
      registration_link: school.registration_link || null,
      qr_code_data_url: school.school_qr_code ? `data:image/png;base64,${school.school_qr_code}` : null,
    }));
  } catch (error) {
    console.error('Error fetching schools:', error.response ? error.response.data : error.message);
    schools.value = [];
  }
};

const generateLink = async (school) => {
  try {
    const response = await axios.post(`/schools/${school.id}/generate-registration-link`);
    school.registration_link = response.data.registration_link;
    school.qr_code_data_url = response.data.qr_code_data_url;
  } catch (error) {
    console.error('Error generating registration link:', error.response ? error.response.data : error.message);
    alert('Failed to generate registration link.');
  }
};

const handleLogoUpload = (event) => {
  const file = event.target.files[0];
  if (file && file.type === 'image/jpeg') {
    newSchool.value.school_logo = file;
    logoPreview.value = URL.createObjectURL(file);
  } else {
    newSchool.value.school_logo = editSchoolId.value ? schools.value.find(s => s.id === editSchoolId.value)?.school_logo || null : null;
    logoPreview.value = newSchool.value.school_logo;
    console.warn('Please upload a valid JPEG file.');
  }
};

const handleSubmit = () => {
  if (editSchoolId.value) updateSchool();
  else addSchool();
};

const addSchool = async () => {
  const formData = new FormData();
  formData.append('school_name', newSchool.value.school_name);
  formData.append('school_address', newSchool.value.school_address);
  formData.append('school_contact', newSchool.value.school_contact);
  formData.append('school_phone', newSchool.value.school_phone);
  if (newSchool.value.school_logo?.type) formData.append('school_logo', newSchool.value.school_logo);

  try {
    const response = await axios.post('/schools', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    schools.value.push(response.data);
    resetForm();
  } catch (error) {
    console.error('Error adding school:', error.response ? error.response.data : error.message);
  }
};

const editSchool = (school) => {
  editSchoolId.value = school.id;
  newSchool.value = { ...school };
  showAddForm.value = true;
  logoPreview.value = school.school_logo;
};

const updateSchool = async () => {
  const formData = new FormData();
  formData.append('school_name', newSchool.value.school_name);
  formData.append('school_address', newSchool.value.school_address);
  formData.append('school_contact', newSchool.value.school_contact);
  formData.append('school_phone', newSchool.value.school_phone);
  if (newSchool.value.school_logo?.type) formData.append('school_logo', newSchool.value.school_logo);

  try {
    const response = await axios.put(`/schools/${editSchoolId.value}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    const index = schools.value.findIndex(s => s.id === editSchoolId.value);
    if (index !== -1) schools.value[index] = response.data;
    resetForm();
  } catch (error) {
    console.error('Error updating school:', error.response ? error.response.data : error.message);
  }
};

const deleteSchool = async (id) => {
  if (confirm('Are you sure you want to delete this school?')) {
    try {
      await axios.delete(`/schools/${id}`);
      schools.value = schools.value.filter(s => s.id !== id);
    } catch (error) {
      console.error('Error deleting school:', error.response ? error.response.data : error.message);
    }
  }
};

const resetForm = () => {
  newSchool.value = { school_name: '', school_address: '', school_contact: '', school_phone: '', school_logo: null };
  editSchoolId.value = null;
  if (logoPreview.value?.startsWith?.('blob:')) URL.revokeObjectURL(logoPreview.value);
  logoPreview.value = null;
  showAddForm.value = false;
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
  fetchSchools();
});

onBeforeUnmount(() => {
  if (logoPreview.value?.startsWith?.('blob:')) URL.revokeObjectURL(logoPreview.value);
});
</script>

<style scoped>
img {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 4px;
}
</style>
