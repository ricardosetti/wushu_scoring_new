<template>
  <div v-if="loading" class="min-h-screen flex items-center justify-center">Loading...</div>
  <div v-else-if="!tournament" class="min-h-screen flex items-center justify-center">Tournament not found.</div>
  
  <div v-else class="min-h-screen flex flex-col" :style="{ backgroundColor: tournament.color_background || '#F3F4F6' }">
    <div class="relative bg-white shadow-md">
      <div class="container mx-auto px-4 py-12 flex flex-col items-center text-center">
        <img v-if="tournament.tournament_logo" :src="tournament.tournament_logo" class="h-32 w-auto mb-6 object-contain" />
        
        <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4">{{ tournament.tournament_title }}</h1>
        
        <p class="text-xl text-gray-600 mb-8 font-medium">
          {{ formatDate(tournament.tournament_start_date) }} • {{ tournament.tournament_city }}, {{ tournament.tournament_state }}
        </p>

        <button 
          @click="goToRegister"
          class="px-8 py-4 rounded-full text-white font-bold text-xl shadow-lg transform transition hover:scale-105"
          :style="{ backgroundColor: tournament.color_primary || '#1E40AF' }"
        >
          Register Now
        </button>
      </div>
    </div>

    <div class="container mx-auto px-4 py-12 flex-grow grid grid-cols-1 md:grid-cols-3 gap-8">
      <div class="md:col-span-2 bg-white p-8 rounded-xl shadow-sm">
        <h2 class="text-2xl font-bold mb-4 text-gray-800">Event Details</h2>
        <p v-if="!tournament.details_content" class="text-gray-500 italic">No additional details provided.</p>
        <div v-else class="prose max-w-none whitespace-pre-wrap text-gray-700">
          {{ tournament.details_content }}
        </div>
      </div>

      <div class="space-y-6">
        <div class="bg-white p-6 rounded-xl shadow-sm">
          <h3 class="text-lg font-bold mb-4 text-gray-800">Location</h3>
          <p class="text-gray-600 mb-4">{{ fullAddress }}</p>
          
          <div class="w-full h-64 bg-gray-200 rounded-lg overflow-hidden">
            <iframe
              width="100%"
              height="100%"
              style="border:0"
              loading="lazy"
              allowfullscreen
              :src="`https://maps.google.com/maps?q=${encodedAddress}&t=&z=13&ie=UTF8&iwloc=&output=embed`">
            </iframe>
          </div>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-sm">
          <h3 class="text-lg font-bold mb-4 text-gray-800">Contact Info</h3>
          <p v-if="tournament.tournament_contact" class="mb-2"><strong>Name:</strong> {{ tournament.tournament_contact }}</p>
          <p v-if="tournament.tournament_email" class="mb-2"><strong>Email:</strong> {{ tournament.tournament_email }}</p>
        </div>
      </div>
    </div>

    <footer class="bg-gray-800 text-white py-8 text-center">
      <p>&copy; {{ new Date().getFullYear() }} {{ tournament.tournament_title }}</p>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from '../axios';

const route = useRoute();
const router = useRouter();
const tournament = ref(null);
const loading = ref(true);

const fullAddress = computed(() => {
  if (!tournament.value) return '';
  return `${tournament.value.tournament_address}, ${tournament.value.tournament_city}, ${tournament.value.tournament_state}`;
});

const encodedAddress = computed(() => {
  return encodeURIComponent(fullAddress.value);
});

const formatDate = (d) => d ? new Date(d).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) : 'TBD';

const goToRegister = () => {
  if (tournament.value) {
    // Navigate to register page with the specific tournament ID
    router.push(`/register?tournament_id=${tournament.value.tournament_id}`);
  }
};

onMounted(async () => {
  try {
    const { id } = route.params;
    const res = await axios.get(`/tournaments/${id}`);
    tournament.value = res.data;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
});
</script>