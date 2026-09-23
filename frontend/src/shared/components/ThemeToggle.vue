<script setup lang="ts">
import { computed } from 'vue';

import { useThemeStore } from '@/shared/stores/theme.store';

withDefaults(defineProps<{ variant?: 'default' | 'onink' }>(), { variant: 'default' });

const themeStore = useThemeStore();

const label = computed(() =>
    themeStore.isDark ? 'Mudar para o tema claro' : 'Mudar para o tema escuro'
);
</script>

<template>
    <button
        type="button"
        class="theme-toggle"
        :class="[`theme-toggle--${variant}`, { 'theme-toggle--dark': themeStore.isDark }]"
        :title="label"
        :aria-label="label"
        :aria-pressed="themeStore.isDark"
        @click="themeStore.toggle()"
    >
        <span class="theme-toggle__icons">
            <svg
                class="theme-toggle__icon theme-toggle__icon--sun"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.9"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
            >
                <circle cx="12" cy="12" r="4.2" />
                <path
                    d="M12 2.5v2.2M12 19.3v2.2M4.2 4.2l1.6 1.6M18.2 18.2l1.6 1.6M2.5 12h2.2M19.3 12h2.2M4.2 19.8l1.6-1.6M18.2 5.8l1.6-1.6"
                />
            </svg>

            <svg
                class="theme-toggle__icon theme-toggle__icon--moon"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.9"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
            >
                <path d="M20.4 14.2A8.6 8.6 0 0 1 9.8 3.6a8.6 8.6 0 1 0 10.6 10.6Z" />
            </svg>
        </span>
    </button>
</template>

<style scoped>
.theme-toggle {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2.375rem;
    height: 2.375rem;
    flex-shrink: 0;
    border: 1px solid transparent;
    border-radius: var(--radius);
    cursor: pointer;
    transition:
        background-color 0.18s var(--ease-out),
        border-color 0.18s var(--ease-out),
        color 0.18s var(--ease-out);
}

.theme-toggle--default {
    background-color: transparent;
    border-color: var(--color-border);
    color: var(--color-text-muted);
}

.theme-toggle--default:hover {
    background-color: var(--color-surface-hover);
    border-color: var(--color-border-strong);
    color: var(--color-text);
}

.theme-toggle--onink {
    background-color: rgba(255, 255, 255, 0.06);
    border-color: var(--color-ink-line);
    color: var(--color-ink-muted);
}

.theme-toggle--onink:hover {
    background-color: rgba(255, 255, 255, 0.12);
    color: #ffffff;
}

.theme-toggle__icons {
    position: relative;
    display: block;
    width: 1.125rem;
    height: 1.125rem;
}

.theme-toggle__icon {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    transition:
        opacity 0.28s var(--ease-out),
        transform 0.38s var(--ease-out);
}

.theme-toggle__icon--sun {
    opacity: 1;
    transform: rotate(0deg) scale(1);
}

.theme-toggle__icon--moon {
    opacity: 0;
    transform: rotate(-70deg) scale(0.55);
}

.theme-toggle--dark .theme-toggle__icon--sun {
    opacity: 0;
    transform: rotate(70deg) scale(0.55);
}

.theme-toggle--dark .theme-toggle__icon--moon {
    opacity: 1;
    transform: rotate(0deg) scale(1);
}

@media (prefers-reduced-motion: reduce) {
    .theme-toggle__icon {
        transition: opacity 0.12s linear;
        transform: none !important;
    }
}
</style>
