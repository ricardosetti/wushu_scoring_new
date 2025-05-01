
<template>
    <div class="container mx-auto p-4 max-w-4xl">
      <h2 class="text-2xl font-bold mb-6 text-center">Wushu Tournament Registration</h2>
      <form @submit.prevent="handleSubmit" class="bg-white p-6 rounded shadow-md">
        <h3 class="text-xl font-semibold mb-4">Personal Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input-field label="First Name" v-model="form.first_name" required />
          <input-field label="Middle Name" v-model="form.middle_name" />
          <input-field label="Last Name" v-model="form.last_name" required />
          <select-field label="School" v-model="form.school_id" :options="schools" required option-label="school_name" />
          <input-field label="Rank" v-model="form.participant_rank" />
          <input-field label="Birthdate" v-model="form.birthdate" type="date" required />
          <input-field label="Height (feet)" v-model="form.height_feet" type="number" />
          <input-field label="Height (inches)" v-model="form.height_inches" type="number" />
          <input-field label="Weight (kg)" v-model="form.weight" type="number" step="0.01" />
          <select-field label="Gender" v-model="form.gender" :options="genderOptions" required />
          <input-field label="Phone" v-model="form.phone" />
          <input-field label="Emergency Contact Name" v-model="form.emergency_contact_name" />
          <input-field label="Emergency Contact Phone" v-model="form.emergency_contact_phone" />
          <input-field label="Street" v-model="form.street" />
          <input-field label="City" v-model="form.city" />
          <input-field label="State" v-model="form.state" />
          <input-field label="Country" v-model="form.country" />
          <input-field label="ZIP Code" v-model="form.zip_code" />
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Account Info</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input-field label="Email" v-model="form.email" type="email" required />
          <input-field label="Password" v-model="form.password" type="password" required />
        </div>
  
        <h3 class="text-xl font-semibold mt-8 mb-4">Choose Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <label v-for="division in divisions" :key="division.id" class="flex items-center space-x-2">
            <input type="checkbox" :value="division.id" v-model="selectedDivisions" />
            <span>{{ division.division_name }}</span>
          </label>
        </div>
  
        <div v-if="error" class="text-red-500 mb-4">{{ error }}</div>
  
        <button type="submit" class="w-full bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600">
          Submit Application
        </button>
      </form>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue';
  import axios from '../axios';
  import { useRoute, useRouter } from 'vue-router';
  
  const route = useRoute();
  const router = useRouter();
  const token = route.params.token;
  
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
  const schools = ref([]);
  const error = ref('');
  
  const genderOptions = [
    { value: 'M', label: 'Male' },
    { value: 'F', label: 'Female' },
    { value: 'O', label: 'Other' }
  ];
  
  const fetchInitialData = async () => {
    try {
      const [divs, schs] = await Promise.all([
        axios.get(`/registrations/token/${token}`),
        axios.get('/schools')
      ]);
      divisions.value = divs.data;
      schools.value = schs.data;
    } catch (err) {
      error.value = 'Failed to load data. Check your registration link.';
    }
  };
  
  const handleSubmit = async () => {
    try {
      const payload = { ...form.value, divisions: selectedDivisions.value };
      await axios.post(`/register/${token}`, payload);
      alert('Registration submitted successfully!');
      router.push('/');
    } catch (err) {
      error.value = err.response?.data?.error || 'Registration failed.';
    }
  };
  
  onMounted(fetchInitialData);
  </script>
  
  <script>
  export default {
    components: {
      'input-field': {
        props: ['label', 'modelValue', 'type', 'required'],
        emits: ['update:modelValue'],
        template: `
          <div>
            <label class="block mb-1">{{ label }}<span v-if="required" class="text-red-500">*</span></label>
            <input :type="type || 'text'" :required="required"
                   class="border p-2 w-full rounded"
                   :value="modelValue"
                   @input="$emit('update:modelValue', $event.target.value)" />
          </div>`
      },
      'select-field': {
        props: ['label', 'modelValue', 'options', 'required', 'optionLabel'],
        emits: ['update:modelValue'],
        template: `
          <div>
            <label class="block mb-1">{{ label }}<span v-if="required" class="text-red-500">*</span></label>
            <select :required="required"
                    class="border p-2 w-full rounded"
                    :value="modelValue"
                    @change="$emit('update:modelValue', $event.target.value)">
              <option :value="null" disabled>Select</option>
              <option v-for="option in options" :key="option.id" :value="option.id">
                {{ optionLabel ? option[optionLabel] : option.label }}
              </option>
            </select>
          </div>`
      }
    }
  }
  </script>
  
  <style scoped>
  .container {
    max-width: 850px;
  }
  </style>
  