<script setup lang="ts">
defineProps<{
    title: string;
    subtitle?: string;
    /** Agrupa a operação (Movimentação, Transferência, Gerência). */
    group?: string;
    /** Caminho de um ícone de traço 24x24. */
    icon?: string;
}>();
</script>

<template>
    <header>
        <div class="flex items-center gap-4">
            <span v-if="icon" class="op-glyph">
                <svg
                    class="h-5 w-5"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.9"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    aria-hidden="true"
                >
                    <path :d="icon" />
                </svg>
            </span>

            <div>
                <p v-if="group" class="eyebrow">{{ group }}</p>
                <h1 class="mt-0.5 text-2xl sm:text-[1.875rem]">{{ title }}</h1>
            </div>
        </div>

        <p v-if="subtitle" class="mt-4 max-w-2xl text-sm text-muted">{{ subtitle }}</p>
    </header>
</template>
