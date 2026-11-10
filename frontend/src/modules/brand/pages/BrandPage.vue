<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';

import mascotHead from '@/assets/mascot/mascot-head.webp';
import ColorSection from '@/modules/brand/components/sections/ColorSection.vue';
import ComponentsSection from '@/modules/brand/components/sections/ComponentsSection.vue';
import IconSection from '@/modules/brand/components/sections/IconSection.vue';
import LogoSection from '@/modules/brand/components/sections/LogoSection.vue';
import MascotSection from '@/modules/brand/components/sections/MascotSection.vue';
import PrinciplesSection from '@/modules/brand/components/sections/PrinciplesSection.vue';
import ShapeSection from '@/modules/brand/components/sections/ShapeSection.vue';
import ThemeSection from '@/modules/brand/components/sections/ThemeSection.vue';
import TypographySection from '@/modules/brand/components/sections/TypographySection.vue';
import VoiceSection from '@/modules/brand/components/sections/VoiceSection.vue';
import { brandScale, coreColors } from '@/modules/brand/data/brand.data';
import AppLogo from '@/shared/components/AppLogo.vue';
import ThemeToggle from '@/shared/components/ThemeToggle.vue';
import { useAuthStore } from '@/shared/stores/auth.store';

const authStore = useAuthStore();

const sections = [
    { id: 'principios', label: 'Princípios', component: PrinciplesSection },
    { id: 'logo', label: 'Logo', component: LogoSection },
    { id: 'cores', label: 'Cores', component: ColorSection },
    { id: 'tipografia', label: 'Tipografia', component: TypographySection },
    { id: 'mascote', label: 'Mascote', component: MascotSection },
    { id: 'temas', label: 'Temas', component: ThemeSection },
    { id: 'componentes', label: 'Componentes', component: ComponentsSection },
    { id: 'forma', label: 'Forma e movimento', component: ShapeSection },
    { id: 'icones', label: 'Iconografia', component: IconSection },
    { id: 'voz', label: 'Voz e tom', component: VoiceSection },
];

const highlights = [
    { value: String(brandScale.length), label: 'tons na escala da marca' },
    { value: '2', label: 'famílias tipográficas' },
    { value: '2', label: 'temas, claro e escuro' },
];

const primaryCta = computed(() =>
    authStore.isAuthenticated
        ? { label: 'Ir para minha conta', shortLabel: 'Minha conta', route: { name: 'dashboard' } }
        : { label: 'Acessar o banco', shortLabel: 'Entrar', route: { name: 'login' } }
);

const activeId = ref(sections[0]?.id ?? '');
const chipBar = ref<HTMLElement | null>(null);

let sectionObserver: IntersectionObserver | null = null;

function ordinalFor(index: number): string {
    return String(index + 1).padStart(2, '0');
}

function scrollChipIntoView(id: string): void {
    const bar = chipBar.value;
    const chip = bar?.querySelector<HTMLElement>(`[data-section="${id}"]`);
    if (!bar || !chip) return;

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    bar.scrollTo({
        left: chip.offsetLeft - (bar.clientWidth - chip.clientWidth) / 2,
        behavior: prefersReducedMotion ? 'auto' : 'smooth',
    });
}

watch(activeId, (id) => scrollChipIntoView(id));

onMounted(async () => {
    await nextTick();

    if (!('IntersectionObserver' in window)) return;

    sectionObserver = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) activeId.value = entry.target.id;
            });
        },
        { rootMargin: '-30% 0px -60% 0px' }
    );

    sections.forEach((section) => {
        const element = document.getElementById(section.id);
        if (element) sectionObserver?.observe(element);
    });
});

onBeforeUnmount(() => {
    sectionObserver?.disconnect();
});
</script>

<template>
    <div class="min-h-screen">
        <header
            class="sticky top-0 z-50 border-b backdrop-blur-[14px]"
            :style="{
                backgroundColor: 'var(--color-surface-glass)',
                borderColor: 'var(--color-border)',
            }"
        >
            <div class="mx-auto flex h-[4.5rem] max-w-6xl items-center gap-4 px-5 sm:px-8">
                <RouterLink :to="{ name: 'home' }" aria-label="Ir para a página inicial">
                    <AppLogo size="sm" />
                </RouterLink>

                <span
                    class="hidden h-5 w-px sm:block"
                    :style="{ backgroundColor: 'var(--color-border-strong)' }"
                    aria-hidden="true"
                />
                <span class="display hidden text-sm font-semibold text-muted sm:inline">
                    Design system
                </span>

                <div class="ml-auto flex items-center gap-2 sm:gap-3">
                    <RouterLink
                        :to="{ name: 'home' }"
                        class="link-nav mr-2 hidden text-sm md:inline"
                    >
                        Página inicial
                    </RouterLink>
                    <ThemeToggle />
                    <RouterLink
                        :to="primaryCta.route"
                        class="btn px-4 py-2 text-sm sm:px-[1.375rem] sm:py-[0.6875rem] sm:text-[0.9375rem]"
                    >
                        <span class="sm:hidden">{{ primaryCta.shortLabel }}</span>
                        <span class="hidden sm:inline">{{ primaryCta.label }}</span>
                    </RouterLink>
                </div>
            </div>
        </header>

        <section class="surface-ink relative overflow-hidden">
            <div class="grain pointer-events-none absolute inset-0 opacity-70" />
            <div
                class="pointer-events-none absolute -top-40 -right-32 h-[34rem] w-[34rem] rounded-full opacity-[0.07]"
                :style="{ border: '1px solid #ffffff' }"
            />

            <div
                class="relative z-10 mx-auto grid max-w-6xl items-center gap-12 px-5 py-16 sm:px-8 sm:py-20 lg:grid-cols-[1.15fr_1fr] lg:py-24"
            >
                <div>
                    <span class="badge badge-onink">
                        <span
                            class="h-1.5 w-1.5 rounded-full"
                            :style="{ backgroundColor: 'var(--color-accent)' }"
                        />
                        Design system · versão 1.0
                    </span>

                    <h1
                        class="mt-6 text-[2.5rem] leading-[1.06] font-extrabold text-white sm:text-[3.25rem] lg:text-[3.75rem]"
                    >
                        A identidade visual do
                        <span :style="{ color: 'var(--color-accent)' }">ICEIBank</span>.
                    </h1>

                    <p
                        class="mt-6 max-w-xl text-base leading-relaxed sm:text-[1.0625rem]"
                        :style="{ color: 'var(--color-ink-muted)' }"
                    >
                        Cores, tipografia, mascote, componentes e regras de escrita que dão ao
                        internet banking a mesma cara nas três agências. Uma referência única para
                        quem desenha e para quem desenvolve.
                    </p>

                    <div class="mt-9 flex flex-wrap gap-3">
                        <a href="#cores" class="btn">
                            Explorar as cores
                            <svg
                                class="h-4 w-4"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2.2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                aria-hidden="true"
                            >
                                <path d="M12 5v13m0 0-5-5m5 5 5-5" />
                            </svg>
                        </a>
                        <a href="#componentes" class="btn btn-onink">Ver os componentes</a>
                    </div>

                    <dl
                        class="mt-12 grid max-w-md grid-cols-3 gap-6 border-t pt-7"
                        :style="{ borderColor: 'var(--color-ink-line)' }"
                    >
                        <div v-for="item in highlights" :key="item.label">
                            <dt class="display numeric text-2xl font-extrabold text-white">
                                {{ item.value }}
                            </dt>
                            <dd class="mt-1 text-xs" :style="{ color: 'var(--color-ink-muted)' }">
                                {{ item.label }}
                            </dd>
                        </div>
                    </dl>
                </div>

                <div class="mx-auto grid w-full max-w-sm grid-cols-2 gap-3 lg:mr-0 lg:max-w-md">
                    <div
                        class="hero-tile flex items-center justify-center"
                        :style="{
                            backgroundColor: 'var(--color-ink-raised)',
                            border: '1px solid var(--color-ink-line)',
                        }"
                    >
                        <img
                            src="/favicon.svg"
                            width="80"
                            height="80"
                            alt="Símbolo do ICEIBank"
                            class="w-16 sm:w-20"
                        />
                    </div>

                    <div
                        class="hero-tile flex flex-col justify-between p-5"
                        :style="{
                            backgroundColor: 'var(--color-surface)',
                            color: 'var(--color-text)',
                        }"
                    >
                        <span
                            class="display text-[3.25rem] leading-none font-extrabold sm:text-[4rem]"
                            aria-hidden="true"
                        >
                            Aa
                        </span>
                        <span class="text-xs font-semibold text-muted">Plus Jakarta Sans</span>
                    </div>

                    <div class="hero-tile flex overflow-hidden" aria-hidden="true">
                        <span
                            v-for="color in coreColors"
                            :key="color.token"
                            class="flex-1"
                            :style="{ backgroundColor: color.hex }"
                        />
                    </div>

                    <div
                        class="hero-tile flex items-end justify-center overflow-hidden"
                        :style="{ backgroundColor: 'var(--color-brand-100)' }"
                    >
                        <img
                            :src="mascotHead"
                            width="320"
                            height="279"
                            alt="Mascote do ICEIBank"
                            class="float-slow w-[82%]"
                        />
                    </div>
                </div>
            </div>
        </section>

        <nav
            ref="chipBar"
            class="chip-bar sticky top-[4.5rem] z-40 flex gap-2 overflow-x-auto border-b px-5 py-3 backdrop-blur-[14px] sm:px-8 lg:hidden"
            :style="{
                backgroundColor: 'var(--color-surface-glass)',
                borderColor: 'var(--color-border)',
            }"
            aria-label="Seções do design system"
        >
            <a
                v-for="section in sections"
                :key="section.id"
                :href="`#${section.id}`"
                :data-section="section.id"
                class="chip"
                :class="{ 'chip--active': activeId === section.id }"
                :aria-current="activeId === section.id ? 'true' : undefined"
            >
                {{ section.label }}
            </a>
        </nav>

        <div class="mx-auto max-w-6xl px-5 sm:px-8 lg:grid lg:grid-cols-[12.5rem_1fr] lg:gap-14">
            <aside class="hidden lg:block">
                <nav class="sticky top-[4.5rem] py-16" aria-label="Seções do design system">
                    <p class="eyebrow">Nesta página</p>
                    <ol class="mt-4 flex flex-col">
                        <li v-for="(section, index) in sections" :key="section.id">
                            <a
                                :href="`#${section.id}`"
                                class="toc-link"
                                :class="{ 'toc-link--active': activeId === section.id }"
                                :aria-current="activeId === section.id ? 'true' : undefined"
                            >
                                <span class="numeric text-[0.6875rem] font-bold opacity-70">
                                    {{ ordinalFor(index) }}
                                </span>
                                {{ section.label }}
                            </a>
                        </li>
                    </ol>
                </nav>
            </aside>

            <main class="min-w-0">
                <component
                    :is="section.component"
                    v-for="(section, index) in sections"
                    :id="section.id"
                    :key="section.id"
                    :ordinal="ordinalFor(index)"
                />
            </main>
        </div>

        <footer class="border-t" :style="{ borderColor: 'var(--color-border)' }">
            <div
                class="mx-auto flex max-w-6xl flex-col gap-6 px-5 py-10 sm:px-8 md:flex-row md:items-center md:justify-between"
            >
                <div class="max-w-xl">
                    <RouterLink
                        :to="{ name: 'home' }"
                        class="inline-block"
                        aria-label="Ir para a página inicial"
                    >
                        <AppLogo size="sm" />
                    </RouterLink>
                    <p class="mt-3 text-xs text-muted">
                        O ICEIBank é um projeto acadêmico e não é uma instituição financeira
                        autorizada a funcionar no país. Os valores exibidos não representam dinheiro
                        real.
                    </p>
                </div>

                <div class="flex flex-col gap-2 md:items-end">
                    <RouterLink
                        :to="{ name: 'home' }"
                        class="link-nav self-start text-sm md:self-auto"
                    >
                        Voltar à página inicial
                    </RouterLink>
                    <p class="text-xs text-muted">© 2026 ICEIBank. Todos os direitos reservados.</p>
                </div>
            </div>
        </footer>
    </div>
</template>

<style scoped>
.hero-tile {
    aspect-ratio: 1;
    border-radius: var(--radius-xl);
    box-shadow: 0 24px 48px -24px rgba(0, 0, 0, 0.55);
}

.chip-bar {
    scrollbar-width: none;
}

.chip-bar::-webkit-scrollbar {
    display: none;
}

.chip {
    flex-shrink: 0;
    padding: 0.375rem 0.875rem;
    border: 1px solid var(--color-border);
    border-radius: 999px;
    background-color: var(--color-surface);
    color: var(--color-text-muted);
    font-size: 0.8125rem;
    font-weight: 500;
    white-space: nowrap;
    text-decoration: none;
    transition:
        background-color 0.18s var(--ease-out),
        border-color 0.18s var(--ease-out),
        color 0.18s var(--ease-out);
}

.chip:hover {
    border-color: var(--color-border-strong);
    color: var(--color-text);
}

.chip--active,
.chip--active:hover {
    border-color: var(--color-primary-line);
    background-color: var(--color-primary-soft);
    color: var(--color-primary-dark);
    font-weight: 600;
}

.toc-link {
    position: relative;
    display: flex;
    align-items: baseline;
    gap: 0.625rem;
    padding: 0.4375rem 0 0.4375rem 0.875rem;
    border-left: 2px solid var(--color-border);
    color: var(--color-text-muted);
    font-size: 0.875rem;
    font-weight: 500;
    text-decoration: none;
    transition:
        border-color 0.18s var(--ease-out),
        color 0.18s var(--ease-out);
}

.toc-link:hover {
    border-left-color: var(--color-border-strong);
    color: var(--color-text);
}

.toc-link--active,
.toc-link--active:hover {
    border-left-color: var(--color-primary);
    color: var(--color-text);
    font-weight: 600;
}
</style>
