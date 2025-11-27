<template>
  <div class="container mx-auto p-4 max-w-4xl">
    <div class="bg-white p-8 rounded-lg shadow-lg">
      <h2 class="text-3xl font-bold mb-2 text-center text-blue-800">Tournament Registration</h2>
      
      <div v-if="activeTournament" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 text-center">
        <p class="text-blue-800 font-medium uppercase tracking-wide text-xs">You are registering for</p>
        <h3 class="text-xl font-bold text-blue-900 mt-1">{{ activeTournament.tournament_title }}</h3>
        <p class="text-sm text-blue-600 mt-1">
          📅 {{ formatDate(activeTournament.tournament_start_date) }} • 📍 {{ activeTournament.tournament_city }}
        </p>
      </div>

      <div v-if="loading" class="text-center py-10 text-gray-500">
        <p>Loading details...</p>
      </div>
      
      <div v-else-if="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6" role="alert">
        <p class="font-bold">Error</p>
        <p>{{ error }}</p>
      </div>

      <form v-else @submit.prevent="handleSubmit">
        
        <div class="mb-8 p-4 bg-gray-50 rounded border border-gray-200">
          <div v-if="isTokenMode">
            <label class="block text-xs font-bold text-gray-500 uppercase">School (Locked via Invite)</label>
            <div class="text-lg font-bold text-gray-800 mt-1">{{ schoolNameDisplay }}</div>
          </div>

          <div v-else>
            <label class="block text-sm font-bold text-gray-700 mb-2">Select Your School *</label>
            <select 
              v-model="form.school_id" 
              required 
              class="w-full border border-gray-300 rounded-lg p-2.5 focus:ring-2 focus:ring-blue-500 outline-none bg-white"
            >
              <option :value="null" disabled>-- Choose a School --</option>
              <option v-for="s in availableSchools" :key="s.id" :value="s.id">
                {{ s.school_name }}
              </option>
            </select>
            <p class="text-xs text-gray-500 mt-2">
              * If you do not belong to a specific school, select <strong>Independent</strong>.
            </p>
          </div>
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Student Information</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <InputField label="First Name *" v-model="form.first_name" required />
          <InputField label="Middle Name" v-model="form.middle_name" />
          <InputField label="Last Name *" v-model="form.last_name" required />
          <InputField label="Rank / Belt Level" v-model="form.participant_rank" />
          
          <InputField label="Birthdate *" v-model="form.birthdate" type="date" required />
          <SelectField label="Gender *" v-model="form.gender" :options="genderOptions" required />
          
          <div class="flex gap-4">
             <InputField label="Height (ft)" v-model="form.height_feet" type="number" class="w-1/2" />
             <InputField label="Height (in)" v-model="form.height_inches" type="number" class="w-1/2" />
          </div>
          <InputField label="Weight (kg)" v-model="form.weight" type="number" step="0.1" />
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Contact Details</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <InputField label="Phone" v-model="form.phone" />
          <InputField label="Email Address *" v-model="form.email" type="email" required />
          
          <InputField label="Emergency Contact Name" v-model="form.emergency_contact_name" />
          <InputField label="Emergency Contact Phone" v-model="form.emergency_contact_phone" />
          
          <div class="md:col-span-2">
            <InputField label="Street Address" v-model="form.street" />
          </div>
          <InputField label="City" v-model="form.city" />
          <div class="flex gap-4">
            <InputField label="State" v-model="form.state" class="w-1/2" />
            <InputField label="Zip Code" v-model="form.zip_code" class="w-1/2" />
          </div>
          <InputField label="Country" v-model="form.country" />
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Account Setup</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
           <div>
             <InputField label="Create Password *" v-model="form.password" type="password" required />
             <p class="text-xs text-gray-500 mt-1">You will use this to log in and view your scores.</p>
           </div>
        </div>

        <h3 class="text-xl font-semibold mb-4 border-b pb-2 text-gray-700">Select Divisions</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 mb-8">
          <label 
            v-for="division in divisions" 
            :key="division.id" 
            class="flex items-center space-x-3 p-3 border rounded hover:bg-gray-50 cursor-pointer transition select-none"
            :class="{'border-blue-500 bg-blue-50': selectedDivisions.includes(division.id)}"
          >
            <input 
              type="checkbox" 
              :value="division.id" 
              v-model="selectedDivisions" 
              class="h-5 w-5 text-blue-600 rounded focus:ring-blue-500"
            />
            <span class="text-gray-700 font-medium">{{ division.division_name }}</span>
          </label>
        </div>

        <button 
          type="submit" 
          :disabled="submitting" 
          class="w-full bg-green-600 text-white font-bold text-lg py-3 rounded shadow hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ submitting ? 'Processing Registration...' : 'Submit Registration' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from '../axios';
import { useRoute, useRouter } from 'vue-router';
import InputField from '../components/InputField.vue';
import SelectField from '../components/SelectField.vue';

const route = useRoute();
const router = useRouter();

// Query Params
const token = ref(route.query.token || '');
const urlTournamentId = ref(route.query.tournament_id || '');

const form = ref({
  first_name: '', middle_name: '', last_name: '',
  birthdate: '', height_feet: null, height_inches: null, weight: null,
  gender: '', phone: '', emergency_contact_name: '', emergency_contact_phone: '',
  street: '', city: '', state: '', country: '', zip_code: '',
  participant_rank: '', email: '', password: '',
  school_id: null
});

const selectedDivisions = ref([]);
const divisions = ref([]);
const activeTournament = ref(null);
const availableSchools = ref([]);
const lockedSchool = ref(null); // For token mode

const error = ref('');
const loading = ref(true);
const submitting = ref(false);

const isTokenMode = computed(() => !!token.value);
const schoolNameDisplay = computed(() => lockedSchool.value ? lockedSchool.value.school_name : 'Loading...');

const genderOptions = [
  { value: 'M', label: 'Male' },
  { value: 'F', label: 'Female' },
  { value: 'O', label: 'Other' }
];

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : '';

const fetchInitialData = async () => {
  try {
    let tid = null;

    // --- 1. Determine Tournament & School ---
    if (isTokenMode.value) {
      // Mode A: Token (Invite)
      const schoolRes = await axios.get(`/register/validate-token?token=${token.value}`);
      lockedSchool.value = schoolRes.data.school;
      form.value.school_id = lockedSchool.value.id;
      
      // Token usually doesn't carry tournament ID explicitly in your schema (it links school to tournament), 
      // but we can assume Active tournament for now, or you could fetch it via the backend validation.
      // For safety, we look up the Active Tournament.
      const tourneyRes = await axios.get('/tournaments');
      activeTournament.value = tourneyRes.data.find(t => t.is_active) || tourneyRes.data[0];
      tid = activeTournament.value.tournament_id;

    } else {
      // Mode B: Public (Dropdown)
      if (urlTournamentId.value) {
        const tRes = await axios.get(`/tournaments/${urlTournamentId.value}`);
        activeTournament.value = tRes.data;
        tid = activeTournament.value.tournament_id;
      } else {
        // Fallback: Find active
        const tourneyRes = await axios.get('/tournaments');
        activeTournament.value = tourneyRes.data.find(t => t.is_active);
        if(activeTournament.value) tid = activeTournament.value.tournament_id;
      }

      if (!activeTournament.value) throw new Error("No active tournament found.");

      // Fetch Public Schools for this tournament
      const schoolsRes = await axios.get('/schools/public', { params: { tournament_id: tid } });
      availableSchools.value = schoolsRes.data;
    }

    // --- 2. Fetch Divisions for this Tournament ---
    const divRes = await axios.get('/divisions', {
      params: { tournament_id: tid } // Use the specific tournament ID we found
    });
    divisions.value = divRes.data;

  } catch (err) {
    console.error(err);
    error.value = err.response?.data?.error || err.message || 'Failed to load registration data.';
  } finally {
    loading.value = false;
  }
};

const handleSubmit = async () => {
  if (selectedDivisions.value.length === 0) {
    alert("Please select at least one division.");
    return;
  }
  if (!form.value.school_id) {
    alert("Please select a school.");
    return;
  }

  try {
    submitting.value = true;
    const payload = { 
      ...form.value, 
      divisions: selectedDivisions.value,
      tournament_id: activeTournament.value.tournament_id 
    };
    
    await axios.post('/register', payload);
    
    alert('Registration successful! You can now log in to view your profile.');
    router.push('/participant-login');
  } catch (err) {
    error.value = err.response?.data?.error || 'Registration failed.';
    window.scrollTo(0,0);
  } finally {
    submitting.value = false;
  }
};

onMounted(fetchInitialData);
</script>