<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';

import mascotHead from '@/assets/mascot/mascot-head.webp';
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
    <div class="flex flex-col gap-7">
        <header class="flex flex-wrap items-end justify-between gap-4">
            <div>
                <h1 class="text-[1.75rem] sm:text-[2rem]">Olá, {{ greetingName }}</h1>
                <p class="mt-1 text-sm text-muted">
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
                <svg
                    class="h-4 w-4"
                    :class="accountsStore.isLoading ? 'animate-spin' : ''"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                >
                    <path d="M21 12a9 9 0 1 1-2.6-6.4M21 3v6h-6" />
                </svg>
                {{ accountsStore.isLoading ? 'Atualizando...' : 'Atualizar saldos' }}
            </button>
        </header>

        <section v-if="accountsStore.accounts.length > 0" class="flex flex-col gap-4">
            <div class="flex items-center justify-between gap-3">
                <h2 class="eyebrow">
                    {{ authStore.isManager ? 'Contas do banco' : 'Suas contas' }}
                </h2>
                <span class="badge">{{ accountsStore.accounts.length }}</span>
            </div>

            <div class="grid gap-5" :class="hasMultipleAccounts ? 'lg:grid-cols-2' : ''">
                <BalanceCard
                    v-for="account in accountsStore.accounts"
                    :key="account.id"
                    :account="account"
                    :revealed="isBalanceRevealed"
                    @toggle="isBalanceRevealed = !isBalanceRevealed"
                />
            </div>

            <div
                v-if="hasMultipleAccounts"
                class="card flex flex-wrap items-center justify-between gap-3 px-5 py-4"
            >
                <p class="text-sm text-muted">
                    {{
                        authStore.isManager
                            ? `Somando as ${accountsStore.accounts.length} contas do banco`
                            : `Saldo somado das suas ${accountsStore.accounts.length} contas`
                    }}
                </p>
                <p
                    v-if="isBalanceRevealed"
                    class="display numeric text-xl font-extrabold"
                    :style="{ color: 'var(--color-primary-dark)' }"
                >
                    {{ formatCurrency(accountsStore.totalBalance) }}
                </p>
                <p v-else class="display text-xl font-extrabold text-muted">
                    &bull;&bull;&bull;&bull;
                </p>
            </div>
        </section>

        <section
            v-else-if="accountsStore.isEmpty"
            class="card flex flex-col items-center gap-2 px-6 py-14 text-center"
        >
            <img
                :src="mascotHead"
                width="320"
                height="279"
                alt=""
                class="w-[88px]"
                loading="lazy"
                decoding="async"
            />
            <p class="mt-2 font-semibold">Nenhuma conta no seu nome</p>
            <p class="max-w-sm text-sm text-muted">
                {{
                    authStore.isManager
                        ? 'Cadastre um correntista e abra a primeira conta do banco.'
                        : 'Procure o gerente para abrir a sua conta.'
                }}
            </p>
            <RouterLink v-if="authStore.isManager" :to="{ name: 'new-customer' }" class="btn mt-4">
                Cadastrar correntista
            </RouterLink>
        </section>

        <p v-if="accountsStore.hasUnavailableAgencies" class="note">
            Não foi possível falar com a {{ unavailableAgencyLabels }}. Se você tiver contas lá,
            elas não entram nesta soma até a agência voltar.
        </p>

        <section>
            <h2 class="eyebrow mb-4">O que você quer fazer</h2>

            <div class="card overflow-hidden">
                <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5">
                    <RouterLink
                        v-for="action in actions"
                        :key="action.name"
                        :to="{ name: action.name }"
                        class="group relative flex flex-col items-center gap-3 border-b border-l px-3 py-6 text-center no-underline transition-colors first:border-l-0 sm:border-b-0"
                        :style="{
                            color: 'var(--color-text)',
                            borderColor: 'var(--color-border)',
                        }"
                    >
                        <svg
                            class="h-[22px] w-[22px] transition-colors duration-150"
                            :style="{ color: 'var(--color-primary)' }"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path :d="action.icon" />
                        </svg>

                        <span class="text-[0.8125rem] font-semibold">{{ action.label }}</span>

                        <span
                            class="motif-rule absolute inset-x-0 bottom-0 h-1 opacity-0 transition-opacity duration-200 group-hover:opacity-100"
                        />
                    </RouterLink>
                </div>
            </div>
        </section>

        <section class="card flex flex-wrap items-end justify-between gap-5 p-5 sm:p-6">
            <div>
                <h2 class="text-[1.0625rem]">Acesso às agências</h2>
                <p class="mt-1.5 max-w-md text-sm text-muted">
                    Suas operações são enviadas automaticamente para a agência que guarda cada
                    conta. Fixe uma agência apenas se quiser testar o comportamento da partição.
                </p>
            </div>

            <div class="w-full sm:w-56">
                <AgencySelect label="Agência de destino das chamadas" />
            </div>
        </section>
    </div>
</template>
