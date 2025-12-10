<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 px-4 py-12">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-2xl">
      <h2 class="text-3xl font-bold mb-2 text-center text-gray-800">Create Account</h2>
      <p class="text-center text-gray-500 mb-8 text-sm">Join to register for tournaments and track your history.</p>

      <div v-if="success" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4">
        <strong class="font-bold">Success!</strong>
        <span class="block sm:inline"> {{ successMessage }}</span>
        <div class="mt-4 text-center">
          <router-link to="/participant-login" class="bg-green-600 text-white px-6 py-2 rounded hover:bg-green-700 font-bold">
            Go to Login
          </router-link>
        </div>
      </div>

      <form v-else @submit.prevent="handleSignup">
        
        <!-- Personal Info -->
        <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2">Personal Details</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <InputField label="First Name" v-model="form.first_name" required />
          <InputField label="Last Name" v-model="form.last_name" required />
          
          <InputField label="Date of Birth" v-model="form.birthdate" type="date" required />
          <SelectField label="Gender" v-model="form.gender" :options="genderOptions" required />
          
          <InputField label="Phone Number" v-model="form.phone" type="tel" />
        </div>

        <!-- Address -->
        <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2 mt-6">Address</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div class="md:col-span-2">
            <InputField label="Street Address" v-model="form.street" required />
          </div>
          <InputField label="City" v-model="form.city" required />
          <InputField label="State / Province" v-model="form.state" required />
          <InputField label="ZIP / Postal Code" v-model="form.zip_code" required />
          <SelectField label="Country" v-model="form.country" :options="countryOptions" required />
        </div>

        <!-- Account Security -->
        <h3 class="text-lg font-bold text-gray-700 mb-4 border-b pb-2 mt-6">Account Security</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <InputField label="Email Address" v-model="form.email" type="email" required />
          <InputField label="Password" v-model="form.password" type="password" required />
        </div>

        <button type="submit" :disabled="loading" class="w-full bg-blue-600 text-white font-bold p-3 rounded-lg hover:bg-blue-700 transition disabled:opacity-50 mt-4 shadow-md">
          {{ loading ? 'Creating Account...' : 'Create Account' }}
        </button>
      </form>

      <p v-if="error" class="mt-4 text-red-500 text-center bg-red-50 p-2 rounded border border-red-100">{{ error }}</p>

      <div class="mt-8 text-center border-t pt-4 text-sm">
        <p class="text-gray-600">Already have an account?</p>
        <router-link to="/participant-login" class="text-blue-600 font-bold hover:underline">Log In</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from '../axios';
import InputField from '../components/InputField.vue';
import SelectField from '../components/SelectField.vue';

const form = ref({ 
  first_name: '', last_name: '', email: '', password: '',
  birthdate: '', gender: '', phone: '',
  street: '', city: '', state: '', zip_code: '', country: 'USA'
});

const loading = ref(false);
const error = ref('');
const success = ref(false);
const successMessage = ref('');

const genderOptions = [
  { value: 'M', label: 'Male' },
  { value: 'F', label: 'Female' },
  { value: 'O', label: 'Other' }
];

const countryOptions = [
  { value: 'USA', label: 'United States' },
  { value: 'CAN', label: 'Canada' },
  { value: 'MEX', label: 'Mexico' },
  { value: 'BRA', label: 'Brazil' },
  { value: 'GBR', label: 'United Kingdom' },
  { value: 'FRA', label: 'France' },
  { value: 'DEU', label: 'Germany' },
  { value: 'CHN', label: 'China' },
  { value: 'JPN', label: 'Japan' },
  { value: 'IND', label: 'India' },
  { value: 'Other', label: 'Other' }
];

const handleSignup = async () => {
  loading.value = true;
  error.value = '';
  try {
    const res = await axios.post('/auth/signup', form.value);
    successMessage.value = res.data.message;
    success.value = true;
    window.scrollTo(0,0);
  } catch (err) {
    error.value = err.response?.data?.error || 'Signup failed. Please try again.';
  } finally {
    loading.value = false;
  }
};
</script>