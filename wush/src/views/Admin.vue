<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Admin Dashboard</h1>
    <button
      @click="openSchoolManagement"
      class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
    >
      Manage Schools
    </button>
    <!-- Add other management buttons here later -->
  </div>
</template>

<script>
export default {
  methods: {
    openSchoolManagement() {
      this.$router.push('/admin/schools');
    },
  },
};
</script>

<style scoped>
/* Add any specific styles if needed */
</style>