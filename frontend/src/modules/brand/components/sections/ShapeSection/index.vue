<script setup lang="ts">
import { ref } from 'vue';

import BrandSection from '@/modules/brand/components/BrandSection.vue';
import { motionTokens, radiusTokens, shadowTokens } from '@/modules/brand/data/brand.data';

defineProps<{ id: string; ordinal: string }>();

const isMotionPlaying = ref(false);
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Forma e movimento"
        title="Cantos suaves, sombras discretas"
        description="Cantos arredondados deixam a interface amigável sem perder a seriedade. Sombras são leves e usadas para indicar elevação, nunca como enfeite."
    >
        <h3 class="text-[1.0625rem]">Raios</h3>
        <ul class="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-6">
            <li v-for="radius in radiusTokens" :key="radius.token">
                <div
                    class="aspect-4/3 border-2"
                    :style="{
                        borderRadius: `var(${radius.token})`,
                        borderColor: 'var(--color-primary-line)',
                        backgroundColor: 'var(--color-primary-soft)',
                    }"
                    aria-hidden="true"
                />
                <p class="mt-2.5 text-sm font-semibold">
                    {{ radius.name }}
                    <span class="numeric font-medium text-muted">· {{ radius.value }} px</span>
                </p>
                <p class="mt-0.5 font-mono text-xs text-muted">{{ radius.token }}</p>
                <p class="mt-1 text-xs text-muted">{{ radius.usage }}</p>
            </li>
        </ul>

        <h3 class="mt-12 text-[1.0625rem]">Sombras</h3>
        <ul class="mt-4 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <li v-for="shadow in shadowTokens" :key="shadow.token">
                <div
                    class="flex h-24 items-center justify-center"
                    :style="{
                        borderRadius: 'var(--radius-card)',
                        backgroundColor: 'var(--color-surface)',
                        boxShadow: `var(${shadow.token})`,
                    }"
                    aria-hidden="true"
                />
                <p class="mt-3.5 text-sm font-semibold">{{ shadow.name }}</p>
                <p class="mt-0.5 font-mono text-xs text-muted">{{ shadow.token }}</p>
                <p class="mt-1 text-xs text-muted">{{ shadow.usage }}</p>
            </li>
        </ul>

        <h3 class="mt-12 text-[1.0625rem]">Movimento</h3>
        <div class="mt-4 grid gap-4 lg:grid-cols-[1.1fr_1fr]">
            <div class="card p-6">
                <div class="flex flex-wrap items-center justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold">Curva padrão</p>
                        <p class="mt-0.5 font-mono text-xs break-all text-muted">
                            --ease-out · cubic-bezier(0.22, 1, 0.36, 1)
                        </p>
                    </div>
                    <button
                        type="button"
                        class="btn btn-secondary px-3.5 py-2 text-sm"
                        @click="isMotionPlaying = !isMotionPlaying"
                    >
                        Reproduzir
                    </button>
                </div>

                <div
                    class="relative mt-6 h-12 rounded-full"
                    :style="{ backgroundColor: 'var(--color-surface-sunken)' }"
                    aria-hidden="true"
                >
                    <span
                        class="motion-dot absolute top-1.5 left-1.5 h-9 w-9 rounded-full"
                        :class="{ 'motion-dot--end': isMotionPlaying }"
                    />
                </div>

                <p class="mt-4 text-sm text-muted">
                    Começa rápido e desacelera no fim, como algo que chega e se acomoda. Quem ativa
                    a redução de movimento no sistema vê as mudanças sem animação.
                </p>
            </div>

            <ul class="card p-6">
                <li
                    v-for="motion in motionTokens"
                    :key="motion.name"
                    class="flex items-baseline justify-between gap-4 border-b py-3 first:pt-0 last:border-b-0 last:pb-0"
                    :style="{ borderColor: 'var(--color-border)' }"
                >
                    <div>
                        <p class="text-sm font-semibold">{{ motion.name }}</p>
                        <p class="mt-0.5 text-xs text-muted">{{ motion.usage }}</p>
                    </div>
                    <p class="display numeric shrink-0 text-[1.0625rem] font-bold text-primary">
                        {{ motion.duration }} ms
                    </p>
                </li>
            </ul>
        </div>
    </BrandSection>
</template>

<style scoped>
.motion-dot {
    background:
        radial-gradient(120% 140% at 85% 0%, rgba(87, 227, 168, 0.5) 0%, transparent 60%),
        var(--color-primary);
    box-shadow: var(--shadow-brand);
    transition: left 0.9s var(--ease-out);
}

.motion-dot--end {
    left: calc(100% - 2.625rem);
}

@media (prefers-reduced-motion: reduce) {
    .motion-dot {
        transition: none;
    }
}
</style>
