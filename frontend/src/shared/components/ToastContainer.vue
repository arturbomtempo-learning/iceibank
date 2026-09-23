<script setup lang="ts">
import { useToastStore, type ToastVariant } from '@/shared/stores/toast.store';

const toastStore = useToastStore();

const accentByVariant: Record<ToastVariant, string> = {
    success: 'var(--color-success)',
    error: 'var(--color-danger)',
    info: 'var(--color-brand-500)',
};

const surfaceByVariant: Record<ToastVariant, string> = {
    success: 'var(--color-success-soft)',
    error: 'var(--color-danger-soft)',
    info: 'var(--color-primary-soft)',
};

const iconByVariant: Record<ToastVariant, string> = {
    success: 'm4 12.5 5 5L20 6.5',
    error: 'M12 8v5M12 16.5h.01M12 3 2.5 20h19L12 3Z',
    info: 'M12 16v-5M12 8h.01M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z',
};
</script>

<template>
    <div
        class="pointer-events-none fixed inset-x-0 top-0 z-50 flex flex-col items-center gap-2.5 p-4 sm:inset-x-auto sm:right-0 sm:items-end sm:pt-24 sm:pr-6"
    >
        <TransitionGroup
            enter-active-class="transition duration-250 ease-out"
            enter-from-class="opacity-0 -translate-y-3 scale-[0.97]"
            leave-active-class="transition duration-150 ease-in absolute"
            leave-to-class="opacity-0 translate-x-3"
            move-class="transition duration-200 ease-out"
        >
            <div
                v-for="toast in toastStore.toasts"
                :key="toast.id"
                class="card pointer-events-auto flex w-full max-w-sm items-start gap-3 p-4"
                :style="{ boxShadow: 'var(--shadow-lg)' }"
            >
                <span
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full"
                    :style="{ backgroundColor: surfaceByVariant[toast.variant] }"
                >
                    <svg
                        class="h-[17px] w-[17px]"
                        viewBox="0 0 24 24"
                        fill="none"
                        :stroke="accentByVariant[toast.variant]"
                        stroke-width="2.2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >
                        <path :d="iconByVariant[toast.variant]" />
                    </svg>
                </span>

                <div class="min-w-0 flex-1">
                    <p class="display text-sm font-bold">{{ toast.title }}</p>
                    <p v-if="toast.description" class="mt-1 text-[0.8125rem] text-muted">
                        {{ toast.description }}
                    </p>
                </div>

                <button
                    type="button"
                    class="-mt-0.5 shrink-0 cursor-pointer rounded-lg p-1 text-lg leading-none transition-colors hover:bg-[var(--color-surface-hover)]"
                    :style="{ color: 'var(--color-text-muted)' }"
                    aria-label="Fechar aviso"
                    @click="toastStore.dismiss(toast.id)"
                >
                    &times;
                </button>
            </div>
        </TransitionGroup>
    </div>
</template>
