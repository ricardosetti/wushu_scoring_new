<template>
    <div>
      <label class="block mb-1">{{ label }}<span v-if="required" class="text-red-500">*</span></label>
      <select
        :required="required"
        class="border p-2 w-full rounded"
        :value="modelValue"
        @change="$emit('update:modelValue', $event.target.value)"
      >
        <option value="" disabled>Select</option>
        <option v-for="option in options" :key="option.value" :value="option.value">
          {{ option.label }}
        </option>
      </select>
    </div>
  </template>
  
  <script setup>
  defineProps(['label', 'modelValue', 'options', 'required']);
  defineEmits(['update:modelValue']);
  </script>