<script setup lang="ts">
import { ref } from 'vue';

import BrandSection from '@/modules/brand/components/BrandSection/index.vue';
import BalanceCard from '@/shared/components/BalanceCard/index.vue';
import BaseInput from '@/shared/components/BaseInput/index.vue';
import type { OwnedAccount } from '@/shared/stores/accounts.store';
import { useToastStore } from '@/shared/stores/toast.store';

defineOptions({ name: 'ComponentsSection' });

defineProps<{ id: string; ordinal: string }>();

const toastStore = useToastStore();

const holderName = ref<string | number | null>('');
const amount = ref<string | number | null>(250);
const invalidAmount = ref<string | number | null>(5000);
const agency = ref<string | number | null>('Agência 0, definida pela conta');

const isBalanceRevealed = ref(false);

const sampleAccount: OwnedAccount = {
    id: 6,
    nomeAluno: 'Ana Souza',
    dono: 'ana',
    saldo: 2500,
    agencia: 0,
    agencyLabel: 'Agência 0',
};

const badges = [
    { className: 'badge', label: 'Neutro' },
    { className: 'badge badge-primary', label: 'Marca' },
    { className: 'badge badge-success', label: 'Concluída' },
    { className: 'badge badge-danger', label: 'Indisponível' },
];

function showSuccessToast(): void {
    toastStore.success('Transferência concluída', 'R$ 250,00 enviados para a conta 7.');
}

function showErrorToast(): void {
    toastStore.error('Saldo insuficiente', 'Escolha um valor de até R$ 2.500,00.');
}

function showInfoToast(): void {
    toastStore.info('Entrega assíncrona', 'A agência de destino vai creditar em instantes.');
}
</script>

<template>
    <BrandSection
        :id="id"
        :ordinal="ordinal"
        eyebrow="Componentes"
        title="Peças prontas, comportamento previsível"
        description="Os componentes abaixo são os mesmos usados no internet banking, renderizados ao vivo. Cada um indica a classe ou o componente Vue que o implementa."
    >
        <div class="flex flex-col gap-4">
            <article class="card p-6 sm:p-7">
                <header class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                    <h3 class="text-base">Botões</h3>
                    <code class="font-mono text-xs text-muted">.btn</code>
                </header>
                <p class="mt-2 max-w-2xl text-sm text-muted">
                    Um único botão primário por tela, para a ação que conclui a tarefa. As demais
                    ações usam as variações secundária ou fantasma.
                </p>

                <div class="mt-6 flex flex-wrap items-center gap-3">
                    <button type="button" class="btn">Transferir</button>
                    <button type="button" class="btn btn-secondary">Cancelar</button>
                    <button type="button" class="btn btn-ghost">Ver detalhes</button>
                    <button type="button" class="btn btn-danger">Encerrar sessão</button>
                    <button type="button" class="btn" disabled>Indisponível</button>
                </div>

                <div
                    class="surface-ink relative mt-5 flex flex-wrap items-center gap-3 overflow-hidden p-5"
                    :style="{ borderRadius: 'var(--radius)' }"
                >
                    <button type="button" class="btn relative z-10">Acessar o banco</button>
                    <button type="button" class="btn btn-onink relative z-10">
                        Ver como funciona
                    </button>
                </div>

                <ul class="mt-5 flex flex-wrap gap-2">
                    <li
                        v-for="className in [
                            '.btn',
                            '.btn-secondary',
                            '.btn-ghost',
                            '.btn-danger',
                            '.btn-onink',
                            '.btn-block',
                        ]"
                        :key="className"
                    >
                        <code class="badge font-mono">{{ className }}</code>
                    </li>
                </ul>
            </article>

            <article class="card p-6 sm:p-7">
                <header class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                    <h3 class="text-base">Campos</h3>
                    <code class="font-mono text-xs text-muted">&lt;BaseInput /&gt;</code>
                </header>
                <p class="mt-2 max-w-2xl text-sm text-muted">
                    Rótulo sempre visível acima do campo. O erro aparece logo abaixo, com ícone e
                    texto, para não depender apenas da cor.
                </p>

                <div class="mt-6 grid gap-5 sm:grid-cols-2">
                    <BaseInput
                        v-model="holderName"
                        label="Nome do titular"
                        placeholder="Como está no documento"
                        autocomplete="off"
                    />
                    <BaseInput
                        v-model="amount"
                        label="Valor"
                        type="number"
                        prefix="R$"
                        hint="O valor sai na hora da conta de origem."
                    />
                    <BaseInput
                        v-model="invalidAmount"
                        label="Valor do saque"
                        type="number"
                        prefix="R$"
                        error="Saldo insuficiente para este valor."
                    />
                    <BaseInput v-model="agency" label="Agência" disabled />
                </div>
            </article>

            <div class="grid gap-4 lg:grid-cols-2">
                <article class="card p-6 sm:p-7">
                    <header class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                        <h3 class="text-base">Selos</h3>
                        <code class="font-mono text-xs text-muted">.badge</code>
                    </header>
                    <p class="mt-2 text-sm text-muted">
                        Indicam estado ou categoria. Nunca são clicáveis.
                    </p>
                    <div class="mt-5 flex flex-wrap gap-2">
                        <span v-for="badge in badges" :key="badge.label" :class="badge.className">
                            {{ badge.label }}
                        </span>
                    </div>
                    <div
                        class="surface-ink mt-4 flex flex-wrap gap-2 p-4"
                        :style="{ borderRadius: 'var(--radius)' }"
                    >
                        <span class="badge badge-onink">Sobre a tinta</span>
                    </div>
                </article>

                <article class="card p-6 sm:p-7">
                    <header class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                        <h3 class="text-base">Avisos</h3>
                        <code class="font-mono text-xs text-muted"
                            >.note · &lt;ToastContainer /&gt;</code
                        >
                    </header>
                    <p class="mt-2 text-sm text-muted">
                        Notas ficam no fluxo da página. Notificações flutuam e somem sozinhas em
                        seis segundos.
                    </p>
                    <p class="note mt-5">A transferência entre agências é entregue pela fila.</p>
                    <p class="note note-brand mt-3">
                        Primeiro acesso? Entre como gerente para abrir contas.
                    </p>
                    <div class="mt-5 flex flex-wrap gap-2">
                        <button
                            type="button"
                            class="btn btn-secondary px-3.5 py-2 text-sm"
                            @click="showSuccessToast"
                        >
                            Sucesso
                        </button>
                        <button
                            type="button"
                            class="btn btn-secondary px-3.5 py-2 text-sm"
                            @click="showErrorToast"
                        >
                            Erro
                        </button>
                        <button
                            type="button"
                            class="btn btn-secondary px-3.5 py-2 text-sm"
                            @click="showInfoToast"
                        >
                            Informação
                        </button>
                    </div>
                </article>
            </div>

            <article class="card grid gap-6 p-6 sm:p-7 lg:grid-cols-[1fr_1.15fr] lg:items-center">
                <div>
                    <header class="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                        <h3 class="text-base">Cartão de saldo</h3>
                        <code class="font-mono text-xs text-muted">&lt;BalanceCard /&gt;</code>
                    </header>
                    <p class="mt-2 text-sm text-muted">
                        O saldo começa oculto, para proteger quem acessa em lugares públicos. Um
                        toque no ícone de olho revela o valor.
                    </p>
                    <div class="mt-5 flex items-center gap-3">
                        <span class="op-glyph">
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
                                <path d="M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4" />
                            </svg>
                        </span>
                        <p class="text-sm text-muted">
                            O glifo de operação, <code class="font-mono text-xs">.op-glyph</code>,
                            abre o cabeçalho de cada tela de movimentação.
                        </p>
                    </div>
                </div>

                <BalanceCard
                    :account="sampleAccount"
                    :revealed="isBalanceRevealed"
                    @toggle="isBalanceRevealed = !isBalanceRevealed"
                />
            </article>
        </div>
    </BrandSection>
</template>
