<script setup lang="ts">
import { useUiStore } from '@/shared/stores/ui.store';

const uiStore = useUiStore();
</script>

<template>
    <Transition
        enter-active-class="transition-opacity duration-150"
        enter-from-class="opacity-0"
        leave-active-class="transition-opacity duration-300"
        leave-to-class="opacity-0"
    >
        <div
            v-if="uiStore.isLoading"
            class="fixed inset-x-0 top-0 z-60 h-[3px] overflow-hidden"
            role="status"
            aria-label="Carregando"
        >
            <div
                class="h-full w-2/5 animate-[loading-slide_1.1s_ease-in-out_infinite]"
                :style="{
                    background:
                        'linear-gradient(90deg, transparent, var(--color-brand-500), var(--color-accent))',
                    boxShadow: '0 0 12px rgba(47, 193, 135, 0.7)',
                }"
            />
        </div>
    </Transition>
</template>

<style>
@keyframes loading-slide {
    0% {
        transform: translateX(-100%);
    }
    100% {
        transform: translateX(350%);
    }
}
</style>
