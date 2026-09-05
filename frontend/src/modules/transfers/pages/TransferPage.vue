<script setup lang="ts">
import { computed, ref } from 'vue';

import {
    transferSchema,
    type TransferDraft,
    type TransferValues,
} from '@/modules/schemas/transfer.schema';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useForm } from '@/shared/composables/useForm';
import { extractErrorMessage } from '@/shared/services/api';
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

const agencyStore = useAgencyStore();
const toastStore = useToastStore();
const { formatCurrency } = useCurrency();

const outcome = ref<TransferOutcome | null>(null);

const { values, errors, isSubmitting, handleSubmit, reset } = useForm<
    TransferDraft,
    TransferValues
>(transferSchema, {
    sourceAccountId: null,
    targetAccountId: null,
    amount: null,
});

const sourceHint = computed(() => {
    const typedSourceId = values.value.sourceAccountId;

    if (!agencyStore.isAutomatic) {
        return `A ordem vai sempre para a ${agencyStore.gateway?.label}, porque o roteamento automático está desligado.`;
    }

    if (typedSourceId === null || !Number.isInteger(typedSourceId) || typedSourceId < 0) {
        return 'A ordem é enviada para a agência que guarda a conta de origem.';
    }

    return `A ordem será enviada para a ${agencyStore.agencyForAccount(typedSourceId)?.label}.`;
});

async function submit(): Promise<void> {
    await handleSubmit(async ({ sourceAccountId, targetAccountId, amount }) => {
        try {
            const { data } = await transfer({
                idOrigem: sourceAccountId,
                idDestino: targetAccountId,
                valor: amount,
            });

            outcome.value = {
                status: 'success',
                message: data.mensagem,
                sourceAccountId,
                targetAccountId,
                amount,
            };

            toastStore.success('Transferência concluída', data.mensagem);
            reset();
        } catch (error) {
            outcome.value = {
                status: 'failure',
                message: extractErrorMessage(error),
                sourceAccountId,
                targetAccountId,
                amount,
            };
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader
            title="Transferir"
            subtitle="Informe as contas e o valor. A agência de origem e a de destino são descobertas pelo próprio sistema."
        />

        <div class="grid gap-5 lg:grid-cols-5">
            <section class="card p-5 sm:p-6 lg:col-span-3">
                <form class="flex flex-col gap-4" novalidate @submit.prevent="submit">
                    <BaseInput
                        v-model="values.sourceAccountId"
                        label="Conta de origem"
                        type="number"
                        placeholder="Ex.: 0"
                        :error="errors.sourceAccountId"
                        :hint="sourceHint"
                    />

                    <BaseInput
                        v-model="values.targetAccountId"
                        label="Conta de destino"
                        type="number"
                        placeholder="Ex.: 1"
                        :error="errors.targetAccountId"
                        hint="O sistema descobre sozinho a agência responsável pelo destino."
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
                        Se a agência de destino estiver fora do ar, o débito na origem já pode ter
                        sido aplicado. Consulte o saldo da conta de origem para confirmar.
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
                        O resultado da operação aparece aqui, seja ela local ou entre agências.
                    </p>
                </div>
            </section>
        </div>
    </div>
</template>
