<script setup lang="ts">
import type { StyleValue } from 'vue';

import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import AppLogo from '@/shared/components/AppLogo/index.vue';

defineOptions({ name: 'LogoSection' });

defineProps<{ id: string; ordinal: string }>();

type LogoSize = 'sm' | 'md' | 'lg';

const sizes: { size: LogoSize; label: string }[] = [
    { size: 'sm', label: '28 px' },
    { size: 'md', label: '32 px' },
    { size: 'lg', label: '42 px' },
];

const misuses: { label: string; logoStyle: StyleValue; background?: string }[] = [
    { label: 'Não distorça as proporções', logoStyle: { transform: 'scaleX(1.45)' } },
    { label: 'Não troque as cores', logoStyle: { filter: 'hue-rotate(150deg)' } },
    { label: 'Não rotacione', logoStyle: { transform: 'rotate(-14deg)' } },
    {
        label: 'Não use sobre fundos sem contraste',
        logoStyle: {},
        background: 'var(--color-brand-400)',
    },
];
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Logo"
        title="Um símbolo, três agências"
        description="O símbolo reúne três barras em diagonal, uma para cada agência, que diminuem de tamanho e de opacidade como uma operação que atravessa a rede. Ao lado, o nome em Plus Jakarta Sans ExtraBold, com “Bank” na cor da marca."
    >
        <div class="grid gap-4 md:grid-cols-2">
            <figure class="m-0">
                <div class="card flex min-h-52 items-center justify-center p-8">
                    <AppLogo size="lg" />
                </div>
                <figcaption class="mt-3 text-sm">
                    <span class="font-semibold">Versão principal.</span>
                    <span class="text-muted"> Para fundos claros e superfícies.</span>
                </figcaption>
            </figure>

            <figure class="m-0">
                <div
                    class="surface-ink relative flex min-h-52 items-center justify-center overflow-hidden p-8"
                    :style="{ borderRadius: 'var(--radius-card)' }"
                >
                    <div class="grain pointer-events-none absolute inset-0 opacity-60" />
                    <AppLogo variant="light" size="lg" class="relative z-10" />
                </div>
                <figcaption class="mt-3 text-sm">
                    <span class="font-semibold">Versão negativa.</span>
                    <span class="text-muted"> Para a tinta e fundos escuros.</span>
                </figcaption>
            </figure>
        </div>

        <div class="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div class="card flex flex-col p-6">
                <p class="eyebrow">Símbolo isolado</p>
                <div class="flex flex-1 items-center gap-4 py-6">
                    <AppLogo size="lg" mark-only />
                    <AppLogo size="md" mark-only />
                    <AppLogo size="sm" mark-only />
                </div>
                <p class="text-sm text-muted">
                    Para favicon, ícone de aplicativo e avatares, onde o nome não cabe.
                </p>
            </div>

            <div class="card flex flex-col p-6">
                <p class="eyebrow">Tamanhos</p>
                <ul class="flex flex-1 flex-col justify-center gap-4 py-6">
                    <li
                        v-for="item in sizes"
                        :key="item.size"
                        class="flex items-center justify-between gap-4"
                    >
                        <AppLogo :size="item.size" />
                        <span
                            class="numeric shrink-0 text-xs font-semibold whitespace-nowrap text-muted"
                        >
                            {{ item.label }}
                        </span>
                    </li>
                </ul>
                <p class="text-sm text-muted">
                    A altura do símbolo nunca fica abaixo de 28 px, exceto no favicon.
                </p>
            </div>

            <div class="card flex flex-col p-6 sm:col-span-2 lg:col-span-1">
                <p class="eyebrow">Área de proteção</p>
                <div class="flex flex-1 items-center justify-center py-6">
                    <div
                        class="clearspace rounded-xs p-4"
                        :style="{ backgroundColor: 'var(--color-primary-soft)' }"
                    >
                        <div
                            class="rounded-sm px-1 py-0.5"
                            :style="{ backgroundColor: 'var(--color-surface)' }"
                        >
                            <AppLogo size="md" />
                        </div>
                    </div>
                </div>
                <p class="text-sm text-muted">
                    Mantenha ao redor do logo um espaço livre igual à metade da altura do símbolo.
                </p>
            </div>
        </div>

        <h3 class="mt-12 text-[1.0625rem]">Evite</h3>
        <ul class="mt-4 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <li v-for="misuse in misuses" :key="misuse.label">
                <div
                    class="card flex h-28 items-center justify-center overflow-hidden p-4"
                    :style="misuse.background ? { backgroundColor: misuse.background } : undefined"
                    aria-hidden="true"
                >
                    <AppLogo size="sm" :style="misuse.logoStyle" />
                </div>
                <p class="mt-2.5 flex items-start gap-2 text-[0.8125rem] font-medium">
                    <svg
                        class="mt-0.5 h-4 w-4 shrink-0"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="var(--color-danger)"
                        stroke-width="2.4"
                        stroke-linecap="round"
                        aria-hidden="true"
                    >
                        <path d="M6 6l12 12M18 6 6 18" />
                    </svg>
                    {{ misuse.label }}
                </p>
            </li>
        </ul>

        <div class="mt-10 flex flex-wrap gap-3">
            <a href="/favicon.svg" download="iceibank-simbolo.svg" class="btn btn-secondary">
                <svg
                    class="h-4 w-4"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    aria-hidden="true"
                >
                    <path d="M12 4v11m0 0-4.5-4.5M12 15l4.5-4.5M5 20h14" />
                </svg>
                Baixar símbolo em SVG
            </a>
        </div>
    </BrandSection>
</template>

<style scoped>
.clearspace {
    outline: 1px dashed var(--color-primary-line);
    outline-offset: -1px;
}
</style>
