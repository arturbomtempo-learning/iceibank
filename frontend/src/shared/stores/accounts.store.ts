import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

import { fetchStatement, type Account } from '@/shared/services/accounts.service';

import { useAgencyStore } from './agency.store';

export interface OwnedAccount extends Account {
    agencyLabel: string;
}

export const useAccountsStore = defineStore('accounts', () => {
    const accounts = ref<OwnedAccount[]>([]);
    const totalBalance = ref(0);
    const unavailableAgencies = ref<number[]>([]);
    const hasLoaded = ref(false);
    const isLoading = ref(false);

    const isEmpty = computed(() => hasLoaded.value && accounts.value.length === 0);

    const hasUnavailableAgencies = computed(() => unavailableAgencies.value.length > 0);

    function findById(accountId: number): OwnedAccount | undefined {
        return accounts.value.find((account) => account.id === accountId);
    }

    function toOwnedAccount(account: Account): OwnedAccount {
        const agencyStore = useAgencyStore();

        return {
            ...account,
            agencyLabel: agencyStore.labelForAgency(account.agencia),
        };
    }

    async function load(): Promise<void> {
        isLoading.value = true;

        try {
            const { data } = await fetchStatement();

            accounts.value = data.contas.map(toOwnedAccount);
            totalBalance.value = data.saldoTotal;
            unavailableAgencies.value = data.agenciasIndisponiveis;
            hasLoaded.value = true;
        } catch {
            accounts.value = [];
            totalBalance.value = 0;
        } finally {
            isLoading.value = false;
        }
    }

    function replace(account: Account): void {
        const previousBalance = findById(account.id)?.saldo ?? account.saldo;

        accounts.value = accounts.value.map((owned) =>
            owned.id === account.id ? { ...owned, ...account } : owned
        );
        totalBalance.value += account.saldo - previousBalance;
    }

    function reset(): void {
        accounts.value = [];
        totalBalance.value = 0;
        unavailableAgencies.value = [];
        hasLoaded.value = false;
    }

    return {
        accounts,
        totalBalance,
        unavailableAgencies,
        hasUnavailableAgencies,
        hasLoaded,
        isLoading,
        isEmpty,
        findById,
        load,
        replace,
        reset,
    };
});
