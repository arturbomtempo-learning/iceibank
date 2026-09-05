<script setup lang="ts">
import { useCurrency } from '@/shared/composables/useCurrency';
import type { OwnedAccount } from '@/shared/stores/accounts.store';

defineProps<{
    account: OwnedAccount;
    revealed: boolean;
}>();

const emit = defineEmits<{
    toggle: [];
}>();

const { formatCurrency } = useCurrency();
</script>

<template>
    <article
        class="card relative overflow-hidden p-6 sm:p-7"
        :style="{ backgroundColor: 'var(--color-sidebar-bg)', border: 'none' }"
    >
        <div
            class="pointer-events-none absolute -top-20 -right-16 h-64 w-64 rounded-full opacity-20 blur-3xl"
            :style="{ backgroundColor: 'var(--color-primary)' }"
        />

        <div class="relative z-10 flex items-start justify-between gap-4">
            <div>
                <p
                    class="text-xs font-medium tracking-wide uppercase"
                    :style="{ color: 'var(--color-sidebar-muted)' }"
                >
                    Saldo disponível
                </p>

                <div class="mt-1.5 flex items-center gap-3">
                    <p
                        class="numeric text-4xl font-semibold text-white transition-all duration-200"
                        :class="revealed ? '' : 'blur-[10px] select-none'"
                        :aria-hidden="!revealed"
                    >
                        {{ formatCurrency(account.saldo) }}
                    </p>

                    <button
                        type="button"
                        class="shrink-0 cursor-pointer rounded-full p-2 transition-colors"
                        :style="{
                            color: 'var(--color-sidebar-muted)',
                            backgroundColor: 'rgba(255,255,255,0.08)',
                        }"
                        :aria-label="revealed ? 'Ocultar saldo' : 'Mostrar saldo'"
                        @click="emit('toggle')"
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
                            <template v-if="revealed">
                                <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7Z" />
                                <circle cx="12" cy="12" r="3" />
                            </template>
                            <template v-else>
                                <path
                                    d="M3 3l18 18M10.6 6.2A9.9 9.9 0 0 1 12 6c6.4 0 10 6 10 6a18 18 0 0 1-3.3 3.9M6.3 8.1A17.6 17.6 0 0 0 2 12s3.6 6 10 6a9.9 9.9 0 0 0 3.4-.6"
                                />
                            </template>
                        </svg>
                    </button>
                </div>
            </div>

            <span class="badge badge-primary shrink-0">{{ account.agencyLabel }}</span>
        </div>

        <dl
            class="relative z-10 mt-7 grid grid-cols-2 gap-x-6 gap-y-4 border-t pt-5"
            :style="{ borderColor: 'rgba(255,255,255,0.12)' }"
        >
            <div>
                <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">Conta</dt>
                <dd class="numeric mt-0.5 text-[0.9375rem] font-medium text-white">
                    {{ account.id }}
                </dd>
            </div>
            <div>
                <dt class="text-xs" :style="{ color: 'var(--color-sidebar-muted)' }">Titular</dt>
                <dd class="mt-0.5 truncate text-[0.9375rem] font-medium text-white">
                    {{ account.nomeAluno }}
                </dd>
            </div>
        </dl>
    </article>
</template>
