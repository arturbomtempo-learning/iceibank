<script setup lang="ts">
import { ref } from 'vue';

import {
    createCustomerSchema,
    type CreateCustomerDraft,
    type CreateCustomerValues,
} from '@/modules/schemas/customer.schema';
import BaseInput from '@/shared/components/BaseInput.vue';
import PageHeader from '@/shared/components/PageHeader.vue';
import { useForm } from '@/shared/composables/useForm';
import { useToastStore } from '@/shared/stores/toast.store';

import { createCustomer } from '../services/users.service';

const toastStore = useToastStore();

const lastCreatedUsername = ref<string | null>(null);

const { values, errors, isSubmitting, handleSubmit, reset } = useForm<
    CreateCustomerDraft,
    CreateCustomerValues
>(createCustomerSchema, { username: '', password: '' });

async function submit(): Promise<void> {
    await handleSubmit(async ({ username, password }) => {
        try {
            const { data } = await createCustomer({ usuario: username, senha: password });

            lastCreatedUsername.value = data.usuario;
            reset();
            toastStore.success(
                'Correntista cadastrado',
                `${data.usuario} já pode entrar no sistema. Agora abra uma conta para essa pessoa.`
            );
        } catch {
            return;
        }
    });
}
</script>

<template>
    <div class="flex flex-col gap-6">
        <PageHeader
            title="Novo correntista"
            subtitle="Cadastre o acesso de um cliente. Depois abra a conta bancária dele."
        />

        <section class="card p-5 sm:p-6">
            <form class="flex max-w-md flex-col gap-4" novalidate @submit.prevent="submit">
                <BaseInput
                    v-model="values.username"
                    label="Usuário"
                    placeholder="Ex.: ana"
                    autocomplete="off"
                    hint="É com esse nome que a pessoa vai entrar no sistema."
                    :error="errors.username"
                />

                <BaseInput
                    v-model="values.password"
                    label="Senha"
                    type="password"
                    placeholder="Mínimo de 6 caracteres"
                    autocomplete="new-password"
                    :error="errors.password"
                />

                <button type="submit" class="btn mt-1" :disabled="isSubmitting">
                    {{ isSubmitting ? 'Cadastrando...' : 'Cadastrar correntista' }}
                </button>
            </form>
        </section>

        <section
            v-if="lastCreatedUsername"
            class="card flex flex-wrap items-center justify-between gap-4 p-5"
            :style="{ borderLeft: '3px solid var(--color-success)' }"
        >
            <div>
                <p class="font-medium">
                    <strong>{{ lastCreatedUsername }}</strong> foi cadastrado
                </p>
                <p class="mt-1 text-sm text-muted">
                    O acesso vale nas três agências. Falta abrir a conta bancária.
                </p>
            </div>

            <RouterLink :to="{ name: 'new-account' }" class="btn">Abrir conta</RouterLink>
        </section>
    </div>
</template>
