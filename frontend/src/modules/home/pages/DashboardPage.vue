<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';

import AgencySelect from '@/shared/components/AgencySelect.vue';
import BalanceCard from '@/shared/components/BalanceCard.vue';
import { useCurrency } from '@/shared/composables/useCurrency';
import { useAccountsStore } from '@/shared/stores/accounts.store';
import { useAgencyStore } from '@/shared/stores/agency.store';
import { useAuthStore } from '@/shared/stores/auth.store';

const authStore = useAuthStore();
const accountsStore = useAccountsStore();
const agencyStore = useAgencyStore();
const { formatCurrency } = useCurrency();

const isBalanceRevealed = ref(false);

const actions = computed(() =>
    [
        { name: 'deposit', label: 'Depositar', icon: 'M12 19V5M5 12l7-7 7 7' },
        { name: 'withdraw', label: 'Sacar', icon: 'M12 5v14M5 12l7 7 7-7' },
        {
            name: 'transfer',
            label: 'Transferir',
            icon: 'M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4',
        },
        authStore.isManager
            ? { name: 'new-account', label: 'Abrir conta', icon: 'M12 5v14M5 12h14' }
            : null,
        authStore.isManager
            ? {
                  name: 'new-customer',
                  label: 'Novo correntista',
                  icon: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM19 8v6M22 11h-6',
              }
            : null,
    ].filter((action) => action !== null)
);

const hasMultipleAccounts = computed(() => accountsStore.accounts.length > 1);

const unavailableAgencyLabels = computed(() =>
    accountsStore.unavailableAgencies
        .map((agencyId) => agencyStore.labelForAgency(agencyId))
        .join(', ')
);

const greetingName = computed(() => {
    const ownAccount = accountsStore.accounts.find(
        (account) => account.dono === authStore.username
    );
    const nameToShow = ownAccount?.nomeAluno?.trim() || authStore.username;

    return (nameToShow.split(' ')[0] ?? nameToShow).toUpperCase();
});

onMounted(() => {
    accountsStore.load();
});
</script>

<template>
    <div class="flex flex-col gap-6">
        <header class="flex flex-wrap items-end justify-between gap-3">
            <div>
                <h1 class="text-2xl font-semibold sm:text-[1.75rem]">
                    Olá, {{ greetingName }}
                </h1>
                <p class="text-sm text-muted">
                    {{
                        authStore.isManager
                            ? 'Você é o gerente: cadastra correntistas, abre contas e opera qualquer conta.'
                            : 'Bem-vindo ao seu internet banking.'
                    }}
                </p>
            </div>

            <button
                type="button"
                class="btn btn-secondary"
                :disabled="accountsStore.isLoading"
                @click="accountsStore.load()"
            >
                {{ accountsStore.isLoading ? 'Atualizando...' : 'Atualizar saldos' }}
            </button>
        </header>

        <section v-if="accountsStore.accounts.length > 0" class="flex flex-col gap-3">
            <h2 class="text-sm font-semibold tracking-wide text-muted uppercase">
                {{ authStore.isManager ? 'Contas do banco' : 'Suas contas' }}
            </h2>

            <div class="grid gap-5" :class="hasMultipleAccounts ? 'lg:grid-cols-2' : ''">
                <BalanceCard
                    v-for="account in accountsStore.accounts"
                    :key="account.id"
                    :account="account"
                    :revealed="isBalanceRevealed"
                    @toggle="isBalanceRevealed = !isBalanceRevealed"
                />
            </div>

            <p v-if="hasMultipleAccounts" class="mt-2 text-sm text-muted">
                {{
                    authStore.isManager
                        ? `Somando as ${accountsStore.accounts.length} contas do banco:`
                        : `Saldo somado das suas ${accountsStore.accounts.length} contas:`
                }}
                <strong v-if="isBalanceRevealed" class="numeric">{{
                    formatCurrency(accountsStore.totalBalance)
                }}</strong>
                <strong v-else>&bull;&bull;&bull;&bull;</strong>
            </p>
        </section>

        <section
            v-else-if="accountsStore.isEmpty"
            class="card flex flex-col items-center gap-2 px-6 py-12 text-center"
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
                    <path d="M4 6h16v12H4zM4 10h16" />
                </svg>
            </div>
            <p class="mt-1 font-medium">Nenhuma conta no seu nome</p>
            <p class="max-w-sm text-sm text-muted">
                {{
                    authStore.isManager
                        ? 'Cadastre um correntista e abra a primeira conta do banco.'
                        : 'Procure o gerente para abrir a sua conta.'
                }}
            </p>
            <RouterLink v-if="authStore.isManager" :to="{ name: 'new-customer' }" class="btn mt-3">
                Cadastrar correntista
            </RouterLink>
        </section>

        <p
            v-if="accountsStore.hasUnavailableAgencies"
            class="rounded-[var(--radius)] px-4 py-3 text-sm"
            :style="{
                backgroundColor: 'var(--color-surface-hover)',
                color: 'var(--color-text-muted)',
            }"
        >
            Não foi possível falar com a {{ unavailableAgencyLabels }}. Se você tiver contas lá,
            elas não entram nesta soma até a agência voltar.
        </p>

        <section>
            <h2 class="mb-3 text-sm font-semibold tracking-wide text-muted uppercase">
                O que você quer fazer
            </h2>

            <div class="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
                <RouterLink
                    v-for="action in actions"
                    :key="action.name"
                    :to="{ name: action.name }"
                    class="card flex flex-col items-center gap-2.5 px-3 py-5 text-center no-underline"
                    :style="{ color: 'var(--color-text)' }"
                >
                    <span
                        class="flex h-11 w-11 items-center justify-center rounded-full"
                        :style="{ backgroundColor: 'var(--color-primary-soft)' }"
                    >
                        <svg
                            class="h-5 w-5"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="var(--color-primary)"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path :d="action.icon" />
                        </svg>
                    </span>
                    <span class="text-[0.8125rem] font-medium">{{ action.label }}</span>
                </RouterLink>
            </div>
        </section>

        <section class="card flex flex-wrap items-end justify-between gap-4 p-5">
            <div>
                <h2 class="text-[0.9375rem] font-semibold">Acesso às agências</h2>
                <p class="mt-1 max-w-md text-sm text-muted">
                    Suas operações são enviadas automaticamente para a agência que guarda cada
                    conta. Fixe uma agência apenas se quiser testar o comportamento da partição.
                </p>
            </div>

            <div class="w-full sm:w-52">
                <AgencySelect label="Agência de destino das chamadas" />
            </div>
        </section>
    </div>
</template>
