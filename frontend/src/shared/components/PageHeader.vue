<script setup lang="ts">
defineProps<{
    title: string;
    subtitle?: string;
}>();
</script>

<template>
    <header class="flex flex-col gap-1.5">
        <h1 class="text-[1.75rem] sm:text-[2rem]">{{ title }}</h1>
        <p v-if="subtitle" class="max-w-2xl text-sm text-muted">{{ subtitle }}</p>
    </header>
</template>
