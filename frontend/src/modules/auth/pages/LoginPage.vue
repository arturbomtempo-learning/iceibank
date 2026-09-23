<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

import LoginMascot from '@/modules/auth/components/LoginMascot.vue';
import { loginSchema, type LoginDraft, type LoginValues } from '@/modules/schemas/login.schema';
import AppLogo from '@/shared/components/AppLogo.vue';
import BaseInput from '@/shared/components/BaseInput.vue';
import { useForm } from '@/shared/composables/useForm';
import { useToastStore } from '@/shared/stores/toast.store';

import { useAuthStore } from '@/shared/stores/auth.store';

const isPasswordFocused = ref(false);

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
        <section class="surface-ink relative hidden flex-col overflow-hidden p-12 lg:flex xl:p-14">
            <div class="grain pointer-events-none absolute inset-0 opacity-70" />

            <RouterLink
                :to="{ name: 'home' }"
                class="relative z-10 self-start"
                aria-label="Ir para a página inicial"
            >
                <AppLogo variant="light" size="md" />
            </RouterLink>

            <div class="relative z-10 flex flex-1 flex-col items-center justify-center gap-9">
                <LoginMascot :covered="isPasswordFocused" />

                <div class="flex min-h-[1.75rem] max-w-sm flex-col items-center text-center">
                    <p
                        class="display text-[1.0625rem] font-bold transition-colors duration-300"
                        :style="{
                            color: isPasswordFocused ? 'var(--color-accent)' : '#ffffff',
                        }"
                    >
                        {{
                            isPasswordFocused
                                ? 'Pode digitar. Não estamos olhando.'
                                : 'Que bom ver você por aqui de novo.'
                        }}
                    </p>
                </div>
            </div>
        </section>

        <section class="flex items-center justify-center px-5 py-12 sm:px-8">
            <div class="w-full max-w-sm">
                <div class="mb-8 flex flex-col items-center gap-6 lg:hidden">
                    <RouterLink :to="{ name: 'home' }" aria-label="Ir para a página inicial">
                        <AppLogo size="md" />
                    </RouterLink>

                    <LoginMascot :covered="isPasswordFocused" class="max-w-[9.5rem]" />
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

                    <div @focusin="isPasswordFocused = true" @focusout="isPasswordFocused = false">
                        <BaseInput
                            v-model="values.password"
                            label="Senha"
                            type="password"
                            placeholder="Sua senha"
                            autocomplete="current-password"
                            :error="errors.password"
                        />
                    </div>

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

                <p class="note note-brand mt-9 text-xs">
                    Primeiro acesso? Entre como <strong>admin</strong> com a senha
                    <strong>admin1234</strong> para cadastrar correntistas e abrir contas.
                </p>
            </div>
        </section>
    </div>
</template>
