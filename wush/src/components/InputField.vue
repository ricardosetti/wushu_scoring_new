<template>
    <div>
      <label class="block mb-1">{{ label }}<span v-if="required" class="text-red-500">*</span></label>
      <input
        :type="type || 'text'"
        :required="required"
        class="border p-2 w-full rounded"
        :value="modelValue"
        @input="$emit('update:modelValue', $event.target.value)"
      />
    </div>
  </template>
  
  <script setup>
  defineProps(['label', 'modelValue', 'type', 'required']);
  defineEmits(['update:modelValue']);
  </script>