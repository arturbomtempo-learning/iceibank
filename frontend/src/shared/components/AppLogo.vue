<script setup lang="ts">
withDefaults(
    defineProps<{
        variant?: 'light' | 'dark';
        size?: 'sm' | 'md' | 'lg';
    }>(),
    { variant: 'dark', size: 'md' }
);

const textSizes = { sm: 'text-lg', md: 'text-xl', lg: 'text-3xl' } as const;
</script>

<template>
    <span
        class="font-bold tracking-tight"
        :class="[textSizes[size], variant === 'light' ? 'text-white' : '']"
        :style="variant === 'dark' ? { color: 'var(--color-sidebar-bg)' } : undefined"
    >
        ICEI<span :style="{ color: 'var(--color-primary)' }">Bank</span>
    </span>
</template>
