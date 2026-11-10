<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection.vue';
import { principles } from '@/modules/brand/data/brand.data';

defineProps<{ id: string; ordinal: string }>();
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Princípios"
        title="O que guia cada decisão de interface"
        description="Um banco pede confiança antes de pedir atenção. Estes quatro princípios orientam desde a escolha de uma cor até a frase de uma mensagem de erro."
    >
        <ol class="grid gap-4 sm:grid-cols-2">
            <li v-for="(principle, index) in principles" :key="principle.title" class="card p-6">
                <p class="ordinal">{{ String(index + 1).padStart(2, '0') }}</p>
                <h3 class="mt-3 text-[1.125rem]">{{ principle.title }}</h3>
                <p class="mt-2 text-sm text-muted">{{ principle.description }}</p>
            </li>
        </ol>
    </BrandSection>
</template>
