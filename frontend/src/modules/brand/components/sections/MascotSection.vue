<script setup lang="ts">
import { ref } from 'vue';

import mascotFullBody from '@/assets/mascot/mascot-full-body.webp';
import mascotHead from '@/assets/mascot/mascot-head.webp';
import LoginMascot from '@/modules/auth/components/LoginMascot.vue';
import BrandSection from '@/modules/brand/components/BrandSection.vue';

defineProps<{ id: string; ordinal: string }>();

const isCardRaised = ref(false);

const doGuidelines = [
    'Boas-vindas, primeiro acesso e login',
    'Estados vazios, como um painel ainda sem contas',
    'Conquistas e mensagens de conclusão',
    'Sempre com texto alternativo descritivo',
];

const dontGuidelines = [
    'Telas de confirmação de valores ou de erro em transações',
    'Recortado, espelhado, recolorido ou com proporções alteradas',
    'Competindo com o saldo ou com a ação principal da tela',
    'Mais de uma vez na mesma tela',
];

const downloads = [
    { label: 'Corpo inteiro', href: mascotFullBody, filename: 'iceibank-mascote.webp' },
    { label: 'Cabeça', href: mascotHead, filename: 'iceibank-mascote-cabeca.webp' },
];
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Mascote"
        title="O castor que cuida do seu dinheiro"
        description="Organizado, construtor e persistente, o castor de moletom traduz a ideia de um banco feito com cuidado, peça por peça. Ele aparece para acolher, nunca para distrair."
    >
        <div class="grid gap-4 lg:grid-cols-[1.1fr_1fr]">
            <figure
                class="surface-ink relative m-0 flex flex-col overflow-hidden p-6 sm:p-8"
                :style="{ borderRadius: 'var(--radius-xl)' }"
            >
                <div class="grain pointer-events-none absolute inset-0 opacity-60" />
                <div class="relative z-10 flex flex-1 items-center justify-center py-4">
                    <img
                        :src="mascotFullBody"
                        width="642"
                        height="760"
                        alt="Mascote do ICEIBank de corpo inteiro: um castor de moletom verde segurando um cartão do banco"
                        class="float-slow w-full max-w-[15rem] sm:max-w-[17rem]"
                        loading="lazy"
                        decoding="async"
                    />
                </div>
                <figcaption class="relative z-10 mt-4">
                    <p class="display text-sm font-bold text-white">Corpo inteiro</p>
                    <p class="mt-1 text-[0.8125rem]" :style="{ color: 'var(--color-ink-muted)' }">
                        Para chamadas de destaque, como o convite final da página inicial.
                    </p>
                </figcaption>
            </figure>

            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-1">
                <figure class="card m-0 flex flex-col gap-5 p-6 sm:flex-row sm:items-center lg:p-7">
                    <div
                        class="flex h-28 w-28 shrink-0 items-center justify-center rounded-[30%]"
                        :style="{ backgroundColor: 'var(--color-primary-soft)' }"
                    >
                        <img
                            :src="mascotHead"
                            width="320"
                            height="279"
                            alt="Cabeça do mascote do ICEIBank"
                            class="w-[5.5rem]"
                            loading="lazy"
                            decoding="async"
                        />
                    </div>
                    <figcaption>
                        <p class="display text-sm font-bold">Cabeça</p>
                        <p class="mt-1 text-[0.8125rem] text-muted">
                            Para saudações no painel e estados vazios, onde há pouco espaço.
                        </p>
                    </figcaption>
                </figure>

                <figure
                    class="surface-ink relative m-0 flex flex-col items-center overflow-hidden p-6 lg:flex-row lg:gap-6 lg:p-7"
                    :style="{ borderRadius: 'var(--radius-card)' }"
                >
                    <div class="grain pointer-events-none absolute inset-0 opacity-60" />
                    <div class="relative z-10 w-full max-w-[9.5rem] shrink-0">
                        <LoginMascot :covered="isCardRaised" />
                    </div>
                    <figcaption class="relative z-10 mt-5 w-full lg:mt-0">
                        <p class="display text-sm font-bold text-white">Versão animada</p>
                        <p
                            class="mt-1 text-[0.8125rem]"
                            :style="{ color: 'var(--color-ink-muted)' }"
                        >
                            No login, acompanha o cursor e cobre os olhos com o cartão enquanto a
                            senha é digitada.
                        </p>
                        <button
                            type="button"
                            class="btn btn-onink mt-4 px-4 py-2 text-sm"
                            :aria-pressed="isCardRaised"
                            @click="isCardRaised = !isCardRaised"
                        >
                            {{ isCardRaised ? 'Baixar o cartão' : 'Levantar o cartão' }}
                        </button>
                    </figcaption>
                </figure>
            </div>
        </div>

        <div class="mt-4 grid gap-4 md:grid-cols-2">
            <div class="card p-6">
                <p class="eyebrow" :style="{ color: 'var(--color-success)' }">Quando usar</p>
                <ul class="mt-4 flex flex-col gap-3">
                    <li v-for="item in doGuidelines" :key="item" class="flex gap-3 text-sm">
                        <svg
                            class="mt-0.5 h-4 w-4 shrink-0"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="var(--color-success)"
                            stroke-width="2.4"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            aria-hidden="true"
                        >
                            <path d="m4 12.5 5 5L20 6.5" />
                        </svg>
                        {{ item }}
                    </li>
                </ul>
            </div>

            <div class="card p-6">
                <p class="eyebrow" :style="{ color: 'var(--color-danger)' }">Quando evitar</p>
                <ul class="mt-4 flex flex-col gap-3">
                    <li v-for="item in dontGuidelines" :key="item" class="flex gap-3 text-sm">
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
                        {{ item }}
                    </li>
                </ul>
            </div>
        </div>

        <div class="mt-10 flex flex-wrap gap-3">
            <a
                v-for="item in downloads"
                :key="item.filename"
                :href="item.href"
                :download="item.filename"
                class="btn btn-secondary"
            >
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
                Baixar {{ item.label.toLowerCase() }}
            </a>
        </div>
    </BrandSection>
</template>
