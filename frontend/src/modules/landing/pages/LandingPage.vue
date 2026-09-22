<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';

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

const features = [
    {
        title: 'Extrato consolidado',
        description:
            'Suas contas nas três agências somadas em uma única chamada. Se uma agência cair, o extrato avisa o que ficou de fora em vez de mentir o total.',
        icon: 'M4 6h16M4 12h16M4 18h10',
    },
    {
        title: 'Transferência entre agências',
        description:
            'Você informa origem, destino e valor. O banco decide sozinho se resolve internamente ou se precisa falar com outra agência pela rede.',
        icon: 'M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4',
    },
    {
        title: 'Roteamento automático',
        description:
            'Nenhuma escolha manual de agência. O aplicativo descobre quem atende cada conta e envia a requisição para o endereço certo.',
        icon: 'M3 12h7l4-6h7m0 0-3-3m3 3-3 3M10 12l4 6h7m0 0-3-3m3 3-3 3',
    },
    {
        title: 'Autenticação por token',
        description:
            'Login com senha em hash e token assinado com expiração. Token ausente, inválido ou vencido é recusado antes de tocar em qualquer saldo.',
        icon: 'M12 3l7.5 3.5v5c0 4.3-3.1 8.2-7.5 9.5-4.4-1.3-7.5-5.2-7.5-9.5v-5L12 3Z',
    },
    {
        title: 'Autorização em três camadas',
        description:
            'Papel de gerente para abrir contas, posse do recurso para movimentar saldo e um token de serviço separado para as chamadas entre agências.',
        icon: 'M12 3l7.5 3.5v5c0 4.3-3.1 8.2-7.5 9.5-4.4-1.3-7.5-5.2-7.5-9.5v-5L12 3ZM9.5 12l1.8 1.8 3.4-3.4',
    },
    {
        title: 'Ordem causal preservada',
        description:
            'Cada operação recebe um timestamp lógico de Lamport. Os logs das três agências se juntam em uma linha do tempo única e auditável.',
        icon: 'M12 7v5l3.2 1.9M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z',
    },
];

const steps = [
    {
        number: '01',
        title: 'A conta escolhe a agência',
        description:
            'O número da conta define quem a guarda, pela regra id % 3. Nenhuma agência conhece as contas das outras, e recusa explicitamente operar o que não é seu.',
    },
    {
        number: '02',
        title: 'A operação encontra o caminho',
        description:
            'Transferência na mesma agência é resolvida em memória. Entre agências, a origem debita e chama a agência de destino pela rede para creditar.',
    },
    {
        number: '03',
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
    'HTTP 401 e 403 distinguidos — "não sei quem você é" não é o mesmo que "você não pode"',
];

function handleScroll(): void {
    isScrolled.value = window.scrollY > 8;
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
        <!-- ================= Navegação ================= -->
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
                <RouterLink :to="{ name: 'home' }" aria-label="ICEIBank">
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

        <!-- ================= Hero ================= -->
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
                        Sprint 1 · Relógio lógico de Lamport
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

                <!-- Visual do hero -->
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
                                <p class="section-title">Extrato consolidado</p>
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

        <!-- ================= Produto ================= -->
        <section id="produto" class="mx-auto max-w-6xl scroll-mt-24 px-5 py-20 sm:px-8 sm:py-28">
            <div data-reveal class="reveal max-w-2xl">
                <p class="section-title">O produto</p>
                <h2 class="mt-3 text-[2rem] leading-tight sm:text-[2.5rem]">
                    Tudo o que um internet banking precisa ter — e o que quase nenhum mostra.
                </h2>
                <p class="mt-4 text-[1.0625rem] text-muted">
                    A complexidade fica no backend. Na tela, a pessoa vê saldo, transfere e saca sem
                    nunca precisar saber que existem três servidores conversando.
                </p>
            </div>

            <div class="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
                <article
                    v-for="(feature, index) in features"
                    :key="feature.title"
                    data-reveal
                    class="reveal card card-interactive p-6"
                    :style="{ transitionDelay: `${index * 60}ms` }"
                >
                    <span
                        class="flex h-11 w-11 items-center justify-center rounded-2xl"
                        :style="{ backgroundColor: 'var(--color-brand-50)' }"
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
                            <path :d="feature.icon" />
                        </svg>
                    </span>

                    <h3 class="mt-5 text-[1.0625rem]">{{ feature.title }}</h3>
                    <p class="mt-2 text-sm text-muted">{{ feature.description }}</p>
                </article>
            </div>
        </section>

        <!-- ================= Arquitetura ================= -->
        <section
            id="arquitetura"
            class="scroll-mt-24"
            :style="{ backgroundColor: 'var(--color-surface)' }"
        >
            <div class="mx-auto max-w-6xl px-5 py-20 sm:px-8 sm:py-28">
                <div data-reveal class="reveal max-w-2xl">
                    <p class="section-title">Arquitetura</p>
                    <h2 class="mt-3 text-[2rem] leading-tight sm:text-[2.5rem]">
                        Contas particionadas, não replicadas.
                    </h2>
                    <p class="mt-4 text-[1.0625rem] text-muted">
                        Cada conta pertence a exatamente uma agência. É dessa decisão que nasce todo
                        o resto: a chamada pela rede, o relógio lógico e o extrato que precisa
                        conversar com os vizinhos.
                    </p>
                </div>

                <div data-reveal class="reveal mt-12 grid gap-4 sm:grid-cols-3">
                    <div
                        v-for="agency in [0, 1, 2]"
                        :key="agency"
                        class="card relative overflow-hidden p-6"
                    >
                        <div class="flex items-center justify-between gap-3">
                            <p class="display numeric text-2xl font-extrabold">0{{ agency }}</p>
                            <span
                                class="h-2 w-2 rounded-full"
                                :style="{ backgroundColor: 'var(--color-brand-500)' }"
                            />
                        </div>
                        <p class="mt-3 text-sm font-semibold">Agência {{ agency }}</p>
                        <p class="numeric mt-1 text-xs text-muted">
                            Atende contas em que id % 3 = {{ agency }}
                        </p>
                        <p
                            class="numeric mt-4 rounded-[var(--radius-xs)] px-2.5 py-1.5 text-xs"
                            :style="{
                                backgroundColor: 'var(--color-surface-sunken)',
                                color: 'var(--color-text-muted)',
                            }"
                        >
                            {{ agency }}, {{ agency + 3 }}, {{ agency + 6 }}, {{ agency + 9 }}…
                        </p>
                    </div>
                </div>

                <ol class="mt-14 grid gap-8 lg:grid-cols-3">
                    <li
                        v-for="(step, index) in steps"
                        :key="step.number"
                        data-reveal
                        class="reveal border-t pt-6"
                        :style="{
                            borderColor: 'var(--color-border-strong)',
                            transitionDelay: `${index * 80}ms`,
                        }"
                    >
                        <p
                            class="display numeric text-sm font-extrabold"
                            :style="{ color: 'var(--color-primary)' }"
                        >
                            {{ step.number }}
                        </p>
                        <h3 class="mt-3 text-[1.0625rem]">{{ step.title }}</h3>
                        <p class="mt-2 text-sm text-muted">{{ step.description }}</p>
                    </li>
                </ol>

                <div
                    data-reveal
                    class="reveal note mt-12 flex flex-wrap items-center gap-x-3 gap-y-2"
                >
                    <span class="badge badge-danger">Limitação conhecida</span>
                    <p class="text-sm">
                        Se a agência de destino cair no meio de uma transferência, o débito já
                        aplicado não é revertido. O sistema registra a inconsistência no log em vez
                        de escondê-la — resolver isso de verdade é tema de transações distribuídas.
                    </p>
                </div>
            </div>
        </section>

        <!-- ================= Segurança ================= -->
        <section id="seguranca" class="mx-auto max-w-6xl scroll-mt-24 px-5 py-20 sm:px-8 sm:py-28">
            <div class="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
                <div data-reveal class="reveal">
                    <p class="section-title">Segurança</p>
                    <h2 class="mt-3 text-[2rem] leading-tight sm:text-[2.5rem]">
                        Saber quem você é e saber o que você pode são perguntas diferentes.
                    </h2>
                    <p class="mt-4 text-[1.0625rem] text-muted">
                        A autenticação resolve a primeira. A autorização, em três camadas
                        independentes, resolve a segunda — inclusive para as chamadas que as
                        agências fazem entre si.
                    </p>
                </div>

                <div
                    data-reveal
                    class="reveal surface-ink relative overflow-hidden p-7 sm:p-8"
                    :style="{
                        borderRadius: 'var(--radius-xl)',
                        boxShadow: 'var(--shadow-lg)',
                    }"
                >
                    <div class="grain pointer-events-none absolute inset-0 opacity-60" />

                    <ul class="relative z-10 flex flex-col gap-4">
                        <li
                            v-for="point in securityPoints"
                            :key="point"
                            class="flex items-start gap-3 text-sm"
                            :style="{ color: 'var(--color-ink-muted)' }"
                        >
                            <svg
                                class="mt-0.5 h-[17px] w-[17px] shrink-0"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="var(--color-accent)"
                                stroke-width="2.4"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >
                                <path d="m4 12.5 5 5L20 6.5" />
                            </svg>
                            {{ point }}
                        </li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- ================= Chamada final ================= -->
        <section class="px-5 pb-20 sm:px-8 sm:pb-28">
            <div
                data-reveal
                class="reveal surface-ink relative mx-auto max-w-6xl overflow-hidden px-6 py-16 text-center sm:px-12 sm:py-20"
                :style="{ borderRadius: 'var(--radius-xl)', boxShadow: 'var(--shadow-lg)' }"
            >
                <div class="grain pointer-events-none absolute inset-0 opacity-70" />

                <div class="relative z-10 mx-auto max-w-2xl">
                    <h2
                        class="text-[2rem] leading-tight font-extrabold text-white sm:text-[2.75rem]"
                    >
                        Entre e veja as três agências
                        <span :style="{ color: 'var(--color-accent)' }">trabalhando juntas</span>.
                    </h2>
                    <p class="mt-5 text-[1.0625rem]" :style="{ color: 'var(--color-ink-muted)' }">
                        Abra o internet banking, transfira entre agências diferentes e acompanhe o
                        resultado chegando do outro lado da rede.
                    </p>

                    <div class="mt-9 flex flex-wrap justify-center gap-3">
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
                        Primeiro acesso? Entre como <strong class="text-white">admin</strong> com a
                        senha <strong class="text-white">admin1234</strong> para cadastrar
                        correntistas e abrir contas.
                    </p>
                </div>
            </div>
        </section>

        <!-- ================= Rodapé ================= -->
        <footer class="border-t" :style="{ borderColor: 'var(--color-border)' }">
            <div
                class="mx-auto flex max-w-6xl flex-col gap-8 px-5 py-12 sm:px-8 md:flex-row md:items-start md:justify-between"
            >
                <div class="max-w-xs">
                    <AppLogo size="sm" />
                    <p class="mt-4 text-sm text-muted">
                        Banco simplificado dividido em agências, construído para aplicar conceitos
                        de Sistemas Distribuídos em um sistema que realmente funciona.
                    </p>
                </div>

                <div class="flex flex-wrap gap-12">
                    <div>
                        <p class="section-title">Navegar</p>
                        <ul class="mt-4 flex flex-col gap-2.5">
                            <li v-for="link in navLinks" :key="link.href">
                                <a
                                    :href="link.href"
                                    class="text-sm no-underline"
                                    :style="{ color: 'var(--color-text-muted)' }"
                                >
                                    {{ link.label }}
                                </a>
                            </li>
                            <li>
                                <RouterLink
                                    :to="primaryCta.route"
                                    class="text-sm no-underline"
                                    :style="{ color: 'var(--color-text-muted)' }"
                                >
                                    {{ primaryCta.label }}
                                </RouterLink>
                            </li>
                        </ul>
                    </div>

                    <div>
                        <p class="section-title">Projeto</p>
                        <ul class="mt-4 flex flex-col gap-2.5 text-sm text-muted">
                            <li>Sprint 1 — Relógio de Lamport</li>
                            <li>Flask · Vue 3 · Tailwind</li>
                            <li>Licença MIT</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="border-t" :style="{ borderColor: 'var(--color-border)' }">
                <div
                    class="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-5 py-6 sm:px-8"
                >
                    <p class="text-xs text-muted">
                        Projeto acadêmico de Laboratório de Desenvolvimento de Aplicações Móveis e
                        Distribuídas. Não é uma instituição financeira.
                    </p>
                    <p class="text-xs text-muted">© 2026 ICEIBank</p>
                </div>
            </div>
        </footer>
    </div>
</template>
