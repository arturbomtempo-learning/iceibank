<script setup lang="ts">
import { useToastStore, type ToastVariant } from '@/shared/stores/toast.store';

const toastStore = useToastStore();

const accentByVariant: Record<ToastVariant, string> = {
    success: 'var(--color-success)',
    error: 'var(--color-danger)',
    info: 'var(--color-info)',
};
</script>

<template>
    <div
        class="pointer-events-none fixed inset-x-0 top-0 z-50 flex flex-col items-center gap-2 p-4 sm:inset-x-auto sm:right-0 sm:items-end sm:pt-20"
    >
        <TransitionGroup
            enter-active-class="transition duration-200 ease-out"
            enter-from-class="opacity-0 -translate-y-2"
            leave-active-class="transition duration-150 ease-in"
            leave-to-class="opacity-0 translate-x-2"
        >
            <div
                v-for="toast in toastStore.toasts"
                :key="toast.id"
                class="card pointer-events-auto flex w-full max-w-sm items-start gap-3 overflow-hidden p-3.5 pl-4"
                :style="{
                    boxShadow: 'var(--shadow-lg)',
                    borderLeft: `3px solid ${accentByVariant[toast.variant]}`,
                }"
            >
                <div class="min-w-0 flex-1">
                    <p class="text-sm font-semibold">{{ toast.title }}</p>
                    <p v-if="toast.description" class="mt-0.5 text-[0.8125rem] text-muted">
                        {{ toast.description }}
                    </p>
                </div>

                <button
                    type="button"
                    class="-mt-0.5 shrink-0 cursor-pointer rounded p-1 text-lg leading-none transition-colors"
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
