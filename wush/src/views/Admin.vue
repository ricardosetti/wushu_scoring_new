<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>
    <button
      @click="openSchoolManagement"
      class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mr-2"
    >
      Manage Schools
    </button>
    <button
      @click="openParticipantManagement"
      class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mr-2"
    >
      Manage Participants
    </button>
    <button
      @click="openDivisionManagement"
      class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mr-2"
    >
      Manage Divisions
    </button>
    <button
      @click="openRegistrationLink"
      class="bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600"
    >
      Test Registration Link
    </button>

    <button
      @click="logout"
      class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 mt-4"
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

const openRegistrationLink = () => {
  // Replace this token if needed in the future
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
