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
        <Transition
            enter-active-class="transition-opacity duration-200"
            enter-from-class="opacity-0"
            leave-active-class="transition-opacity duration-150"
            leave-to-class="opacity-0"
        >
            <div
                v-if="isMenuOpen"
                class="fixed inset-0 z-30 backdrop-blur-sm lg:hidden"
                :style="{ backgroundColor: 'rgba(6, 32, 23, 0.55)' }"
                @click="closeMenu"
            />
        </Transition>

        <aside
            class="surface-ink fixed inset-y-0 left-0 z-40 flex w-[17rem] shrink-0 flex-col transition-transform duration-300 ease-out lg:translate-x-0"
            :class="isMenuOpen ? 'translate-x-0' : '-translate-x-full'"
        >
            <div class="relative z-10 flex h-[4.5rem] items-center px-5">
                <AppLogo variant="light" size="sm" />
            </div>

            <nav class="relative z-10 flex flex-1 flex-col gap-1 overflow-y-auto px-3 py-3">
                <p class="section-title mb-1.5 px-3.5" :style="{ color: 'var(--color-ink-muted)' }">
                    Menu
                </p>

                <RouterLink
                    v-for="item in navigationItems"
                    :key="item.name"
                    :to="{ name: item.name }"
                    class="nav-link"
                    exact-active-class="nav-link--active"
                    @click="closeMenu"
                >
                    <svg
                        class="h-[18px] w-[18px] shrink-0 transition-colors"
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

            <div class="relative z-10 px-3 pb-4">
                <div
                    class="flex items-center gap-3 rounded-[var(--radius-md)] border px-3 py-3"
                    :style="{
                        backgroundColor: 'rgba(255, 255, 255, 0.04)',
                        borderColor: 'var(--color-ink-line)',
                    }"
                >
                    <div
                        class="display flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-[0.8125rem] font-bold"
                        :style="{
                            backgroundColor: 'rgba(87, 227, 168, 0.16)',
                            color: 'var(--color-accent)',
                        }"
                    >
                        {{ initials }}
                    </div>
                    <div class="min-w-0 flex-1">
                        <p class="truncate text-sm font-semibold text-white">
                            {{ authStore.username }}
                        </p>
                        <p class="truncate text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                            {{ roleLabel }}
                        </p>
                    </div>
                    <button
                        type="button"
                        class="shrink-0 cursor-pointer rounded-lg p-1.5 transition-colors hover:bg-white/8 hover:text-white"
                        :style="{ color: 'var(--color-ink-muted)' }"
                        aria-label="Sair"
                        title="Sair"
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

        <div class="flex min-w-0 flex-1 flex-col lg:pl-[17rem]">
            <header
                class="sticky top-0 z-20 flex h-[4.5rem] items-center gap-3 border-b px-4 sm:px-8"
                :style="{
                    backgroundColor: 'rgba(255, 255, 255, 0.82)',
                    borderColor: 'var(--color-border)',
                    backdropFilter: 'blur(12px)',
                }"
            >
                <button
                    type="button"
                    class="cursor-pointer rounded-lg p-2 transition-colors hover:bg-[var(--color-surface-hover)] lg:hidden"
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

                <span class="badge badge-primary hidden sm:inline-flex">
                    <span
                        class="h-1.5 w-1.5 rounded-full"
                        :style="{ backgroundColor: 'var(--color-brand-500)' }"
                    />
                    {{ agencyStore.isAutomatic ? 'Roteamento automático' : 'Roteamento fixo' }}
                </span>

                <div class="ml-auto flex items-center gap-3">
                    <div class="hidden text-right leading-tight sm:block">
                        <p class="text-[0.8125rem] font-semibold">{{ authStore.username }}</p>
                        <p class="text-xs text-muted">{{ roleLabel }}</p>
                    </div>
                    <span
                        class="display flex h-9 w-9 items-center justify-center rounded-full text-xs font-bold text-white"
                        :style="{
                            background:
                                'linear-gradient(135deg, var(--color-brand-400), var(--color-brand-700))',
                        }"
                    >
                        {{ initials }}
                    </span>
                </div>
            </header>

            <div
                v-if="!agencyStore.isAutomatic"
                class="flex flex-wrap items-center gap-x-3 gap-y-2 border-b px-4 py-3 sm:px-8"
                :style="{
                    backgroundColor: 'var(--color-warning-soft)',
                    borderColor: 'var(--color-border)',
                }"
            >
                <svg
                    class="h-4 w-4 shrink-0"
                    viewBox="0 0 24 24"
                    fill="none"
                    :stroke="'var(--color-warning)'"
                    stroke-width="1.9"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                >
                    <path
                        d="M12 9v4M12 17h.01M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"
                    />
                </svg>
                <p class="text-[0.8125rem]" :style="{ color: 'var(--color-text)' }">
                    Todas as chamadas estão indo para a
                    <strong>{{ agencyStore.gateway?.label }}</strong
                    >, então contas de outras agências não vão ser encontradas.
                </p>
                <button
                    type="button"
                    class="ml-auto cursor-pointer text-[0.8125rem] font-semibold underline underline-offset-2"
                    :style="{ color: 'var(--color-warning)' }"
                    @click="agencyStore.select(AUTOMATIC_ROUTING)"
                >
                    Voltar ao automático
                </button>
            </div>

            <main class="flex-1 px-4 py-6 sm:px-8 sm:py-9">
                <div class="mx-auto w-full max-w-5xl">
                    <RouterView v-slot="{ Component }">
                        <Transition
                            mode="out-in"
                            enter-active-class="transition duration-200 ease-out"
                            enter-from-class="opacity-0 translate-y-1"
                            leave-active-class="transition duration-100 ease-in"
                            leave-to-class="opacity-0"
                        >
                            <component :is="Component" />
                        </Transition>
                    </RouterView>
                </div>
            </main>
        </div>
    </div>
</template>
