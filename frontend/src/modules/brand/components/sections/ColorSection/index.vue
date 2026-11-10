<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import ColorSwatch from '@/modules/brand/components/ColorSwatch/index.vue';
import { brandScale, coreColors, semanticGroups } from '@/modules/brand/data/brand.data';
import { readableText } from '@/modules/brand/utils/contrast';
import { useClipboard } from '@/shared/composables/useClipboard';

defineOptions({ name: 'ColorSection' });

defineProps<{ id: string; ordinal: string }>();

const { copy } = useClipboard();
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Cores"
        title="Verde que transmite confiança"
        description="A paleta parte de um verde profundo, associado a dinheiro e estabilidade, equilibrado por uma tinta quase preta e um acento menta. Clique em qualquer cor para copiar o código."
    >
        <div class="grid gap-4 md:grid-cols-3">
            <button
                v-for="color in coreColors"
                :key="color.token"
                type="button"
                class="core-color group cursor-pointer overflow-hidden text-left"
                :style="{ backgroundColor: color.hex, color: readableText(color.hex).color }"
                :aria-label="`Copiar a cor ${color.name}, ${color.hex}`"
                @click="copy(color.hex.toUpperCase(), `O código ${color.hex.toUpperCase()}`)"
            >
                <span class="flex min-h-48 flex-col justify-between p-6">
                    <span class="display text-xl font-extrabold">{{ color.name }}</span>
                    <span>
                        <span class="numeric block text-sm font-semibold uppercase">
                            {{ color.hex }}
                        </span>
                        <span class="mt-0.5 block font-mono text-xs opacity-75">
                            {{ color.token }}
                        </span>
                        <span class="mt-3 block text-[0.8125rem] opacity-85">
                            {{ color.description }}
                        </span>
                    </span>
                </span>
            </button>
        </div>

        <div class="mt-12 flex flex-wrap items-baseline justify-between gap-x-6 gap-y-2">
            <h3 class="text-[1.0625rem]">Escala da marca</h3>
            <p class="text-xs text-muted">
                O selo indica o contraste do texto sobre cada tom, pelas regras WCAG.
            </p>
        </div>

        <div class="mt-4 flex h-3 overflow-hidden rounded-full" aria-hidden="true">
            <span
                v-for="shade in brandScale"
                :key="shade.step"
                class="flex-1"
                :style="{ backgroundColor: shade.hex }"
            />
        </div>

        <div class="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-6">
            <ColorSwatch
                v-for="shade in brandScale"
                :key="shade.step"
                :name="`Brand ${shade.step}`"
                :hex="shade.hex"
                :caption="shade.usage"
            />
        </div>

        <div class="mt-14">
            <h3 class="text-[1.0625rem]">Tokens semânticos</h3>
            <p class="mt-2 max-w-2xl text-sm text-muted">
                Os componentes nunca usam um tom da escala diretamente: usam tokens com significado,
                que trocam de valor entre o tema claro e o escuro.
            </p>
        </div>

        <div class="mt-6 flex flex-col gap-8">
            <section v-for="group in semanticGroups" :key="group.title">
                <h4 class="eyebrow">{{ group.title }}</h4>

                <div class="card mt-3 overflow-hidden">
                    <div
                        class="hidden grid-cols-[1.4fr_1fr_1fr] gap-4 border-b px-5 py-3 text-xs font-semibold text-muted md:grid"
                        :style="{
                            borderColor: 'var(--color-border)',
                            backgroundColor: 'var(--color-surface-sunken)',
                        }"
                    >
                        <span>Token</span>
                        <span>Claro</span>
                        <span>Escuro</span>
                    </div>

                    <ul>
                        <li
                            v-for="token in group.tokens"
                            :key="token.token"
                            class="grid gap-3 border-b px-5 py-4 last:border-b-0 md:grid-cols-[1.4fr_1fr_1fr] md:items-center md:gap-4"
                            :style="{ borderColor: 'var(--color-border)' }"
                        >
                            <div class="min-w-0">
                                <p class="text-sm font-semibold">{{ token.name }}</p>
                                <p class="mt-0.5 font-mono text-xs break-all text-muted">
                                    {{ token.token }}
                                </p>
                                <p class="mt-1 text-xs text-muted">{{ token.usage }}</p>
                            </div>

                            <div class="grid grid-cols-2 gap-3 md:contents">
                                <button
                                    v-for="mode in ['light', 'dark'] as const"
                                    :key="mode"
                                    type="button"
                                    class="token-value flex cursor-pointer items-center gap-2.5 rounded-xs p-1.5 text-left"
                                    :aria-label="`Copiar ${token.name} no tema ${mode === 'light' ? 'claro' : 'escuro'}, ${token[mode]}`"
                                    @click="
                                        copy(
                                            token[mode].toUpperCase(),
                                            `O código ${token[mode].toUpperCase()}`
                                        )
                                    "
                                >
                                    <span
                                        class="h-8 w-8 shrink-0 rounded-xs border"
                                        :style="{
                                            backgroundColor: token[mode],
                                            borderColor: 'var(--color-border)',
                                        }"
                                    />
                                    <span class="min-w-0">
                                        <span
                                            class="block text-[0.6875rem] font-semibold text-muted md:hidden"
                                        >
                                            {{ mode === 'light' ? 'Claro' : 'Escuro' }}
                                        </span>
                                        <span
                                            class="numeric block text-[0.8125rem] font-semibold uppercase"
                                        >
                                            {{ token[mode] }}
                                        </span>
                                    </span>
                                </button>
                            </div>
                        </li>
                    </ul>
                </div>
            </section>
        </div>
    </BrandSection>
</template>

<style scoped>
.core-color {
    border: 1px solid rgba(6, 32, 23, 0.08);
    border-radius: var(--radius-card);
    box-shadow: var(--shadow-xs);
    transition:
        box-shadow 0.18s var(--ease-out),
        transform 0.18s var(--ease-out);
}

.core-color:hover {
    box-shadow: var(--shadow-lg);
    transform: translateY(-2px);
}

.token-value {
    transition: background-color 0.18s var(--ease-out);
}

.token-value:hover {
    background-color: var(--color-surface-hover);
}

@media (prefers-reduced-motion: reduce) {
    .core-color:hover {
        transform: none;
    }
}
</style>
