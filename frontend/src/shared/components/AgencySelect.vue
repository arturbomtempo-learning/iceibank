<script setup lang="ts">
import { computed, useId } from 'vue';

import {
    AUTOMATIC_ROUTING,
    useAgencyStore,
    type AgencySelection,
} from '@/shared/stores/agency.store';

defineProps<{
    label?: string;
    hint?: string;
}>();

const agencyStore = useAgencyStore();

const selectId = useId();

const selection = computed({
    get: () => String(agencyStore.selection),
    set: (value: string) => {
        const nextSelection: AgencySelection =
            value === AUTOMATIC_ROUTING ? AUTOMATIC_ROUTING : Number(value);

        agencyStore.select(nextSelection);
    },
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

        <select :id="selectId" v-model="selection" class="input cursor-pointer">
            <option :value="AUTOMATIC_ROUTING">Automática</option>
            <option
                v-for="agency in agencyStore.options"
                :key="agency.id"
                :value="String(agency.id)"
            >
                {{ agency.label }}
            </option>
        </select>

        <p v-if="hint" class="text-xs text-muted">{{ hint }}</p>
    </div>
</template>
