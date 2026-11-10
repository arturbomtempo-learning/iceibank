<script setup lang="ts">
import { computed } from 'vue';

import { formatRatio, readableText } from '@/modules/brand/utils/contrast';
import { useClipboard } from '@/shared/composables/useClipboard';

const props = defineProps<{
    name: string;
    hex: string;
    caption?: string;
}>();

const { copy } = useClipboard();

const readable = computed(() => readableText(props.hex));
</script>

<template>
    <button
        type="button"
        class="swatch group card flex w-full cursor-pointer flex-col overflow-hidden text-left"
        :aria-label="`Copiar a cor ${name}, ${hex}`"
        @click="copy(hex.toUpperCase(), `O código ${hex.toUpperCase()}`)"
    >
        <span
            class="flex h-20 w-full items-end justify-between gap-2 p-3"
            :style="{ backgroundColor: hex, color: readable.color }"
        >
            <span class="display text-sm font-bold">{{ name }}</span>
            <span
                class="numeric text-[0.6875rem] font-semibold opacity-85"
                :title="`Contraste ${formatRatio(readable.ratio)}`"
            >
                {{ readable.level }}
            </span>
        </span>

        <span class="flex w-full items-start justify-between gap-2 p-3">
            <span class="min-w-0">
                <span class="numeric block text-[0.8125rem] font-semibold uppercase">
                    {{ hex }}
                </span>
                <span v-if="caption" class="mt-0.5 block text-xs text-muted">{{ caption }}</span>
            </span>

            <svg
                class="swatch__icon mt-0.5 h-4 w-4 shrink-0"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.9"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
            >
                <rect x="9" y="9" width="12" height="12" rx="2.5" />
                <path
                    d="M5 15H4.5A1.5 1.5 0 0 1 3 13.5v-9A1.5 1.5 0 0 1 4.5 3h9A1.5 1.5 0 0 1 15 4.5V5"
                />
            </svg>
        </span>
    </button>
</template>

<style scoped>
.swatch {
    transition:
        border-color 0.18s var(--ease-out),
        box-shadow 0.18s var(--ease-out),
        transform 0.18s var(--ease-out);
}

.swatch:hover {
    border-color: var(--color-border-strong);
    box-shadow: var(--shadow);
    transform: translateY(-2px);
}

.swatch__icon {
    color: var(--color-text-muted);
    opacity: 0;
    transition: opacity 0.18s var(--ease-out);
}

.swatch:hover .swatch__icon,
.swatch:focus-visible .swatch__icon {
    opacity: 1;
}

@media (hover: none) {
    .swatch__icon {
        opacity: 1;
    }
}

@media (prefers-reduced-motion: reduce) {
    .swatch:hover {
        transform: none;
    }
}
</style>
