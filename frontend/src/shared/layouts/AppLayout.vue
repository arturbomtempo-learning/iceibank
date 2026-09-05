<script setup lang="ts">
import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';

import { useAuthStore } from '@/shared/stores/auth.store';
import AppLogo from '@/shared/components/AppLogo.vue';
import { useAccountsStore } from '@/shared/stores/accounts.store';
import { AUTOMATIC_ROUTING, useAgencyStore } from '@/shared/stores/agency.store';
import { useToastStore } from '@/shared/stores/toast.store';

const router = useRouter();
const authStore = useAuthStore();
const accountsStore = useAccountsStore();
const agencyStore = useAgencyStore();
const toastStore = useToastStore();

const isMenuOpen = ref(false);

const navigationItems = computed(() =>
    [
        { name: 'dashboard', label: 'Início', icon: 'M3 10.5 12 3l9 7.5V21H3z' },
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
    ].filter((item) => item !== null)
);

const initials = computed(() => authStore.username.slice(0, 2).toUpperCase());

const roleLabel = computed(() => (authStore.isManager ? 'Gerente' : 'Correntista'));

function closeMenu(): void {
    isMenuOpen.value = false;
}

function signOut(): void {
    authStore.signOut();
    accountsStore.reset();
    toastStore.info('Sessão encerrada', 'Você saiu da sua conta com segurança.');
    router.push({ name: 'login' });
}
</script>

<template>
    <div class="flex min-h-screen">
        <div
            v-if="isMenuOpen"
            class="fixed inset-0 z-30 bg-black/40 lg:hidden"
            @click="closeMenu"
        />

        <aside
            class="fixed inset-y-0 left-0 z-40 flex w-64 shrink-0 flex-col transition-transform duration-200 lg:translate-x-0"
            :class="isMenuOpen ? 'translate-x-0' : '-translate-x-full'"
            :style="{ backgroundColor: 'var(--color-sidebar-bg)' }"
        >
            <div class="flex h-16 items-center px-5">
                <AppLogo variant="light" size="sm" />
            </div>

            <nav class="flex flex-1 flex-col gap-1 px-3 py-4">
                <RouterLink
                    v-for="item in navigationItems"
                    :key="item.name"
                    :to="{ name: item.name }"
                    class="nav-link"
                    exact-active-class="nav-link--active"
                    @click="closeMenu"
                >
                    <svg
                        class="h-[18px] w-[18px] shrink-0"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        aria-hidden="true"
                    >
                        <path :d="item.icon" />
                    </svg>
                    {{ item.label }}
                </RouterLink>
            </nav>

            <div class="px-3 pb-4">
                <div
                    class="flex items-center gap-3 rounded-[var(--radius)] px-3 py-3"
                    :style="{ backgroundColor: 'var(--color-sidebar-hover)' }"
                >
                    <div
                        class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-[0.8125rem] font-semibold text-white"
                        :style="{ backgroundColor: 'var(--color-primary)' }"
                    >
                        {{ initials }}
                    </div>
                    <div class="min-w-0 flex-1">
                        <p class="truncate text-sm font-medium text-white">
                            {{ authStore.username }}
                        </p>
                        <p
                            class="truncate text-xs"
                            :style="{ color: 'var(--color-sidebar-muted)' }"
                        >
                            {{ roleLabel }}
                        </p>
                    </div>
                    <button
                        type="button"
                        class="shrink-0 cursor-pointer rounded p-1.5 transition-colors hover:text-white"
                        :style="{ color: 'var(--color-sidebar-muted)' }"
                        aria-label="Sair"
                        @click="signOut"
                    >
                        <svg
                            class="h-[18px] w-[18px]"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.8"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path
                                d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"
                            />
                        </svg>
                    </button>
                </div>
            </div>
        </aside>

        <div class="flex min-w-0 flex-1 flex-col lg:pl-64">
            <header
                class="sticky top-0 z-20 flex h-16 items-center gap-3 border-b px-4 sm:px-6"
                :style="{
                    backgroundColor: 'var(--color-surface)',
                    borderColor: 'var(--color-border)',
                }"
            >
                <button
                    type="button"
                    class="cursor-pointer rounded p-2 lg:hidden"
                    :style="{ color: 'var(--color-text)' }"
                    aria-label="Abrir menu"
                    @click="isMenuOpen = true"
                >
                    <svg
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="1.8"
                        stroke-linecap="round"
                    >
                        <path d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>

                <div class="ml-auto flex items-center gap-2.5">
                    <span class="hidden text-sm text-muted sm:inline">{{
                        authStore.username
                    }}</span>
                    <span
                        class="flex h-8 w-8 items-center justify-center rounded-full text-xs font-semibold text-white"
                        :style="{ backgroundColor: 'var(--color-primary)' }"
                    >
                        {{ initials }}
                    </span>
                </div>
            </header>

            <div
                v-if="!agencyStore.isAutomatic"
                class="flex flex-wrap items-center gap-x-3 gap-y-2 border-b px-4 py-2.5 sm:px-6"
                :style="{
                    backgroundColor: 'var(--color-primary-soft)',
                    borderColor: 'var(--color-border)',
                }"
            >
                <span class="badge badge-primary">Roteamento fixo</span>
                <p class="text-[0.8125rem]" :style="{ color: 'var(--color-text)' }">
                    Todas as chamadas estão indo para a
                    <strong>{{ agencyStore.gateway?.label }}</strong
                    >, então contas de outras agências não vão ser encontradas.
                </p>
                <button
                    type="button"
                    class="ml-auto cursor-pointer text-[0.8125rem] font-semibold underline"
                    :style="{ color: 'var(--color-primary-dark)' }"
                    @click="agencyStore.select(AUTOMATIC_ROUTING)"
                >
                    Voltar ao automático
                </button>
            </div>

            <main class="flex-1 px-4 py-6 sm:px-6 sm:py-8">
                <div class="mx-auto w-full max-w-5xl">
                    <RouterView />
                </div>
            </main>
        </div>
    </div>
</template>
