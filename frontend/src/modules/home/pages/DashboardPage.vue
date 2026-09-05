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
            description: 'Veja o saldo, deposite e saque em qualquer conta sua.',
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
        ? 'Como gerente, você abre contas e opera qualquer conta das três agências.'
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
                        Roteamento
                    </p>
                    <p class="mt-1.5 text-3xl font-semibold text-white">
                        {{ agencyStore.isAutomatic ? 'Automático' : agencyStore.gateway?.label }}
                    </p>
                    <p class="mt-1 text-sm" :style="{ color: 'var(--color-sidebar-muted)' }">
                        {{
                            agencyStore.isAutomatic
                                ? 'Cada operação vai para a agência dona da conta'
                                : agencyStore.gateway?.url
                        }}
                    </p>
                </div>

                <p class="max-w-xs text-sm" :style="{ color: 'var(--color-sidebar-muted)' }">
                    As contas são divididas entre as agências pela regra
                    <strong class="text-white"
                        >número da conta % {{ agencyStore.options.length }}</strong
                    >, e o sistema envia cada operação para a agência responsável.
                </p>
            </div>

            <dl
                class="relative z-10 mt-7 grid grid-cols-1 gap-x-6 gap-y-4 border-t pt-5 sm:grid-cols-3"
                :style="{ borderColor: 'rgba(255,255,255,0.12)' }"
            >
                <div v-for="agency in agencyStore.options" :key="agency.id">
                    <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">
                        {{ agency.label }}
                    </dt>
                    <dd class="numeric mt-0.5 text-[0.9375rem] font-medium text-white">
                        contas {{ agency.id }}, {{ agency.id + agencyStore.options.length }},
                        {{ agency.id + agencyStore.options.length * 2 }}...
                    </dd>
                </div>
            </dl>
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
