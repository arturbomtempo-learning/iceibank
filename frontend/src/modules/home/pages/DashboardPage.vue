<script setup lang="ts">
import { computed } from 'vue';

import { useAuthStore } from '@/modules/auth/stores/auth.store';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useAgencyStore } from '@/shared/stores/agency.store';

const authStore = useAuthStore();
const agencyStore = useAgencyStore();

const shortcuts = computed(() =>
    [
        {
            name: 'account',
            title: 'Consultar conta',
            description: 'Veja o saldo, deposite e saque em uma conta desta agência.',
            icon: 'M4 6h16v12H4zM4 10h16',
        },
        {
            name: 'transfer',
            title: 'Transferir',
            description: 'Envie valores para contas desta ou de outra agência.',
            icon: 'M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4',
        },
        authStore.isManager
            ? {
                  name: 'new-account',
                  title: 'Abrir conta',
                  description: 'Cadastre uma nova conta e defina o usuário dono dela.',
                  icon: 'M12 5v14M5 12h14',
              }
            : null,
    ].filter((shortcut) => shortcut !== null)
);

const roleDescription = computed(() =>
    authStore.isManager
        ? 'Como gerente, você abre contas e opera qualquer conta desta agência.'
        : 'Como correntista, você opera apenas as contas das quais é dono.'
);
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader :title="`Olá, ${authStore.username}`" :subtitle="roleDescription" />

        <section
            class="card relative overflow-hidden p-6 sm:p-7"
            :style="{ backgroundColor: 'var(--color-sidebar-bg)', border: 'none' }"
        >
            <div
                class="pointer-events-none absolute -top-20 -right-16 h-64 w-64 rounded-full opacity-20 blur-3xl"
                :style="{ backgroundColor: 'var(--color-primary)' }"
            />

            <div class="relative z-10 flex flex-wrap items-end justify-between gap-6">
                <div>
                    <p
                        class="text-xs font-medium tracking-wide uppercase"
                        :style="{ color: 'var(--color-sidebar-muted)' }"
                    >
                        Agência de acesso
                    </p>
                    <p class="mt-1.5 text-3xl font-semibold text-white">
                        {{ agencyStore.selected?.label }}
                    </p>
                    <p class="mt-1 text-sm" :style="{ color: 'var(--color-sidebar-muted)' }">
                        {{ agencyStore.selected?.url }}
                    </p>
                </div>

                <p class="max-w-xs text-sm" :style="{ color: 'var(--color-sidebar-muted)' }">
                    Cada agência responde apenas pelas contas da sua partição. Troque a agência no
                    topo da tela para operar as demais.
                </p>
            </div>
        </section>

        <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <RouterLink
                v-for="shortcut in shortcuts"
                :key="shortcut.name"
                :to="{ name: shortcut.name }"
                class="card flex flex-col gap-3 p-5 no-underline"
                :style="{ color: 'var(--color-text)' }"
            >
                <div
                    class="flex h-10 w-10 items-center justify-center rounded-[var(--radius)]"
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
                        <path :d="shortcut.icon" />
                    </svg>
                </div>

                <div>
                    <h2 class="text-[0.9375rem] font-semibold">{{ shortcut.title }}</h2>
                    <p class="mt-1 text-sm text-muted">{{ shortcut.description }}</p>
                </div>
            </RouterLink>
        </div>
    </div>
</template>
