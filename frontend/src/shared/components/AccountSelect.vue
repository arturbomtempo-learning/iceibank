<script setup lang="ts">
import { useId } from 'vue';

import { useCurrency } from '@/shared/composables/useCurrency';
import type { OwnedAccount } from '@/shared/stores/accounts.store';

defineProps<{
    label: string;
    accounts: OwnedAccount[];
    hint?: string;
}>();

const selectedAccountId = defineModel<number | null>({ required: true });

const selectId = useId();

const { formatCurrency } = useCurrency();
</script>

<template>
    <div class="flex flex-col gap-1.5">
        <label
            :for="selectId"
            class="text-[0.8125rem] font-medium"
            :style="{ color: 'var(--color-text)' }"
        >
            {{ label }}
        </label>

        <select :id="selectId" v-model="selectedAccountId" class="input cursor-pointer">
            <option v-for="account in accounts" :key="account.id" :value="account.id">
                Conta {{ account.id }} &middot; {{ account.agencyLabel }} &middot;
                {{ formatCurrency(account.saldo) }}
            </option>
        </select>

        <p v-if="hint" class="text-xs text-muted">{{ hint }}</p>
    </div>
</template>
