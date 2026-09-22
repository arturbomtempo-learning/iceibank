<script setup lang="ts">
import { useRouter } from 'vue-router';

import { loginSchema, type LoginDraft, type LoginValues } from '@/modules/schemas/login.schema';
import AppLogo from '@/shared/components/AppLogo.vue';
import BaseInput from '@/shared/components/BaseInput.vue';
import { useForm } from '@/shared/composables/useForm';
import { useToastStore } from '@/shared/stores/toast.store';

import { useAuthStore } from '@/shared/stores/auth.store';

const router = useRouter();
const authStore = useAuthStore();
const toastStore = useToastStore();

const highlights = [
    'Saldo, depósito, saque e extrato em tempo real',
    'Transferências dentro da agência e entre agências',
    'Sessão autenticada por token nas três agências',
];

const { values, errors, isSubmitting, handleSubmit } = useForm<LoginDraft, LoginValues>(
    loginSchema,
    { username: '', password: '' }
);

async function submit(): Promise<void> {
    await handleSubmit(async (credentials) => {
        try {
            await authStore.signIn(credentials.username, credentials.password);
            toastStore.success('Bem-vindo de volta', `Você entrou como ${credentials.username}.`);
            await router.push({ name: 'dashboard' });
        } catch {
            return;
        }
    });
}
</script>

<template>
    <div class="grid min-h-screen lg:grid-cols-[1.05fr_1fr]">
        <section class="surface-ink relative hidden flex-col justify-between p-12 xl:p-14 lg:flex">
            <div class="grain pointer-events-none absolute inset-0 opacity-70" />

            <div
                class="pointer-events-none absolute -right-24 -bottom-28 h-[26rem] w-[26rem] rounded-full opacity-[0.07]"
                :style="{
                    border: '1px solid #ffffff',
                    boxShadow: '0 0 0 6rem rgba(255, 255, 255, 0.04) inset',
                }"
            />

            <div class="relative z-10">
                <AppLogo variant="light" size="md" />
            </div>

            <div class="relative z-10 max-w-lg">
                <span class="badge badge-onink">Sistemas distribuídos</span>

                <h2
                    class="display mt-5 text-[2.5rem] leading-[1.08] font-extrabold text-white xl:text-[2.85rem]"
                >
                    Seu banco em três agências
                    <span :style="{ color: 'var(--color-accent)' }">independentes</span>.
                </h2>

                <p class="mt-5 text-[0.9375rem]" :style="{ color: 'var(--color-ink-muted)' }">
                    Cada agência responde pela sua própria partição de contas e conversa com as
                    demais para concluir transferências entre elas.
                </p>

                <ul class="mt-8 flex flex-col gap-3">
                    <li
                        v-for="highlight in highlights"
                        :key="highlight"
                        class="flex items-start gap-3 text-sm"
                        :style="{ color: 'var(--color-ink-muted)' }"
                    >
                        <svg
                            class="mt-0.5 h-[17px] w-[17px] shrink-0"
                            viewBox="0 0 24 24"
                            fill="none"
                            :stroke="'var(--color-accent)'"
                            stroke-width="2.4"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >
                            <path d="m4 12.5 5 5L20 6.5" />
                        </svg>
                        {{ highlight }}
                    </li>
                </ul>
            </div>

            <div class="relative z-10 grid grid-cols-3 gap-3">
                <div
                    v-for="agency in [0, 1, 2]"
                    :key="agency"
                    class="rounded-[var(--radius-md)] border px-4 py-3.5"
                    :style="{
                        borderColor: 'var(--color-ink-line)',
                        backgroundColor: 'rgba(255, 255, 255, 0.03)',
                    }"
                >
                    <div class="flex items-center gap-2">
                        <span
                            class="h-1.5 w-1.5 rounded-full"
                            :style="{ backgroundColor: 'var(--color-accent)' }"
                        />
                        <p class="display numeric text-xl font-extrabold text-white">
                            0{{ agency }}
                        </p>
                    </div>
                    <p class="mt-1 text-xs" :style="{ color: 'var(--color-ink-muted)' }">Agência</p>
                </div>
            </div>
        </section>

        <section class="flex items-center justify-center px-5 py-12 sm:px-8">
            <div class="w-full max-w-sm">
                <div class="mb-9 lg:hidden">
                    <AppLogo size="md" />
                </div>

                <h1 class="text-[1.75rem] leading-tight">Acessar sua conta</h1>
                <p class="mt-2 text-sm text-muted">
                    Entre com suas credenciais para acessar o ICEIBank.
                </p>

                <form class="mt-8 flex flex-col gap-4" novalidate @submit.prevent="submit">
                    <BaseInput
                        v-model="values.username"
                        label="Usuário"
                        placeholder="Seu nome de usuário"
                        autocomplete="username"
                        :error="errors.username"
                    />

                    <BaseInput
                        v-model="values.password"
                        label="Senha"
                        type="password"
                        placeholder="Sua senha"
                        autocomplete="current-password"
                        :error="errors.password"
                    />

                    <button type="submit" class="btn btn-block mt-2" :disabled="isSubmitting">
                        <template v-if="isSubmitting">Entrando...</template>
                        <template v-else>
                            Entrar
                            <svg
                                class="h-4 w-4"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2.2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >
                                <path d="M5 12h13m0 0-5-5m5 5-5 5" />
                            </svg>
                        </template>
                    </button>
                </form>

                <p class="note note-brand mt-7 text-xs">
                    Primeiro acesso? Entre como <strong>admin</strong> com a senha
                    <strong>admin1234</strong> para cadastrar correntistas e abrir contas.
                </p>
            </div>
        </section>
    </div>
</template>
