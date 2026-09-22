<script setup lang="ts">
import { computed, useId } from 'vue';

const props = withDefaults(
    defineProps<{
        variant?: 'light' | 'dark';
        size?: 'sm' | 'md' | 'lg';
        markOnly?: boolean;
    }>(),
    { variant: 'dark', size: 'md', markOnly: false }
);

const gradientId = useId();

const sizes = {
    sm: { mark: 28, text: 'text-[1.0625rem]' },
    md: { mark: 32, text: 'text-xl' },
    lg: { mark: 42, text: 'text-[1.75rem]' },
} as const;

const markSize = computed(() => sizes[props.size].mark);

const textSize = computed(() => sizes[props.size].text);
</script>

<template>
    <span class="inline-flex items-center gap-2.5 align-middle">
        <svg
            :width="markSize"
            :height="markSize"
            viewBox="0 0 40 40"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            role="img"
            aria-label="ICEIBank"
            class="shrink-0"
        >
            <defs>
                <linearGradient :id="gradientId" x1="0" y1="0" x2="40" y2="40">
                    <stop offset="0%" stop-color="var(--color-brand-400)" />
                    <stop offset="55%" stop-color="var(--color-brand-600)" />
                    <stop offset="100%" stop-color="var(--color-brand-800)" />
                </linearGradient>
            </defs>

            <rect width="40" height="40" rx="12" :fill="`url(#${gradientId})`" />

            <g transform="rotate(-45 20 20)" fill="#ffffff">
                <rect x="8" y="9.6" width="24" height="4.6" rx="2.3" />
                <rect x="11" y="17.7" width="18" height="4.6" rx="2.3" opacity="0.82" />
                <rect x="14" y="25.8" width="12" height="4.6" rx="2.3" opacity="0.6" />
            </g>
        </svg>

        <span
            v-if="!markOnly"
            class="display font-extrabold"
            :class="[textSize, variant === 'light' ? 'text-white' : '']"
            :style="variant === 'dark' ? { color: 'var(--color-text)' } : undefined"
        >
            ICEI<span
                :style="{
                    color: variant === 'light' ? 'var(--color-accent)' : 'var(--color-primary)',
                }"
                >Bank</span
            >
        </span>
    </span>
</template>
