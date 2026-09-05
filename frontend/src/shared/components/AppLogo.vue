<script setup lang="ts">
withDefaults(
    defineProps<{
        variant?: 'light' | 'dark';
        size?: 'sm' | 'md' | 'lg';
    }>(),
    { variant: 'dark', size: 'md' }
);

const markSizes = { sm: 'h-7', md: 'h-9', lg: 'h-12' } as const;
const textSizes = { sm: 'text-base', md: 'text-lg', lg: 'text-2xl' } as const;
</script>

<template>
    <div class="flex items-center gap-2.5">
        <svg
            :class="markSizes[size]"
            viewBox="0 0 72 40"
            fill="none"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
        >
            <rect x="0" y="4" width="9" height="32" rx="4.5" fill="var(--color-primary)" />
            <path
                d="M31.2 13.9A9 9 0 1 0 31.2 26.1"
                stroke="var(--color-primary)"
                stroke-width="8.5"
                stroke-linecap="round"
            />
            <rect x="37" y="5.5" width="26" height="8" rx="4" fill="var(--color-primary)" />
            <rect x="37" y="16" width="26" height="8" rx="4" fill="var(--color-primary)" />
            <rect x="37" y="26.5" width="26" height="8" rx="4" fill="var(--color-primary)" />
            <rect x="63" y="4" width="9" height="32" rx="4.5" fill="var(--color-primary)" />
        </svg>

        <span
            class="font-bold tracking-tight"
            :class="textSizes[size]"
            :style="{ color: variant === 'light' ? '#ffffff' : 'var(--color-sidebar-bg)' }"
        >
            ICEI<span :style="{ color: 'var(--color-primary)' }">Bank</span>
        </span>
    </div>
</template>
