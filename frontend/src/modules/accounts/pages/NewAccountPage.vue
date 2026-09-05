<script setup lang="ts">
import { computed } from 'vue';

import {
    createAccountSchema,
    type CreateAccountDraft,
    type CreateAccountValues,
} from '@/modules/schemas/account.schema';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useForm } from '@/shared/composables/useForm';
import { useAgencyStore } from '@/shared/stores/agency.store';
import { useToastStore } from '@/shared/stores/toast.store';

import { createAccount } from '../services/accounts.service';

const agencyStore = useAgencyStore();
const toastStore = useToastStore();
const { formatCurrency } = useCurrency();

const { values, errors, isSubmitting, handleSubmit, reset } = useForm<
    CreateAccountDraft,
    CreateAccountValues
>(createAccountSchema, {
    accountId: null,
    holderName: '',
    owner: '',
    initialBalance: null,
});

const responsibleAgencyLabel = computed(() => {
    const accountId = values.value.accountId;
    if (accountId === null || !Number.isInteger(accountId) || accountId < 0) return null;

    return agencyStore.agencyForAccount(accountId)?.label ?? null;
});

const willReachResponsibleAgency = computed(
    () => agencyStore.isAutomatic || responsibleAgencyLabel.value === agencyStore.gateway?.label
);

async function submit(): Promise<void> {
    await handleSubmit(async ({ accountId, holderName, owner, initialBalance }) => {
        try {
            const { data } = await createAccount({
                id: accountId,
                nomeAluno: holderName,
                dono: owner,
                saldoInicial: initialBalance,
            });

            toastStore.success(
                'Conta aberta',
                `Conta ${data.id} criada para ${data.nomeAluno} com ${formatCurrency(data.saldo)}.`
            );
            reset();
        } catch {
            return;
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader
            title="Abrir conta"
            subtitle="Operação exclusiva do gerente. A conta é criada na agência responsável pelo número informado."
        />

        <section class="card p-5 sm:p-6">
            <form class="grid gap-4 sm:grid-cols-2" novalidate @submit.prevent="submit">
                <BaseInput
                    v-model="values.accountId"
                    label="Número da conta"
                    type="number"
                    placeholder="Ex.: 0"
                    :error="errors.accountId"
                />

                <BaseInput
                    v-model="values.initialBalance"
                    label="Saldo inicial"
                    type="number"
                    prefix="R$"
                    placeholder="0,00"
                    :error="errors.initialBalance"
                />

                <BaseInput
                    v-model="values.holderName"
                    label="Nome do titular"
                    placeholder="Ex.: Maria Souza"
                    :error="errors.holderName"
                />

                <BaseInput
                    v-model="values.owner"
                    label="Usuário dono"
                    placeholder="Usuário que fará login"
                    hint="Precisa ser um usuário já cadastrado na API."
                    :error="errors.owner"
                />

                <div
                    v-if="responsibleAgencyLabel"
                    class="rounded-[var(--radius)] px-4 py-3 text-sm sm:col-span-2"
                    :style="{
                        backgroundColor: willReachResponsibleAgency
                            ? 'var(--color-primary-soft)'
                            : 'var(--color-surface-hover)',
                    }"
                >
                    <template v-if="willReachResponsibleAgency">
                        Essa conta pertence à
                        <strong>{{ responsibleAgencyLabel }}</strong
                        >, e é para lá que o cadastro será enviado.
                    </template>
                    <template v-else>
                        Essa conta pertence à
                        <strong>{{ responsibleAgencyLabel }}</strong
                        >, mas o roteamento automático está desligado e o cadastro iria para a
                        {{ agencyStore.gateway?.label }}. Volte o seletor para "Automática".
                    </template>
                </div>

                <div class="sm:col-span-2">
                    <button type="submit" class="btn" :disabled="isSubmitting">
                        {{ isSubmitting ? 'Abrindo conta...' : 'Abrir conta' }}
                    </button>
                </div>
            </form>
        </section>
    </div>
</template>
