<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection.vue';
import { typeScale, type TypeStyle } from '@/modules/brand/data/brand.data';

defineProps<{ id: string; ordinal: string }>();

const families = [
    {
        name: 'Plus Jakarta Sans',
        role: 'Títulos e números',
        family: 'var(--font-display)',
        weights: [500, 600, 700, 800],
        description:
            'Geométrica e firme, dá presença aos títulos, ao saldo e aos botões. Os pesos ExtraBold e Bold carregam a voz da marca.',
        url: 'https://fonts.google.com/specimen/Plus+Jakarta+Sans',
    },
    {
        name: 'Inter',
        role: 'Texto e interface',
        family: 'var(--font-sans)',
        weights: [400, 500, 600, 700],
        description:
            'Desenhada para telas, mantém a leitura confortável em textos longos, rótulos e campos, mesmo em tamanhos pequenos.',
        url: 'https://fonts.google.com/specimen/Inter',
    },
];

const statement = [
    { label: 'Saldo inicial', amount: 'R$ 1.000,00' },
    { label: 'Depósito', amount: 'R$ 2.480,90' },
    { label: 'Transferência', amount: 'R$ 111,11' },
];

function familyFor(style: TypeStyle): string {
    return style.family === 'display' ? 'var(--font-display)' : 'var(--font-sans)';
}

function specFor(style: TypeStyle): string {
    const tracking = style.tracking === 0 ? '0' : `${String(style.tracking).replace('.', ',')}%`;
    return `${style.size} px · ${style.weight} · ${String(style.lineHeight).replace('.', ',')} · ${tracking}`;
}
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Tipografia"
        title="Duas famílias, papéis bem definidos"
        description="Plus Jakarta Sans para o que precisa ser visto primeiro, Inter para o que precisa ser lido. As duas são livres e carregadas pelo Google Fonts."
    >
        <div class="grid gap-4 md:grid-cols-2">
            <article
                v-for="item in families"
                :key="item.name"
                class="card flex flex-col p-6 sm:p-7"
            >
                <div class="flex items-start justify-between gap-4">
                    <p class="eyebrow">{{ item.role }}</p>
                    <a
                        :href="item.url"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="link-nav shrink-0 text-xs"
                    >
                        Google Fonts
                    </a>
                </div>

                <p
                    class="mt-4 text-[4.5rem] leading-none font-extrabold sm:text-[5.5rem]"
                    :style="{ fontFamily: item.family, letterSpacing: '-0.03em' }"
                    aria-hidden="true"
                >
                    Aa
                </p>
                <h3 class="mt-4 text-xl" :style="{ fontFamily: item.family }">{{ item.name }}</h3>
                <p class="mt-2 text-sm text-muted">{{ item.description }}</p>

                <ul class="mt-5 flex flex-wrap gap-2">
                    <li
                        v-for="weight in item.weights"
                        :key="weight"
                        class="badge"
                        :style="{ fontFamily: item.family, fontWeight: weight }"
                    >
                        {{ weight }}
                    </li>
                </ul>

                <p
                    class="mt-5 border-t pt-5 text-sm break-words text-muted"
                    :style="{ fontFamily: item.family, borderColor: 'var(--color-border)' }"
                >
                    ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 R$ ç ã é
                </p>
            </article>
        </div>

        <h3 class="mt-12 text-[1.0625rem]">Escala tipográfica</h3>
        <ul class="card mt-4 overflow-hidden">
            <li
                v-for="style in typeScale"
                :key="style.name"
                class="grid gap-2 border-b px-5 py-5 last:border-b-0 sm:px-6 md:grid-cols-[12rem_1fr] md:items-center md:gap-6"
                :style="{ borderColor: 'var(--color-border)' }"
            >
                <div>
                    <p class="text-sm font-semibold">{{ style.name }}</p>
                    <p class="numeric mt-0.5 text-xs text-muted">{{ specFor(style) }}</p>
                </div>
                <p
                    class="min-w-0 break-words"
                    :style="{
                        fontFamily: familyFor(style),
                        fontSize: style.previewSize,
                        fontWeight: style.weight,
                        lineHeight: style.lineHeight,
                        letterSpacing: `${style.tracking / 100}em`,
                        textTransform: style.uppercase ? 'uppercase' : undefined,
                        color: style.uppercase ? 'var(--color-text-muted)' : 'var(--color-text)',
                    }"
                >
                    {{ style.sample }}
                </p>
            </li>
        </ul>

        <div class="mt-4 grid gap-4 lg:grid-cols-[1fr_1.1fr]">
            <div class="card p-6">
                <p class="eyebrow">Números tabulares</p>
                <p class="mt-3 text-sm text-muted">
                    Todo valor em dinheiro usa algarismos de largura fixa, com a classe
                    <code class="font-mono text-xs">.numeric</code>. Assim as colunas de um extrato
                    ficam alinhadas e nenhum dígito "pula" quando o saldo muda.
                </p>
            </div>

            <ul class="card p-6">
                <li
                    v-for="row in statement"
                    :key="row.label"
                    class="flex items-baseline justify-between gap-4 border-b py-2.5 first:pt-0 last:border-b-0 last:pb-0"
                    :style="{ borderColor: 'var(--color-border)' }"
                >
                    <span class="text-sm text-muted">{{ row.label }}</span>
                    <span class="display numeric text-[1.0625rem] font-bold">{{ row.amount }}</span>
                </li>
            </ul>
        </div>
    </BrandSection>
</template>
