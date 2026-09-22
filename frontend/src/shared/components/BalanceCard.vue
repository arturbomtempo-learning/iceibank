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
        class="surface-ink relative overflow-hidden p-6 sm:p-7"
        :style="{ borderRadius: 'var(--radius-xl)', boxShadow: 'var(--shadow-lg)' }"
    >
        <div class="grain pointer-events-none absolute inset-0 opacity-60" />

        <svg
            class="pointer-events-none absolute -right-12 -bottom-14 h-40 w-40 opacity-[0.045]"
            viewBox="0 0 40 40"
            fill="none"
            aria-hidden="true"
        >
            <g transform="rotate(-45 20 20)" fill="#ffffff">
                <rect x="8" y="9.6" width="24" height="4.6" rx="2.3" />
                <rect x="11" y="17.7" width="18" height="4.6" rx="2.3" />
                <rect x="14" y="25.8" width="12" height="4.6" rx="2.3" />
            </g>
        </svg>

        <div class="relative z-10 flex items-start justify-between gap-4">
            <div class="min-w-0">
                <p class="section-title" :style="{ color: 'var(--color-ink-muted)' }">
                    Saldo disponível
                </p>

                <div class="mt-2 flex items-center gap-3">
                    <p
                        class="display numeric text-[2rem] leading-none font-extrabold text-white transition-all duration-300 sm:text-[2.5rem]"
                        :class="revealed ? '' : 'blur-[11px] select-none'"
                        :aria-hidden="!revealed"
                    >
                        {{ formatCurrency(account.saldo) }}
                    </p>

                    <button
                        type="button"
                        class="shrink-0 cursor-pointer rounded-full p-2 transition-colors hover:text-white"
                        :style="{
                            color: 'var(--color-ink-muted)',
                            backgroundColor: 'rgba(255, 255, 255, 0.08)',
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

            <span class="badge badge-onink shrink-0">{{ account.agencyLabel }}</span>
        </div>

        <dl
            class="relative z-10 mt-8 grid grid-cols-2 gap-x-6 gap-y-4 border-t pt-5"
            :style="{ borderColor: 'rgba(255, 255, 255, 0.1)' }"
        >
            <div class="min-w-0">
                <dt
                    class="text-[0.6875rem] font-semibold tracking-[0.08em] uppercase"
                    :style="{ color: 'var(--color-ink-muted)' }"
                >
                    Conta
                </dt>
                <dd class="numeric mt-1 text-[0.9375rem] font-semibold text-white">
                    {{ account.id }}
                </dd>
            </div>
            <div class="min-w-0">
                <dt
                    class="text-[0.6875rem] font-semibold tracking-[0.08em] uppercase"
                    :style="{ color: 'var(--color-ink-muted)' }"
                >
                    Titular
                </dt>
                <dd class="mt-1 truncate text-[0.9375rem] font-semibold text-white">
                    {{ account.nomeAluno }}
                </dd>
            </div>
        </dl>
    </article>
</template>
