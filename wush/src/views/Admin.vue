<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-6">Admin Dashboard</h1>
    
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <button
        @click="$router.push('/admin/registrations')"
        class="bg-indigo-600 text-white px-6 py-4 rounded shadow hover:bg-indigo-700 text-lg font-semibold"
      >
        Manage Registrations (Queue)
      </button>

      <button
        @click="$router.push('/admin/tournaments')"
        class="bg-blue-600 text-white px-6 py-4 rounded shadow hover:bg-blue-700 text-lg font-semibold"
      >
        Manage Tournaments
      </button>

      <button
        @click="$router.push('/admin/schools')"
        class="bg-blue-500 text-white px-6 py-4 rounded shadow hover:bg-blue-600 text-lg font-semibold"
      >
        Manage Schools
      </button>
      
      <button
        @click="$router.push('/admin/participants')"
        class="bg-blue-500 text-white px-6 py-4 rounded shadow hover:bg-blue-600 text-lg font-semibold"
      >
        Manage Participants (Roster)
      </button>
      
      <button
        @click="$router.push('/admin/divisions')"
        class="bg-blue-500 text-white px-6 py-4 rounded shadow hover:bg-blue-600 text-lg font-semibold"
      >
        Manage Divisions
      </button>
    </div>

    <button
      @click="logout"
      class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 mt-8"
    >
      Logout
    </button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const openSchoolManagement = () => {
  router.push('/admin/schools');
};

const openParticipantManagement = () => {
  router.push('/admin/participants');
};

const openDivisionManagement = () => {
  router.push('/admin/divisions');
};

const openTournamentManagement = () => {
  router.push('/admin/tournaments');
};

const openRegistrationLink = () => {
  const token = 'e64077fe-9b62-4be0-a4d1-11e1a5620c38';
  router.push(`/register/${token}`);
};

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/login');
};
</script>

<style scoped>
/* Add any specific styles if needed */
</style>