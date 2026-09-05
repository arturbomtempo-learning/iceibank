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
    <div class="grid min-h-screen lg:grid-cols-2">
        <section
            class="relative hidden flex-col justify-between overflow-hidden p-12 lg:flex"
            :style="{ backgroundColor: 'var(--color-sidebar-bg)' }"
        >
            <div
                class="pointer-events-none absolute -top-24 -right-24 h-96 w-96 rounded-full opacity-20 blur-3xl"
                :style="{ backgroundColor: 'var(--color-primary)' }"
            />
            <div
                class="pointer-events-none absolute -bottom-32 -left-20 h-80 w-80 rounded-full opacity-10 blur-3xl"
                :style="{ backgroundColor: 'var(--color-primary-light)' }"
            />

            <AppLogo variant="light" size="md" />

            <div class="relative z-10 max-w-md">
                <h2 class="text-3xl leading-tight font-semibold text-white">
                    Seu banco distribuído, em três agências independentes.
                </h2>
                <p class="mt-4 text-[0.9375rem]" :style="{ color: 'var(--color-sidebar-muted)' }">
                    Cada agência responde pela sua própria partição de contas e conversa com as
                    demais para concluir transferências entre elas.
                </p>
            </div>

            <div class="relative z-10 flex gap-8">
                <div v-for="agency in [0, 1, 2]" :key="agency">
                    <p class="text-2xl font-semibold text-white numeric">0{{ agency }}</p>
                    <p class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">Agência</p>
                </div>
            </div>
        </section>

        <section class="flex items-center justify-center px-5 py-10 sm:px-8">
            <div class="w-full max-w-sm">
                <div class="mb-8 lg:hidden">
                    <AppLogo size="md" />
                </div>

                <h1 class="text-2xl font-semibold">Acessar sua conta</h1>
                <p class="mt-1.5 text-sm text-muted">
                    Entre com suas credenciais para acessar o ICEIBank.
                </p>

                <form class="mt-7 flex flex-col gap-4" novalidate @submit.prevent="submit">
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

                    <button type="submit" class="btn mt-2" :disabled="isSubmitting">
                        {{ isSubmitting ? 'Entrando...' : 'Entrar' }}
                    </button>
                </form>

                <p
                    class="mt-6 rounded-[var(--radius)] px-4 py-3 text-xs text-muted"
                    :style="{ backgroundColor: 'var(--color-surface-hover)' }"
                >
                    Primeiro acesso? Entre como <strong>admin</strong> com a senha
                    <strong>admin1234</strong> para cadastrar correntistas e abrir contas.
                </p>
            </div>
        </section>
    </div>
</template>
