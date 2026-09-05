<script setup lang="ts">
import { computed, useId } from 'vue';

import { useAgencyStore } from '@/shared/stores/agency.store';

defineProps<{
    label?: string;
    hint?: string;
}>();

const agencyStore = useAgencyStore();

const selectId = useId();

const selectedId = computed({
    get: () => agencyStore.selectedId,
    set: (id: number) => agencyStore.select(id),
});
</script>

<template>
    <div class="flex flex-col gap-1.5">
        <label
            v-if="label"
            :for="selectId"
            class="text-[0.8125rem] font-medium"
            :style="{ color: 'var(--color-text)' }"
        >
            {{ label }}
        </label>

        <select :id="selectId" v-model="selectedId" class="input cursor-pointer">
            <option v-for="agency in agencyStore.options" :key="agency.id" :value="agency.id">
                {{ agency.label }}
            </option>
        </select>

        <p v-if="hint" class="text-xs text-muted">{{ hint }}</p>
    </div>
</template>
