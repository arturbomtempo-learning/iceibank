<script setup lang="ts">
defineProps<{
    title: string;
    subtitle?: string;
}>();
</script>

<template>
    <header class="flex flex-col gap-1">
        <h1 class="text-2xl font-semibold sm:text-[1.75rem]">{{ title }}</h1>
        <p v-if="subtitle" class="text-sm text-muted">{{ subtitle }}</p>
    </header>
</template>
