<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import { voiceGuidelines } from '@/modules/brand/data/brand.data';

defineOptions({ name: 'VoiceSection' });

defineProps<{ id: string; ordinal: string }>();
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Voz e tom"
        title="Escrever como quem cuida do dinheiro dos outros"
        description="A interface fala português do Brasil, com frases curtas e concretas. Em momentos de erro, a prioridade é dizer o que aconteceu e qual é o próximo passo."
    >
        <ul class="grid gap-4 md:grid-cols-2">
            <li
                v-for="guideline in voiceGuidelines"
                :key="guideline.title"
                class="card flex flex-col p-6"
            >
                <h3 class="text-[1.0625rem]">{{ guideline.title }}</h3>
                <p class="mt-1.5 text-sm text-muted">{{ guideline.description }}</p>

                <dl class="mt-5 grid flex-1 gap-3 sm:grid-cols-2">
                    <div
                        class="rounded-(--radius) border p-4"
                        :style="{
                            borderColor: 'var(--color-primary-line)',
                            backgroundColor: 'var(--color-success-soft)',
                        }"
                    >
                        <dt class="eyebrow" :style="{ color: 'var(--color-success)' }">Prefira</dt>
                        <dd class="mt-2 text-sm font-medium">{{ guideline.prefer }}</dd>
                    </div>
                    <div
                        class="rounded-(--radius) border p-4"
                        :style="{
                            borderColor: 'var(--color-border)',
                            backgroundColor: 'var(--color-danger-soft)',
                        }"
                    >
                        <dt class="eyebrow" :style="{ color: 'var(--color-danger)' }">Evite</dt>
                        <dd class="mt-2 text-sm text-muted">
                            {{ guideline.avoid }}
                        </dd>
                    </div>
                </dl>
            </li>
        </ul>
    </BrandSection>
</template>
