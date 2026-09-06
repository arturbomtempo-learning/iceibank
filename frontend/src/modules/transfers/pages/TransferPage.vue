<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';

import {
    transferAmountSchema,
    type TransferAmountDraft,
    type TransferAmountValues,
} from '@/modules/schemas/transfer.schema';
import AccountSelect from '@/shared/components/AccountSelect.vue';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useForm } from '@/shared/composables/useForm';
import { extractErrorMessage } from '@/shared/services/api';
import { useAccountsStore } from '@/shared/stores/accounts.store';
import { useAgencyStore } from '@/shared/stores/agency.store';
import { useToastStore } from '@/shared/stores/toast.store';

import { transfer } from '../services/transfers.service';

interface TransferOutcome {
    status: 'success' | 'failure';
    message: string;
    sourceAccountId: number;
    targetAccountId: number;
    amount: number;
}

const accountsStore = useAccountsStore();
const agencyStore = useAgencyStore();
const toastStore = useToastStore();
const { formatCurrency } = useCurrency();

const sourceAccountId = ref<number | null>(null);
const outcome = ref<TransferOutcome | null>(null);

const { values, errors, isSubmitting, handleSubmit, reset } = useForm<
    TransferAmountDraft,
    TransferAmountValues
>(transferAmountSchema, { targetAccountId: null, amount: null });

const targetHint = computed(() => {
    const targetId = values.value.targetAccountId;
    if (targetId === null || !Number.isInteger(targetId) || targetId < 0) {
        return 'Pode ser uma conta de qualquer agência.';
    }

    const sourceAgency = agencyStore.agencyForAccount(sourceAccountId.value ?? 0);
    const targetAgency = agencyStore.agencyForAccount(targetId);

    return sourceAgency?.id === targetAgency?.id
        ? `Conta da ${targetAgency?.label}: será uma transferência dentro da mesma agência.`
        : `Conta da ${targetAgency?.label}: será uma transferência entre agências.`;
});

watch(
    () => accountsStore.accounts,
    (accounts) => {
        if (sourceAccountId.value === null && accounts.length > 0) {
            sourceAccountId.value = accounts[0]?.id ?? null;
        }
    },
    { immediate: true }
);

onMounted(() => {
    if (!accountsStore.hasLoaded) accountsStore.load();
});

async function submit(): Promise<void> {
    const originId = sourceAccountId.value;
    if (originId === null) return;

    await handleSubmit(async ({ targetAccountId, amount }) => {
        if (targetAccountId === originId) {
            errors.value = { targetAccountId: 'A conta de destino deve ser diferente da origem.' };
            return;
        }

        try {
            const { data } = await transfer({
                idOrigem: originId,
                idDestino: targetAccountId,
                valor: amount,
            });

            outcome.value = {
                status: 'success',
                message: data.mensagem,
                sourceAccountId: originId,
                targetAccountId,
                amount,
            };

            toastStore.success('Transferência concluída', data.mensagem);
            reset();
            await accountsStore.load();
        } catch (error) {
            outcome.value = {
                status: 'failure',
                message: extractErrorMessage(error),
                sourceAccountId: originId,
                targetAccountId,
                amount,
            };
            await accountsStore.load();
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader
            title="Transferir"
            subtitle="Escolha de qual conta sai o dinheiro e informe a conta de destino."
        />

        <div v-if="accountsStore.accounts.length > 0" class="grid gap-5 lg:grid-cols-5">
            <section class="card p-5 sm:p-6 lg:col-span-3">
                <form class="flex flex-col gap-4" novalidate @submit.prevent="submit">
                    <AccountSelect
                        v-model="sourceAccountId"
                        label="De onde sai"
                        :accounts="accountsStore.accounts"
                    />

                    <BaseInput
                        v-model="values.targetAccountId"
                        label="Conta de destino"
                        type="number"
                        placeholder="Ex.: 1"
                        :error="errors.targetAccountId"
                        :hint="targetHint"
                    />

                    <BaseInput
                        v-model="values.amount"
                        label="Valor"
                        type="number"
                        prefix="R$"
                        placeholder="0,00"
                        :error="errors.amount"
                    />

                    <button type="submit" class="btn mt-1" :disabled="isSubmitting">
                        {{ isSubmitting ? 'Transferindo...' : 'Transferir' }}
                    </button>
                </form>
            </section>

            <section class="lg:col-span-2">
                <div
                    v-if="outcome"
                    class="card p-5 sm:p-6"
                    :style="{
                        borderLeft: `3px solid ${
                            outcome.status === 'success'
                                ? 'var(--color-success)'
                                : 'var(--color-danger)'
                        }`,
                    }"
                >
                    <span
                        class="badge"
                        :class="outcome.status === 'success' ? 'badge-success' : 'badge-danger'"
                    >
                        {{ outcome.status === 'success' ? 'Concluída' : 'Não concluída' }}
                    </span>

                    <p class="mt-3 text-[0.9375rem] font-medium">{{ outcome.message }}</p>

                    <dl class="mt-5 flex flex-col gap-3 text-sm">
                        <div class="flex items-center justify-between gap-4">
                            <dt class="text-muted">Origem</dt>
                            <dd class="numeric font-medium">{{ outcome.sourceAccountId }}</dd>
                        </div>
                        <div class="flex items-center justify-between gap-4">
                            <dt class="text-muted">Destino</dt>
                            <dd class="numeric font-medium">{{ outcome.targetAccountId }}</dd>
                        </div>
                        <div
                            class="flex items-center justify-between gap-4 border-t pt-3"
                            :style="{ borderColor: 'var(--color-border)' }"
                        >
                            <dt class="text-muted">Valor</dt>
                            <dd class="numeric font-semibold">
                                {{ formatCurrency(outcome.amount) }}
                            </dd>
                        </div>
                    </dl>

                    <p
                        v-if="outcome.status === 'failure'"
                        class="mt-4 rounded-[var(--radius)] p-3 text-xs"
                        :style="{
                            backgroundColor: 'var(--color-surface-hover)',
                            color: 'var(--color-text-muted)',
                        }"
                    >
                        A agência de destino não confirmou o crédito, seja porque está fora do ar ou
                        porque a conta informada não existe lá. O débito na origem já pode ter sido
                        aplicado, então confira o saldo antes de tentar de novo.
                    </p>
                </div>

                <div
                    v-else
                    class="card flex h-full flex-col items-center justify-center gap-2 px-6 py-12 text-center"
                >
                    <div
                        class="flex h-12 w-12 items-center justify-center rounded-full"
                        :style="{ backgroundColor: 'var(--color-primary-soft)' }"
                    >
                        <svg
                            class="h-6 w-6"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="var(--color-primary)"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path d="M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4" />
                        </svg>
                    </div>
                    <p class="mt-1 font-medium">Nenhuma transferência ainda</p>
                    <p class="text-sm text-muted">
                        O resultado aparece aqui, seja dentro da mesma agência ou entre agências.
                    </p>
                </div>
            </section>
        </div>

        <section v-else class="card px-6 py-12 text-center">
            <p class="font-medium">Nenhuma conta disponível</p>
            <p class="mt-1 text-sm text-muted">É preciso ter uma conta para enviar dinheiro.</p>
        </section>
    </div>
</template>
