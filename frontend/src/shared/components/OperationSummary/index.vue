<script setup lang="ts">
import { computed } from 'vue';

import { useCurrency } from '@/shared/composables/useCurrency';
import type { OwnedAccount } from '@/shared/stores/accounts.store';

const props = defineProps<{
    account?: OwnedAccount;
    amount: number | null;
    mode: 'deposit' | 'withdraw';
}>();

const { formatCurrency } = useCurrency();

const signedAmount = computed(() => {
    if (props.amount === null || !Number.isFinite(props.amount) || props.amount <= 0) return null;

    return props.mode === 'deposit' ? props.amount : -props.amount;
});

const resultingBalance = computed(() => {
    if (props.account === undefined || signedAmount.value === null) return null;

    return props.account.saldo + signedAmount.value;
});

const isOverdrawn = computed(() => resultingBalance.value !== null && resultingBalance.value < 0);
</script>

<template>
    <aside class="card p-5 sm:p-6">
        <p class="eyebrow">Resumo da operação</p>

        <dl v-if="account" class="mt-5 flex flex-col">
            <div
                class="flex items-baseline justify-between gap-4 border-b py-3 first:pt-0"
                :style="{ borderColor: 'var(--color-border)' }"
            >
                <dt class="text-sm text-muted">Conta</dt>
                <dd class="numeric text-sm font-semibold">
                    {{ account.id }} · {{ account.agencyLabel }}
                </dd>
            </div>

            <div
                class="flex items-baseline justify-between gap-4 border-b py-3"
                :style="{ borderColor: 'var(--color-border)' }"
            >
                <dt class="text-sm text-muted">Saldo atual</dt>
                <dd class="numeric text-sm font-semibold">{{ formatCurrency(account.saldo) }}</dd>
            </div>

            <div
                class="flex items-baseline justify-between gap-4 border-b py-3"
                :style="{ borderColor: 'var(--color-border)' }"
            >
                <dt class="text-sm text-muted">
                    {{ mode === 'deposit' ? 'A creditar' : 'A debitar' }}
                </dt>
                <dd
                    v-if="signedAmount !== null"
                    class="numeric text-sm font-semibold"
                    :style="{
                        color: mode === 'deposit' ? 'var(--color-success)' : 'var(--color-danger)',
                    }"
                >
                    {{ mode === 'deposit' ? '+' : '−' }}
                    {{ formatCurrency(Math.abs(signedAmount)) }}
                </dd>
                <dd v-else class="numeric text-sm text-muted">{{ formatCurrency(0) }}</dd>
            </div>

            <div class="flex items-baseline justify-between gap-4 pt-4">
                <dt class="text-sm font-semibold">Saldo depois</dt>
                <dd
                    v-if="resultingBalance !== null"
                    class="display numeric text-lg font-extrabold"
                    :style="{ color: isOverdrawn ? 'var(--color-danger)' : 'var(--color-text)' }"
                >
                    {{ formatCurrency(resultingBalance) }}
                </dd>
                <dd v-else class="display numeric text-lg font-extrabold text-muted">
                    {{ formatCurrency(account.saldo) }}
                </dd>
            </div>
        </dl>

        <p v-else class="mt-4 text-sm text-muted">Escolha uma conta para ver o resumo.</p>

        <p v-if="isOverdrawn" class="note mt-5" :style="{ borderColor: 'var(--color-danger)' }">
            Esse valor passa do saldo disponível. A agência vai recusar o saque.
        </p>
    </aside>
</template>
