<template>
  <div>
    <nav class="bg-darkgray p-4">
      <router-link to="/head-judge" class="text-white mx-2">Head Judge</router-link>
      <router-link to="/judge-a1" class="text-white mx-2">Judge A1</router-link>
      <router-link to="/judge-a2" class="text-white mx-2">Judge A2</router-link>
      <router-link to="/judge-b1" class="text-white mx-2">Judge B1</router-link>
      <router-link to="/judge-b2" class="text-white mx-2">Judge B2</router-link>
      <router-link to="/scoreboard" class="text-white mx-2">Scoreboard</router-link>
      <router-link to="/admin" class="text-white mx-2">Admin</router-link>
    </nav>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
}
</script>

<style>
/* Existing styles */
</style>