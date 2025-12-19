<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
      <button
        @click="openSchoolManagement"
        class="bg-blue-500 text-white px-4 py-3 rounded hover:bg-blue-600 font-medium"
      >
        Manage Schools
      </button>
      <button
        @click="openParticipantManagement"
        class="bg-blue-500 text-white px-4 py-3 rounded hover:bg-blue-600 font-medium"
      >
        Manage Participants
      </button>
      <button
        @click="openDivisionManagement"
        class="bg-blue-500 text-white px-4 py-3 rounded hover:bg-blue-600 font-medium"
      >
        Manage Divisions
      </button>
      <button
        @click="openTournamentManagement"
        class="bg-blue-500 text-white px-4 py-3 rounded hover:bg-blue-600 font-medium"
      >
        Manage Tournaments
      </button>

      <!-- User Administration -->
      <button
        @click="openUserManagement"
        class="bg-indigo-600 text-white px-4 py-3 rounded hover:bg-indigo-700 font-medium"
      >
        User Administration
      </button>

      <!-- NEW BUTTON: Roster Management -->
      <button
        @click="openRosterManagement"
        class="bg-teal-600 text-white px-4 py-3 rounded hover:bg-teal-700 font-medium"
      >
        Manage Rosters
      </button>
      
      <button
        @click="openRegistrationLink"
        class="bg-purple-500 text-white px-4 py-3 rounded hover:bg-purple-600 font-medium"
      >
        Test Registration Link
      </button>
    </div>

    <div class="border-t pt-4">
      <button
        @click="logout"
        class="bg-red-500 text-white px-6 py-2 rounded hover:bg-red-600"
      >
        Logout
      </button>
    </div>
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

const openUserManagement = () => {
  router.push('/admin/users');
};

// NEW FUNCTION
const openRosterManagement = () => {
  router.push('/admin/roster');
};

const openRegistrationLink = () => {
  // You might want to make this dynamic or remove it if not needed anymore
  const token = 'e64077fe-9b62-4be0-a4d1-11e1a5620c38'; 
  router.push(`/register?token=${token}`); 
};

const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  router.push('/login');
};
</script>