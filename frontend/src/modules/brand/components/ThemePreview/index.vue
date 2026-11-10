<script setup lang="ts">
import { computed } from 'vue';

import { themeVariables } from '@/modules/brand/data/brand.data';
import type { Theme } from '@/shared/stores/theme.store';

const props = defineProps<{ theme: Theme }>();

const label = computed(() => (props.theme === 'dark' ? 'Tema escuro' : 'Tema claro'));

const variables = computed(() => themeVariables(props.theme));
</script>

<template>
    <figure
        class="preview overflow-hidden border p-4 sm:p-5"
        :style="variables"
        :aria-label="`Prévia do ${label.toLowerCase()}`"
    >
        <figcaption class="flex items-center justify-between gap-3">
            <span class="display text-sm font-bold">{{ label }}</span>
            <span class="badge">{{ theme === 'dark' ? 'data-theme="dark"' : 'padrão' }}</span>
        </figcaption>

        <div
            class="surface-ink relative mt-4 overflow-hidden p-5"
            :style="{ borderRadius: 'var(--radius-card)' }"
        >
            <div class="grain pointer-events-none absolute inset-0 opacity-60" />
            <div class="relative z-10 flex items-start justify-between gap-3">
                <div class="min-w-0">
                    <p class="eyebrow eyebrow-onink">Saldo disponível</p>
                    <p class="display numeric mt-1.5 text-[1.625rem] leading-none font-extrabold">
                        R$ 3.750,00
                    </p>
                </div>
                <span class="badge badge-onink shrink-0">Agência 0</span>
            </div>
        </div>

        <div class="card mt-3 p-4">
            <label class="text-[0.8125rem] font-semibold" :for="`preview-value-${theme}`">
                Valor da transferência
            </label>
            <input
                :id="`preview-value-${theme}`"
                class="input mt-1.5"
                value="R$ 250,00"
                readonly
                tabindex="-1"
            />
            <div class="mt-3 flex flex-wrap gap-2">
                <span class="btn pointer-events-none px-4 py-2 text-sm">Transferir</span>
                <span class="btn btn-secondary pointer-events-none px-4 py-2 text-sm">
                    Cancelar
                </span>
            </div>
        </div>

        <div class="mt-3 flex flex-wrap gap-2">
            <span class="badge badge-success">Concluída</span>
            <span class="badge badge-primary">Mesma agência</span>
            <span class="badge badge-danger">Indisponível</span>
        </div>

        <p class="note note-brand mt-3">O extrato soma as contas das três agências.</p>
    </figure>
</template>

<style scoped>
.preview {
    margin: 0;
    border-color: var(--color-border);
    border-radius: var(--radius-xl);
    background-color: var(--color-bg);
    color: var(--color-text);
}
</style>
