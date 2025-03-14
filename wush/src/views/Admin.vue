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
      class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
    >
      Manage Divisions
    </button>
  </div>
</template>

<script>
export default {
  methods: {
    openSchoolManagement() {
      this.$router.push('/admin/schools');
    },
    openParticipantManagement() {
      this.$router.push('/admin/participants');
    },
    openDivisionManagement() {
      this.$router.push('/admin/divisions');
    },
  },
};
</script>

<style scoped>
/* Add any specific styles if needed */
</style>