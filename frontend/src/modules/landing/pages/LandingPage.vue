<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';

import mascotFullBody from '@/assets/mascot/mascot-full-body.webp';
import AppLogo from '@/shared/components/AppLogo.vue';
import { useAuthStore } from '@/shared/stores/auth.store';

const authStore = useAuthStore();

const isScrolled = ref(false);
const isMenuOpen = ref(false);
const root = ref<HTMLElement | null>(null);

let revealObserver: IntersectionObserver | null = null;

const primaryCta = computed(() =>
    authStore.isAuthenticated
        ? { label: 'Ir para minha conta', route: { name: 'dashboard' } }
        : { label: 'Acessar o banco', route: { name: 'login' } }
);

const navLinks = [
    { href: '#produto', label: 'Produto' },
    { href: '#arquitetura', label: 'Arquitetura' },
    { href: '#seguranca', label: 'Segurança' },
];

const consolidatedAccounts = [
    { agency: 'Agência 0', account: 6, amount: 'R$ 2.500,00' },
    { agency: 'Agência 1', account: 7, amount: 'R$ 800,00' },
    { agency: 'Agência 2', account: 8, amount: 'R$ 450,00' },
];

const metrics = [
    { value: '3', label: 'agências independentes', detail: 'Cada uma com seu próprio processo' },
    { value: 'id % 3', label: 'define onde a conta vive', detail: 'Particionamento, não réplica' },
    { value: '7', label: 'tipos de evento auditados', detail: 'De abertura de conta a falha' },
    { value: '1h', label: 'de validade do token', detail: 'Sessão assinada e expirável' },
];

const highlight = {
    title: 'Extrato consolidado',
    description:
        'Somar saldos de contas espalhadas por agências diferentes não é trivial: a partição garante que nenhuma agência sozinha tenha essa informação. O extrato só responde conversando com as outras duas pela rede.',
    rows: [
        { agency: 'Agência 0', amount: 'R$ 2.500,00', available: true },
        { agency: 'Agência 1', amount: 'R$ 800,00', available: true },
        { agency: 'Agência 2', amount: 'Indisponível', available: false },
    ],
    partial: 'R$ 3.300,00',
};

const capabilities = [
    {
        title: 'Transferência entre agências',
        description:
            'Você informa origem, destino e valor. O banco decide sozinho se resolve a operação em memória ou se precisa atravessar a rede até outra agência.',
    },
    {
        title: 'Roteamento automático',
        description:
            'Nenhuma escolha manual de agência. O aplicativo descobre quem atende cada conta e envia a requisição para o endereço certo.',
    },
    {
        title: 'Autenticação por token',
        description:
            'Login com senha em hash e token assinado com expiração. Token ausente, inválido ou vencido é recusado antes de tocar em qualquer saldo.',
    },
    {
        title: 'Autorização em três camadas',
        description:
            'Papel de gerente para abrir contas, posse do recurso para movimentar saldo e um token de serviço separado para as chamadas entre agências.',
    },
    {
        title: 'Ordem causal preservada',
        description:
            'Cada operação recebe um carimbo lógico. Os registros das três agências se juntam em uma linha do tempo única e auditável.',
    },
];

type AgencyTint = { background: string; color: string };

const agencyTints: AgencyTint[] = [
    { background: 'var(--color-brand-700)', color: '#ffffff' },
    { background: 'var(--color-brand-400)', color: '#ffffff' },
    { background: 'var(--color-brand-100)', color: 'var(--color-brand-800)' },
];

const fallbackTint: AgencyTint = {
    background: 'var(--color-surface-sunken)',
    color: 'inherit',
};

function tintForAccount(accountId: number): AgencyTint {
    return agencyTints[accountId % agencyTints.length] ?? fallbackTint;
}

const steps = [
    {
        title: 'A conta escolhe a agência',
        description:
            'O número da conta define quem a guarda, pela regra id % 3. Nenhuma agência conhece as contas das outras, e recusa explicitamente operar o que não é seu.',
    },
    {
        title: 'A operação encontra o caminho',
        description:
            'Transferência na mesma agência é resolvida em memória. Entre agências, a origem debita e chama a agência de destino pela rede para creditar.',
    },
    {
        title: 'O evento entra na linha do tempo',
        description:
            'Cada passo é registrado com seu timestamp lógico. Mesmo sem relógio global, a ordem causal entre processos independentes se mantém legível.',
    },
];

const securityPoints = [
    'Senhas guardadas em hash, nunca em texto puro',
    'Token de sessão assinado, com expiração de uma hora',
    'Chamadas internas usam token de serviço de curta duração, sem identidade de usuário',
    'A rota interna não confia no papel informado por quem chama: ela consulta o repositório',
    'HTTP 401 e 403 distinguidos: "não sei quem você é" não é o mesmo que "você não pode"',
];

function handleScroll(): void {
    isScrolled.value = window.scrollY > 8;
}

function scrollToTop(): void {
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    window.scrollTo({ top: 0, behavior: prefersReducedMotion ? 'auto' : 'smooth' });
}

onMounted(() => {
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();

    if (!('IntersectionObserver' in window)) return;

    root.value?.classList.add('reveal-ready');

    revealObserver = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                if (!entry.isIntersecting) return;

                entry.target.classList.add('reveal-in');
                revealObserver?.unobserve(entry.target);
            });
        },
        { threshold: 0 }
    );

    root.value
        ?.querySelectorAll('[data-reveal]')
        .forEach((element) => revealObserver?.observe(element));
});

onBeforeUnmount(() => {
    window.removeEventListener('scroll', handleScroll);
    revealObserver?.disconnect();
});
</script>

<template>
    <div ref="root" class="min-h-screen">
        <header
            class="fixed inset-x-0 top-0 z-50 transition-all duration-300"
            :style="
                isScrolled
                    ? {
                          backgroundColor: 'rgba(255, 255, 255, 0.86)',
                          backdropFilter: 'blur(14px)',
                          borderBottom: '1px solid var(--color-border)',
                      }
                    : { borderBottom: '1px solid transparent' }
            "
        >
            <div class="mx-auto flex h-[4.5rem] max-w-6xl items-center gap-8 px-5 sm:px-8">
                <RouterLink
                    :to="{ name: 'home' }"
                    aria-label="ICEIBank, voltar ao topo"
                    @click="scrollToTop"
                >
                    <AppLogo :variant="isScrolled ? 'dark' : 'light'" size="sm" />
                </RouterLink>

                <nav class="hidden items-center gap-7 md:flex">
                    <a
                        v-for="link in navLinks"
                        :key="link.href"
                        :href="link.href"
                        class="link-nav"
                        :style="isScrolled ? undefined : { color: 'var(--color-ink-muted)' }"
                    >
                        {{ link.label }}
                    </a>
                </nav>

                <div class="ml-auto flex items-center gap-3">
                    <RouterLink
                        :to="primaryCta.route"
                        class="btn hidden sm:inline-flex"
                        :class="isScrolled ? '' : 'btn-onink'"
                    >
                        {{ primaryCta.label }}
                    </RouterLink>

                    <button
                        type="button"
                        class="-mr-2 cursor-pointer rounded-lg p-2 md:hidden"
                        :style="{ color: isScrolled ? 'var(--color-text)' : '#ffffff' }"
                        :aria-expanded="isMenuOpen"
                        aria-label="Abrir menu"
                        @click="isMenuOpen = !isMenuOpen"
                    >
                        <svg
                            class="h-5 w-5"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="1.9"
                            stroke-linecap="round"
                        >
                            <path v-if="isMenuOpen" d="M6 6l12 12M18 6 6 18" />
                            <path v-else d="M4 7h16M4 12h16M4 17h16" />
                        </svg>
                    </button>
                </div>
            </div>

            <div
                v-if="isMenuOpen"
                class="border-t px-5 py-4 md:hidden"
                :style="{
                    backgroundColor: 'var(--color-surface)',
                    borderColor: 'var(--color-border)',
                }"
            >
                <nav class="flex flex-col gap-1">
                    <a
                        v-for="link in navLinks"
                        :key="link.href"
                        :href="link.href"
                        class="rounded-[var(--radius)] px-3 py-2.5 text-[0.9375rem] font-medium no-underline"
                        :style="{ color: 'var(--color-text)' }"
                        @click="isMenuOpen = false"
                    >
                        {{ link.label }}
                    </a>

                    <RouterLink
                        :to="primaryCta.route"
                        class="btn btn-block mt-3 sm:hidden"
                        @click="isMenuOpen = false"
                    >
                        {{ primaryCta.label }}
                    </RouterLink>
                </nav>
            </div>
        </header>

        <section class="surface-ink relative overflow-hidden pt-[4.5rem]">
            <div class="grain pointer-events-none absolute inset-0 opacity-70" />

            <div
                class="pointer-events-none absolute -top-40 -right-32 h-[34rem] w-[34rem] rounded-full opacity-[0.07]"
                :style="{ border: '1px solid #ffffff' }"
            />
            <div
                class="pointer-events-none absolute -top-20 -right-10 h-[22rem] w-[22rem] rounded-full opacity-[0.07]"
                :style="{ border: '1px solid #ffffff' }"
            />

            <div
                class="relative z-10 mx-auto grid max-w-6xl items-center gap-14 px-5 py-20 sm:px-8 lg:grid-cols-[1.05fr_1fr] lg:gap-10 lg:py-28"
            >
                <div>
                    <span class="badge badge-onink">
                        <span
                            class="h-1.5 w-1.5 rounded-full"
                            :style="{ backgroundColor: 'var(--color-accent)' }"
                        />
                        Internet banking distribuído
                    </span>

                    <h1
                        class="mt-6 text-[2.75rem] leading-[1.05] font-extrabold text-white sm:text-[3.5rem] lg:text-[4rem]"
                    >
                        Um banco inteiro.
                        <br />
                        <span :style="{ color: 'var(--color-accent)' }">Três agências</span>
                        que nunca se confundem.
                    </h1>

                    <p
                        class="mt-6 max-w-lg text-base leading-relaxed sm:text-[1.0625rem]"
                        :style="{ color: 'var(--color-ink-muted)' }"
                    >
                        O ICEIBank reparte as contas entre três servidores independentes e mesmo
                        assim entrega a experiência de um internet banking único: saldo somado,
                        transferência que atravessa a rede e ordem dos eventos preservada.
                    </p>

                    <div class="mt-9 flex flex-wrap items-center gap-3">
                        <RouterLink :to="primaryCta.route" class="btn">
                            {{ primaryCta.label }}
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
                        </RouterLink>

                        <a href="#arquitetura" class="btn btn-onink">Ver como funciona</a>
                    </div>

                    <dl
                        class="mt-12 grid max-w-md grid-cols-3 gap-6 border-t pt-7"
                        :style="{ borderColor: 'var(--color-ink-line)' }"
                    >
                        <div>
                            <dt class="display numeric text-2xl font-extrabold text-white">3</dt>
                            <dd class="mt-1 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                Agências no ar
                            </dd>
                        </div>
                        <div>
                            <dt class="display numeric text-2xl font-extrabold text-white">1</dt>
                            <dd class="mt-1 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                Chamada por extrato
                            </dd>
                        </div>
                        <div>
                            <dt class="display numeric text-2xl font-extrabold text-white">0</dt>
                            <dd class="mt-1 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                Relógios globais
                            </dd>
                        </div>
                    </dl>
                </div>

                <div class="relative mx-auto w-full max-w-sm lg:max-w-none">
                    <div
                        class="float-slow card relative z-10 p-6"
                        :style="{
                            borderRadius: 'var(--radius-xl)',
                            boxShadow: '0 40px 80px -30px rgba(0, 0, 0, 0.55)',
                        }"
                    >
                        <div class="flex items-start justify-between gap-3">
                            <div>
                                <p class="eyebrow">Extrato consolidado</p>
                                <p class="display numeric mt-2 text-3xl font-extrabold">
                                    R$ 3.750,00
                                </p>
                            </div>
                            <span class="badge badge-primary">3 agências</span>
                        </div>

                        <ul
                            class="mt-6 flex flex-col gap-3 border-t pt-5"
                            :style="{ borderColor: 'var(--color-border)' }"
                        >
                            <li
                                v-for="item in consolidatedAccounts"
                                :key="item.account"
                                class="flex items-center gap-3"
                            >
                                <span
                                    class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-[0.6875rem] font-bold"
                                    :style="{
                                        backgroundColor: 'var(--color-brand-50)',
                                        color: 'var(--color-primary-dark)',
                                    }"
                                >
                                    {{ item.account }}
                                </span>
                                <div class="min-w-0 flex-1">
                                    <p class="text-[0.8125rem] font-semibold">{{ item.agency }}</p>
                                    <p class="text-xs text-muted">Conta {{ item.account }}</p>
                                </div>
                                <p class="numeric text-[0.9375rem] font-semibold">
                                    {{ item.amount }}
                                </p>
                            </li>
                        </ul>
                    </div>

                    <div
                        class="float-slower absolute -top-6 -left-4 z-20 flex items-center gap-2.5 rounded-full py-2.5 pr-4 pl-3 sm:-left-10"
                        :style="{
                            backgroundColor: 'var(--color-ink-raised)',
                            border: '1px solid var(--color-ink-line)',
                            boxShadow: '0 18px 40px -16px rgba(0, 0, 0, 0.6)',
                        }"
                    >
                        <span
                            class="flex h-6 w-6 items-center justify-center rounded-full"
                            :style="{ backgroundColor: 'rgba(87, 227, 168, 0.18)' }"
                        >
                            <svg
                                class="h-3.5 w-3.5"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="var(--color-accent)"
                                stroke-width="3"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >
                                <path d="m4 12.5 5 5L20 6.5" />
                            </svg>
                        </span>
                        <p class="text-xs font-semibold text-white">Transferência concluída</p>
                    </div>

                    <div
                        class="float-slow absolute -right-3 -bottom-7 z-20 rounded-[var(--radius-md)] px-4 py-3 sm:-right-8"
                        :style="{
                            backgroundColor: 'var(--color-surface)',
                            border: '1px solid var(--color-border)',
                            boxShadow: '0 18px 40px -16px rgba(0, 0, 0, 0.45)',
                            color: 'var(--color-text)',
                        }"
                    >
                        <p
                            class="text-[0.6875rem] font-semibold tracking-[0.08em] text-muted uppercase"
                        >
                            Lamport
                        </p>
                        <p class="numeric mt-0.5 text-sm font-bold">L = 42 · Agência 2</p>
                    </div>
                </div>
            </div>

            <div class="relative z-10 border-t" :style="{ borderColor: 'var(--color-ink-line)' }">
                <dl class="mx-auto grid max-w-6xl grid-cols-2 gap-px px-5 sm:px-8 lg:grid-cols-4">
                    <div v-for="metric in metrics" :key="metric.label" class="py-7 pr-6">
                        <dt class="display numeric text-[1.75rem] font-extrabold text-white">
                            {{ metric.value }}
                        </dt>
                        <dd class="mt-1.5">
                            <p class="text-sm font-semibold text-white">{{ metric.label }}</p>
                            <p class="mt-0.5 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                {{ metric.detail }}
                            </p>
                        </dd>
                    </div>
                </dl>
            </div>
        </section>

        <section id="produto" class="mx-auto max-w-6xl scroll-mt-24 px-5 py-20 sm:px-8 sm:py-28">
            <div class="grid gap-12 lg:grid-cols-[0.95fr_1fr] lg:gap-16">
                <div>
                    <div data-reveal class="reveal">
                        <p class="eyebrow">O produto</p>
                        <h2 class="mt-4 text-[2rem] leading-[1.12] sm:text-[2.5rem]">
                            A complexidade fica no backend. Na tela, fica só o banco.
                        </h2>
                        <p class="mt-5 text-[1.0625rem] text-muted">
                            A pessoa vê saldo, transfere e saca sem nunca precisar saber que existem
                            três servidores conversando por baixo.
                        </p>
                    </div>

                    <article
                        data-reveal
                        class="reveal surface-ink relative mt-10 overflow-hidden p-6 sm:p-7"
                        :style="{ borderRadius: 'var(--radius-lg)' }"
                    >
                        <div class="grain pointer-events-none absolute inset-0 opacity-50" />

                        <div class="relative z-10">
                            <div class="flex items-center gap-3">
                                <span class="ordinal ordinal-onink">01</span>
                                <span class="badge badge-onink">Funcionalidade autoral</span>
                            </div>
                            <h3 class="mt-4 text-[1.25rem] text-white">{{ highlight.title }}</h3>
                            <p class="mt-3 text-sm" :style="{ color: 'var(--color-ink-muted)' }">
                                {{ highlight.description }}
                            </p>

                            <ul class="mt-6">
                                <li
                                    v-for="row in highlight.rows"
                                    :key="row.agency"
                                    class="flex items-center justify-between gap-4 border-b py-3"
                                    :style="{ borderColor: 'rgba(255, 255, 255, 0.1)' }"
                                >
                                    <span class="text-[0.8125rem] font-medium text-white">
                                        {{ row.agency }}
                                    </span>
                                    <span
                                        v-if="row.available"
                                        class="numeric text-[0.8125rem] font-semibold text-white"
                                    >
                                        {{ row.amount }}
                                    </span>
                                    <span v-else class="badge badge-danger">{{ row.amount }}</span>
                                </li>
                            </ul>

                            <div class="mt-4 flex items-baseline justify-between gap-4">
                                <p class="text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                    Total do que respondeu
                                </p>
                                <p
                                    class="display numeric text-xl font-extrabold"
                                    :style="{ color: 'var(--color-accent)' }"
                                >
                                    {{ highlight.partial }}
                                </p>
                            </div>

                            <p class="mt-3 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                Quando uma agência não responde, o extrato diz quais ficaram de fora
                                em vez de apresentar um total incompleto como se fosse o número
                                certo.
                            </p>
                        </div>
                    </article>
                </div>

                <ul class="lg:pt-2">
                    <li
                        v-for="(capability, index) in capabilities"
                        :key="capability.title"
                        data-reveal
                        class="reveal border-t py-6 last:pb-0"
                        :style="{
                            borderColor: 'var(--color-border)',
                            transitionDelay: `${index * 60}ms`,
                        }"
                    >
                        <div class="flex gap-5">
                            <p class="ordinal shrink-0 pt-1">
                                {{ String(index + 2).padStart(2, '0') }}
                            </p>
                            <div>
                                <h3 class="text-[1.0625rem]">{{ capability.title }}</h3>
                                <p class="mt-2 text-sm text-muted">{{ capability.description }}</p>
                            </div>
                        </div>
                    </li>
                </ul>
            </div>
        </section>

        <section
            id="arquitetura"
            class="scroll-mt-24"
            :style="{ backgroundColor: 'var(--color-surface)' }"
        >
            <div class="motif-rule h-8 opacity-60" />

            <div class="mx-auto max-w-6xl px-5 py-20 sm:px-8 sm:py-28">
                <div class="grid gap-12 lg:grid-cols-[0.85fr_1fr] lg:gap-16">
                    <div data-reveal class="reveal">
                        <p class="eyebrow">Arquitetura</p>
                        <h2 class="mt-4 text-[2rem] leading-[1.12] sm:text-[2.5rem]">
                            Contas particionadas, não replicadas.
                        </h2>
                        <p class="mt-5 text-[1.0625rem] text-muted">
                            Cada conta pertence a exatamente uma agência, definida pelo resto da
                            divisão do seu número por três. É dessa decisão que nasce todo o resto:
                            a chamada pela rede, o carimbo lógico e o extrato que precisa conversar
                            com os vizinhos.
                        </p>
                    </div>

                    <div data-reveal class="reveal">
                        <div class="flex items-baseline justify-between gap-4">
                            <p class="eyebrow">Onde cada conta vive</p>
                            <p
                                class="numeric text-xs font-bold"
                                :style="{ color: 'var(--color-primary)' }"
                            >
                                id % 3
                            </p>
                        </div>

                        <div class="mt-4 grid grid-cols-6 gap-1.5 sm:grid-cols-12">
                            <div
                                v-for="account in 12"
                                :key="account"
                                class="numeric flex aspect-square items-center justify-center rounded-[var(--radius-xs)] text-xs font-bold"
                                :style="tintForAccount(account - 1)"
                                :title="`Conta ${account - 1} na Agência ${(account - 1) % 3}`"
                            >
                                {{ account - 1 }}
                            </div>
                        </div>

                        <ul class="mt-6">
                            <li
                                v-for="agency in 3"
                                :key="agency"
                                class="flex items-center gap-3 border-t py-3"
                                :style="{ borderColor: 'var(--color-border)' }"
                            >
                                <span
                                    class="h-3 w-3 shrink-0 rounded-[3px]"
                                    :style="{
                                        backgroundColor: tintForAccount(agency - 1).background,
                                    }"
                                />
                                <p class="text-sm font-semibold">Agência {{ agency - 1 }}</p>
                                <p class="numeric ml-auto text-xs text-muted">
                                    {{ agency - 1 }}, {{ agency + 2 }}, {{ agency + 5 }},
                                    {{ agency + 8 }}…
                                </p>
                            </li>
                        </ul>
                    </div>
                </div>

                <ol class="mt-16 grid gap-x-12 gap-y-10 lg:grid-cols-3">
                    <li
                        v-for="(step, index) in steps"
                        :key="step.title"
                        data-reveal
                        class="reveal border-t pt-5"
                        :style="{
                            borderColor: 'var(--color-border-strong)',
                            transitionDelay: `${index * 70}ms`,
                        }"
                    >
                        <p class="ordinal">Passo {{ index + 1 }}</p>
                        <h3 class="mt-3 text-[1.0625rem]">{{ step.title }}</h3>
                        <p class="mt-2.5 text-sm text-muted">{{ step.description }}</p>
                    </li>
                </ol>

                <div data-reveal class="reveal mt-14 max-w-3xl">
                    <span class="badge badge-danger">Limitação conhecida</span>
                    <p class="mt-3 text-sm text-muted">
                        Se a agência de destino cair no meio de uma transferência, o débito já
                        aplicado não é revertido. O sistema registra a inconsistência em vez de
                        escondê-la. Resolver isso de verdade é assunto de transações distribuídas.
                    </p>
                </div>
            </div>
        </section>

        <section id="seguranca" class="mx-auto max-w-6xl scroll-mt-24 px-5 py-20 sm:px-8 sm:py-28">
            <div class="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
                <div data-reveal class="reveal">
                    <p class="eyebrow">Segurança</p>
                    <h2 class="mt-4 text-[2rem] leading-[1.12] sm:text-[2.5rem]">
                        Saber quem você é e saber o que você pode são perguntas diferentes.
                    </h2>
                    <p class="mt-5 text-[1.0625rem] text-muted">
                        A autenticação responde a primeira. A autorização, em três camadas
                        independentes, responde a segunda, inclusive para as chamadas que as
                        agências fazem entre si.
                    </p>
                </div>

                <div
                    data-reveal
                    class="reveal surface-ink relative overflow-hidden p-7 sm:p-9"
                    :style="{ borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-lg)' }"
                >
                    <div class="grain pointer-events-none absolute inset-0 opacity-50" />

                    <ol class="relative z-10">
                        <li
                            v-for="(point, index) in securityPoints"
                            :key="point"
                            class="flex gap-4 border-b py-4 first:pt-0 last:border-b-0 last:pb-0"
                            :style="{ borderColor: 'rgba(255, 255, 255, 0.1)' }"
                        >
                            <span class="ordinal ordinal-onink shrink-0 pt-0.5">
                                {{ String(index + 1).padStart(2, '0') }}
                            </span>
                            <p class="text-sm" :style="{ color: 'var(--color-ink-muted)' }">
                                {{ point }}
                            </p>
                        </li>
                    </ol>
                </div>
            </div>
        </section>

        <section class="px-5 pb-20 sm:px-8 sm:pb-28">
            <div
                data-reveal
                class="reveal surface-ink relative mx-auto max-w-6xl overflow-hidden px-6 py-14 sm:px-12 sm:py-16"
                :style="{ borderRadius: 'var(--radius-xl)', boxShadow: 'var(--shadow-lg)' }"
            >
                <div class="grain pointer-events-none absolute inset-0 opacity-70" />

                <div
                    class="relative z-10 grid items-center gap-10 text-center lg:grid-cols-[1.2fr_0.8fr] lg:gap-12 lg:text-left"
                >
                    <div class="mx-auto max-w-2xl lg:mx-0">
                        <h2
                            class="text-[2rem] leading-tight font-extrabold text-white sm:text-[2.75rem]"
                        >
                            Entre e veja as três agências
                            <span :style="{ color: 'var(--color-accent)' }">trabalhando juntas</span
                            >.
                        </h2>
                        <p
                            class="mt-5 text-[1.0625rem]"
                            :style="{ color: 'var(--color-ink-muted)' }"
                        >
                            Abra o internet banking, transfira entre agências diferentes e acompanhe
                            o resultado chegando do outro lado da rede.
                        </p>

                        <div class="mt-9 flex flex-wrap justify-center gap-3 lg:justify-start">
                            <RouterLink :to="primaryCta.route" class="btn">
                                {{ primaryCta.label }}
                            </RouterLink>
                            <a href="#produto" class="btn btn-onink">Rever os recursos</a>
                        </div>

                        <p
                            v-if="!authStore.isAuthenticated"
                            class="mt-8 text-[0.8125rem]"
                            :style="{ color: 'var(--color-ink-muted)' }"
                        >
                            Primeiro acesso? Entre como
                            <strong class="text-white">admin</strong> com a senha
                            <strong class="text-white">admin1234</strong> para cadastrar
                            correntistas e abrir contas.
                        </p>
                    </div>

                    <img
                        :src="mascotFullBody"
                        width="642"
                        height="760"
                        alt="Mascote do ICEIBank, um castor de moletom segurando um cartão do banco"
                        class="mx-auto w-full max-w-[200px] lg:max-w-[280px]"
                        loading="lazy"
                        decoding="async"
                    />
                </div>
            </div>
        </section>

        <footer class="border-t" :style="{ borderColor: 'var(--color-border)' }">
            <div class="mx-auto max-w-6xl px-5 py-14 sm:px-8">
                <div class="grid gap-10 md:grid-cols-[1.4fr_1fr_1fr]">
                    <div class="max-w-sm">
                        <RouterLink
                            :to="{ name: 'home' }"
                            class="inline-block"
                            aria-label="ICEIBank, voltar ao topo"
                            @click="scrollToTop"
                        >
                            <AppLogo size="sm" />
                        </RouterLink>
                        <p class="mt-4 text-sm text-muted">
                            Internet banking distribuído em três agências independentes, com saldo
                            consolidado, transferências entre agências e sessão autenticada.
                        </p>
                    </div>

                    <div>
                        <p class="eyebrow">O banco</p>
                        <ul class="mt-4 flex flex-col gap-3">
                            <li v-for="link in navLinks" :key="link.href">
                                <a :href="link.href" class="link-nav text-sm">{{ link.label }}</a>
                            </li>
                        </ul>
                    </div>

                    <div>
                        <p class="eyebrow">Sua conta</p>
                        <ul class="mt-4 flex flex-col gap-3">
                            <li>
                                <RouterLink :to="primaryCta.route" class="link-nav text-sm">
                                    {{ primaryCta.label }}
                                </RouterLink>
                            </li>
                            <li>
                                <a href="#seguranca" class="link-nav text-sm">
                                    Segurança da sua conta
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="border-t" :style="{ borderColor: 'var(--color-border)' }">
                <div
                    class="mx-auto flex max-w-6xl flex-col gap-3 px-5 py-6 sm:px-8 md:flex-row md:items-center md:justify-between"
                >
                    <p class="max-w-2xl text-xs text-muted">
                        O ICEIBank é um projeto acadêmico e não é uma instituição financeira
                        autorizada a funcionar no país. Os valores exibidos não representam dinheiro
                        real.
                    </p>
                    <p class="shrink-0 text-xs text-muted">
                        © 2026 ICEIBank. Todos os direitos reservados.
                    </p>
                </div>
            </div>
        </footer>
    </div>
</template>
