<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';

import {
    amountSchema,
    type AmountDraft,
    type AmountValues,
} from '@/modules/schemas/account.schema';
import AccountSelect from '@/shared/components/AccountSelect.vue';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useForm } from '@/shared/composables/useForm';
import { withdraw } from '@/shared/services/accounts.service';
import { useAccountsStore } from '@/shared/stores/accounts.store';
import { useToastStore } from '@/shared/stores/toast.store';

const accountsStore = useAccountsStore();
const toastStore = useToastStore();
const { formatCurrency } = useCurrency();

const selectedAccountId = ref<number | null>(null);

const { values, errors, isSubmitting, handleSubmit, reset } = useForm<AmountDraft, AmountValues>(
    amountSchema,
    { amount: null }
);

const selectedAccount = computed(() =>
    selectedAccountId.value === null ? undefined : accountsStore.findById(selectedAccountId.value)
);

watch(
    () => accountsStore.accounts,
    (accounts) => {
        if (selectedAccountId.value === null && accounts.length > 0) {
            selectedAccountId.value = accounts[0]?.id ?? null;
        }
    },
    { immediate: true }
);

onMounted(() => {
    if (!accountsStore.hasLoaded) accountsStore.load();
});

async function submit(): Promise<void> {
    const accountId = selectedAccountId.value;
    if (accountId === null) return;

    await handleSubmit(async ({ amount }) => {
        try {
            const { data } = await withdraw(accountId, amount);
            accountsStore.replace(data);
            reset();
            toastStore.success(
                'Saque realizado',
                `${formatCurrency(amount)} debitados da conta ${accountId}. Novo saldo: ${formatCurrency(data.saldo)}.`
            );
        } catch {
            return;
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader title="Sacar" subtitle="Debite um valor de uma das suas contas." />

        <section v-if="accountsStore.accounts.length > 0" class="card p-5 sm:p-6">
            <form class="flex max-w-md flex-col gap-4" novalidate @submit.prevent="submit">
                <AccountSelect
                    v-model="selectedAccountId"
                    label="Conta de origem"
                    :accounts="accountsStore.accounts"
                    :hint="
                        selectedAccount
                            ? `Saldo atual: ${formatCurrency(selectedAccount.saldo)}.`
                            : undefined
                    "
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
                    {{ isSubmitting ? 'Sacando...' : 'Sacar' }}
                </button>
            </form>
        </section>

        <section v-else class="card px-6 py-12 text-center">
            <p class="font-medium">Nenhuma conta disponível</p>
            <p class="mt-1 text-sm text-muted">É preciso ter ao menos uma conta para sacar.</p>
        </section>
    </div>
</template>
