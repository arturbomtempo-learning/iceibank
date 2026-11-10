<script setup lang="ts">
import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import ThemePreview from '@/modules/brand/components/ThemePreview/index.vue';
import ThemeToggle from '@/shared/components/ThemeToggle/index.vue';
import { useThemeStore } from '@/shared/stores/theme.store';

defineOptions({ name: 'ThemeSection' });

defineProps<{ id: string; ordinal: string }>();

const themeStore = useThemeStore();

const rules = [
    {
        title: 'Segue o sistema',
        description:
            'No primeiro acesso, o ICEIBank adota o tema do sistema operacional, sem pedir nada.',
    },
    {
        title: 'Lembra a escolha',
        description:
            'Quando a pessoa troca o tema, a preferência fica salva no navegador e vale em todas as telas.',
    },
    {
        title: 'Sem piscar',
        description:
            'O tema é aplicado antes da primeira pintura da página, então a tela nunca começa clara para depois escurecer.',
    },
];
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Temas"
        title="Claro de dia, escuro à noite"
        description="Os dois temas compartilham os mesmos componentes e só trocam os valores dos tokens. No escuro, o verde ganha luminosidade para manter o contraste e as sombras ficam mais densas."
    >
        <div
            class="card flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6"
        >
            <div>
                <p class="text-sm font-semibold">
                    Você está vendo o tema {{ themeStore.isDark ? 'escuro' : 'claro' }}.
                </p>
                <p class="mt-1 text-sm text-muted">
                    Use o botão para alternar e ver esta página inteira mudar.
                </p>
            </div>
            <ThemeToggle class="self-start sm:self-auto" />
        </div>

        <div class="mt-4 grid gap-4 md:grid-cols-2">
            <ThemePreview theme="light" />
            <ThemePreview theme="dark" />
        </div>

        <ol class="mt-10 grid gap-x-10 gap-y-6 md:grid-cols-3">
            <li
                v-for="(rule, index) in rules"
                :key="rule.title"
                class="border-t pt-4"
                :style="{ borderColor: 'var(--color-border-strong)' }"
            >
                <p class="ordinal">{{ String(index + 1).padStart(2, '0') }}</p>
                <h3 class="mt-2 text-base">{{ rule.title }}</h3>
                <p class="mt-1.5 text-sm text-muted">{{ rule.description }}</p>
            </li>
        </ol>
    </BrandSection>
</template>
