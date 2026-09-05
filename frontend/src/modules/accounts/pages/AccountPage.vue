<script setup lang="ts">
import { ref } from 'vue';

import {
    accountLookupSchema,
    amountSchema,
    type AccountLookupDraft,
    type AccountLookupValues,
    type AmountDraft,
    type AmountValues,
} from '@/modules/schemas/account.schema';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useForm } from '@/shared/composables/useForm';
import { useAgencyStore } from '@/shared/stores/agency.store';
import { useToastStore } from '@/shared/stores/toast.store';

import { deposit, fetchAccount, withdraw, type Account } from '../services/accounts.service';

const agencyStore = useAgencyStore();
const toastStore = useToastStore();
const { formatCurrency } = useCurrency();

const account = ref<Account | null>(null);

const {
    values: lookupValues,
    errors: lookupErrors,
    isSubmitting: isLookingUp,
    handleSubmit: submitLookup,
} = useForm<AccountLookupDraft, AccountLookupValues>(accountLookupSchema, { accountId: null });

const {
    values: depositValues,
    errors: depositErrors,
    isSubmitting: isDepositing,
    handleSubmit: submitDepositForm,
    reset: resetDeposit,
} = useForm<AmountDraft, AmountValues>(amountSchema, { amount: null });

const {
    values: withdrawValues,
    errors: withdrawErrors,
    isSubmitting: isWithdrawing,
    handleSubmit: submitWithdrawForm,
    reset: resetWithdraw,
} = useForm<AmountDraft, AmountValues>(amountSchema, { amount: null });

async function loadAccount(): Promise<void> {
    await submitLookup(async ({ accountId }) => {
        try {
            const { data } = await fetchAccount(accountId);
            account.value = data;
        } catch {
            account.value = null;
        }
    });
}

async function handleDeposit(): Promise<void> {
    const currentAccount = account.value;
    if (!currentAccount) return;

    await submitDepositForm(async ({ amount }) => {
        try {
            const { data } = await deposit(currentAccount.id, amount);
            account.value = data;
            resetDeposit();
            toastStore.success(
                'Depósito realizado',
                `${formatCurrency(amount)} creditados na conta ${currentAccount.id}.`
            );
        } catch {
            return;
        }
    });
}

async function handleWithdraw(): Promise<void> {
    const currentAccount = account.value;
    if (!currentAccount) return;

    await submitWithdrawForm(async ({ amount }) => {
        try {
            const { data } = await withdraw(currentAccount.id, amount);
            account.value = data;
            resetWithdraw();
            toastStore.success(
                'Saque realizado',
                `${formatCurrency(amount)} debitados da conta ${currentAccount.id}.`
            );
        } catch {
            return;
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader
            title="Consultar conta"
            subtitle="Veja o saldo e movimente uma conta desta agência."
        />

        <section class="card p-5 sm:p-6">
            <form
                class="flex flex-col gap-4 sm:flex-row sm:items-start"
                novalidate
                @submit.prevent="loadAccount"
            >
                <div class="flex-1">
                    <BaseInput
                        v-model="lookupValues.accountId"
                        label="Número da conta"
                        type="number"
                        placeholder="Ex.: 0"
                        :error="lookupErrors.accountId"
                        :hint="`Buscando na ${agencyStore.selected?.label}.`"
                    />
                </div>
                <button type="submit" class="btn sm:mt-[1.6875rem]" :disabled="isLookingUp">
                    {{ isLookingUp ? 'Buscando...' : 'Consultar' }}
                </button>
            </form>
        </section>

        <template v-if="account">
            <section
                class="card relative overflow-hidden p-6 sm:p-7"
                :style="{ backgroundColor: 'var(--color-sidebar-bg)', border: 'none' }"
            >
                <div
                    class="pointer-events-none absolute -top-16 -right-10 h-56 w-56 rounded-full opacity-20 blur-3xl"
                    :style="{ backgroundColor: 'var(--color-primary)' }"
                />

                <div class="relative z-10 flex flex-wrap items-start justify-between gap-4">
                    <div>
                        <p
                            class="text-xs font-medium tracking-wide uppercase"
                            :style="{ color: 'var(--color-sidebar-muted)' }"
                        >
                            Saldo disponível
                        </p>
                        <p class="numeric mt-1.5 text-4xl font-semibold text-white">
                            {{ formatCurrency(account.saldo) }}
                        </p>
                    </div>

                    <span class="badge badge-primary">{{ agencyStore.selected?.label }}</span>
                </div>

                <dl
                    class="relative z-10 mt-7 grid grid-cols-2 gap-x-6 gap-y-4 border-t pt-5 sm:grid-cols-3"
                    :style="{ borderColor: 'rgba(255,255,255,0.12)' }"
                >
                    <div>
                        <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">
                            Conta
                        </dt>
                        <dd class="numeric mt-0.5 text-[0.9375rem] font-medium text-white">
                            {{ account.id }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">
                            Titular
                        </dt>
                        <dd class="mt-0.5 text-[0.9375rem] font-medium text-white">
                            {{ account.nomeAluno }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">
                            Usuário dono
                        </dt>
                        <dd class="mt-0.5 text-[0.9375rem] font-medium text-white">
                            {{ account.dono }}
                        </dd>
                    </div>
                </dl>
            </section>

            <div class="grid gap-5 sm:grid-cols-2">
                <section class="card p-5 sm:p-6">
                    <h2 class="text-base font-semibold">Depositar</h2>
                    <p class="mt-1 text-sm text-muted">Credite um valor nesta conta.</p>

                    <form
                        class="mt-5 flex flex-col gap-4"
                        novalidate
                        @submit.prevent="handleDeposit"
                    >
                        <BaseInput
                            v-model="depositValues.amount"
                            label="Valor"
                            type="number"
                            prefix="R$"
                            placeholder="0,00"
                            :error="depositErrors.amount"
                        />
                        <button type="submit" class="btn" :disabled="isDepositing">
                            {{ isDepositing ? 'Depositando...' : 'Depositar' }}
                        </button>
                    </form>
                </section>

                <section class="card p-5 sm:p-6">
                    <h2 class="text-base font-semibold">Sacar</h2>
                    <p class="mt-1 text-sm text-muted">Debite um valor desta conta.</p>

                    <form
                        class="mt-5 flex flex-col gap-4"
                        novalidate
                        @submit.prevent="handleWithdraw"
                    >
                        <BaseInput
                            v-model="withdrawValues.amount"
                            label="Valor"
                            type="number"
                            prefix="R$"
                            placeholder="0,00"
                            :error="withdrawErrors.amount"
                        />
                        <button type="submit" class="btn btn-secondary" :disabled="isWithdrawing">
                            {{ isWithdrawing ? 'Sacando...' : 'Sacar' }}
                        </button>
                    </form>
                </section>
            </div>
        </template>

        <section v-else class="card flex flex-col items-center gap-2 px-6 py-14 text-center">
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
                    <circle cx="11" cy="11" r="7" />
                    <path d="m20 20-3.5-3.5" />
                </svg>
            </div>
            <p class="mt-1 font-medium">Nenhuma conta carregada</p>
            <p class="max-w-sm text-sm text-muted">
                Informe o número de uma conta desta agência para ver o saldo e movimentá-la.
            </p>
        </section>
    </div>
</template>
