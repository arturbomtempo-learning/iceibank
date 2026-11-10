<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import { brandIcons } from '@/modules/brand/data/brand.data';

defineOptions({ name: 'IconSection' });

defineProps<{ id: string; ordinal: string }>();

const specs = [
    { label: 'Grade', value: '24 × 24' },
    { label: 'Traço', value: '1,9 px' },
    { label: 'Pontas', value: 'Arredondadas' },
    { label: 'Preenchimento', value: 'Nenhum' },
];
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Iconografia"
        title="Ícones de traço, legíveis em qualquer tamanho"
        description="Os ícones são desenhados em linha contínua, com a mesma espessura do texto em peso médio. Eles sempre acompanham um rótulo ou um nome acessível."
    >
        <dl class="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <div v-for="spec in specs" :key="spec.label" class="card p-4">
                <dt class="text-xs text-muted">{{ spec.label }}</dt>
                <dd class="display mt-1 text-[1.0625rem] font-bold">{{ spec.value }}</dd>
            </div>
        </dl>

        <ul class="mt-4 grid grid-cols-3 gap-3 sm:grid-cols-4 lg:grid-cols-6">
            <li
                v-for="icon in brandIcons"
                :key="icon.name"
                class="card flex flex-col items-center gap-3 px-2 py-5 text-center"
            >
                <svg
                    class="h-6 w-6"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.9"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    aria-hidden="true"
                >
                    <path :d="icon.path" />
                </svg>
                <span class="text-xs text-muted">{{ icon.name }}</span>
            </li>
        </ul>

        <div class="mt-4 flex flex-wrap items-center gap-4">
            <span v-for="icon in brandIcons.slice(0, 4)" :key="icon.name" class="op-glyph">
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
                    <path :d="icon.path" />
                </svg>
            </span>
            <p class="min-w-0 flex-1 basis-60 text-sm text-muted">
                Sobre a tinta, os ícones ganham a cor menta, como no glifo de operação e no item
                ativo do menu.
            </p>
        </div>
    </BrandSection>
</template>
