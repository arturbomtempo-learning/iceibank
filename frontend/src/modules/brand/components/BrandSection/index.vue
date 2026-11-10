<script setup lang="ts">
defineProps<{
    id: string;
    ordinal: string;
    eyebrow: string;
    title: string;
    description?: string;
}>();
</script>

<template>
    <section :id="id" class="brand-section scroll-mt-32 py-14 sm:py-20 lg:scroll-mt-24">
        <header class="max-w-2xl">
            <p class="eyebrow">
                <span class="ordinal">{{ ordinal }}</span>
                {{ eyebrow }}
            </p>
            <h2 class="mt-3 text-[1.75rem] leading-[1.15] sm:text-[2.125rem]">{{ title }}</h2>
            <p v-if="description" class="mt-4 text-base text-muted sm:text-[1.0625rem]">
                {{ description }}
            </p>
        </header>

        <div class="mt-10">
            <slot />
        </div>
    </section>
</template>

<style scoped>
.brand-section + .brand-section {
    border-top: 1px solid var(--color-border);
}
</style>
