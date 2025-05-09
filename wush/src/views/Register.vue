<template>
    <div class="container mx-auto p-4 max-w-4xl">
      <h2 class="text-2xl font-bold mb-6 text-center">Wushu Tournament Registration</h2>
      <div v-if="loading" class="text-center text-gray-500">Loading...</div>
      <div v-else-if="error" class="text-red-500 mb-4 text-center">{{ error }}</div>
      <form v-else @submit.prevent="handleSubmit" class="bg-white p-6 rounded shadow-md">
        <h3 class="text-xl font-semibold mb-4">Personal Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="col-span-2">
            <label class="block mb-1">School</label>
            <input type="text" :value="school ? school.school_name : 'Loading...'" disabled class="border p-2 w-full rounded bg-gray-100" />
          </div>
          <InputField label="First Name" v-model="form.first_name" required />
          <InputField label="Middle Name" v-model="form.middle_name" />
          <InputField label="Last Name" v-model="form.last_name" required />
          <InputField label="Rank" v-model="form.participant_rank" />
          <InputField label="Birthdate" v-model="form.birthdate" type="date" required />
          <InputField label="Height (feet)" v-model="form.height_feet" type="number" />
          <InputField label="Height (inches)" v-model="form.height_inches" type="number" />
          <InputField label="Weight (kg)" v-model="form.weight" type="number" step="0.01" />
          <SelectField label="Gender" v-model="form.gender" :options="genderOptions" required />
          <InputField label="Phone" v-model="form.phone" />
          <InputField label="Emergency Contact Name" v-model="form.emergency_contact_name" />
          <InputField label="Emergency Contact Phone" v-model="form.emergency_contact_phone" />
          <InputField label="Street" v-model="form.street" />
          <InputField label="City" v-model="form.city" />
          <InputField label="State" v-model="form.state" />
          <InputField label="Country" v-model="form.country" />
          <InputField label="ZIP Code" v-model="form.zip_code" />
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Account Info</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <InputField label="Email" v-model="form.email" type="email" required />
          <InputField label="Password" v-model="form.password" type="password" required />
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Choose Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-2">
            <input type="checkbox" :value="division.id" v-model="selectedDivisions" />
            <span>{{ division.division_name }}</span>
          </label>
        </div>
  
        <button type="submit" :disabled="submitting" class="w-full bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600">
          {{ submitting ? 'Submitting...' : 'Submit Application' }}
        </button>
      </form>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue';
  import axios from '../axios';
  import { useRoute, useRouter } from 'vue-router';
  import InputField from '../components/InputField.vue';
  import SelectField from '../components/SelectField.vue';
  
  const route = useRoute();
  const router = useRouter();
  const token = ref(route.query.token || '');
  
  const form = ref({
    first_name: '',
    middle_name: '',
    last_name: '',
    school_id: null,
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
    email: '',
    password: '',
  });
  
  const selectedDivisions = ref([]);
  const divisions = ref([]);
  const school = ref(null);
  const error = ref('');
  const loading = ref(true);
  const submitting = ref(false);
  
  const genderOptions = [
    { value: 'M', label: 'Male' },
    { value: 'F', label: 'Female' },
    { value: 'O', label: 'Other' }
  ];
  
  const fetchInitialData = async () => {
    try {
      if (!token.value) {
        throw new Error('No registration token provided in the URL.');
      }
  
      const [schoolResponse, divisionsResponse] = await Promise.all([
        axios.get(`/register/validate-token?token=${token.value}`),
        axios.get('/divisions')
      ]);
  
      school.value = schoolResponse.data.school;
      form.value.school_id = school.value.id; // Correct field name: id
      divisions.value = divisionsResponse.data;
    } catch (err) {
      error.value = err.response?.data?.error || 'Failed to load registration data. Check your registration link.';
    } finally {
      loading.value = false;
    }
  };
  
  const handleSubmit = async () => {
    try {
      submitting.value = true;
      const payload = { ...form.value, divisions: selectedDivisions.value };
      await axios.post('/register', payload);
      alert('Registration submitted successfully! Please log in to continue.');
      router.push('/login');
    } catch (err) {
      error.value = err.response?.data?.error || 'Registration failed. Please try again.';
    } finally {
      submitting.value = false;
    }
  };
  
  onMounted(fetchInitialData);
  </script>
  
  <style scoped>
  .container {
    max-width: 850px;
  }
  </style>