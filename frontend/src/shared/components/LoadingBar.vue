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
            class="fixed inset-x-0 top-0 z-60 h-0.5 overflow-hidden"
            role="status"
            aria-label="Carregando"
        >
            <div
                class="h-full w-2/5 animate-[loading-slide_1.1s_ease-in-out_infinite]"
                :style="{
                    background:
                        'linear-gradient(90deg, transparent, var(--color-primary), var(--color-primary-light))',
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
