<script setup lang="ts">
import { computed, useId } from 'vue';

const props = defineProps<{
    label: string;
    modelValue: string | number | null;
    type?: 'text' | 'password' | 'number';
    placeholder?: string;
    error?: string;
    hint?: string;
    autocomplete?: string;
    prefix?: string;
    disabled?: boolean;
}>();

const emit = defineEmits<{
    'update:modelValue': [value: string | number | null];
}>();

const inputId = useId();

const inputType = computed(() => props.type ?? 'text');

function handleInput(event: Event): void {
    const target = event.target as HTMLInputElement;

    if (inputType.value !== 'number') {
        emit('update:modelValue', target.value);
        return;
    }

    emit('update:modelValue', target.value === '' ? null : Number(target.value));
}
</script>

<template>
    <div class="flex flex-col gap-1.5">
        <label
            :for="inputId"
            class="text-[0.8125rem] font-semibold"
            :style="{ color: 'var(--color-text)' }"
        >
            {{ label }}
        </label>

        <div class="relative flex items-center">
            <span
                v-if="prefix"
                class="pointer-events-none absolute left-3.5 text-sm font-medium"
                :style="{ color: 'var(--color-text-muted)' }"
            >
                {{ prefix }}
            </span>
            <input
                :id="inputId"
                class="input"
                :class="{ 'input--invalid': Boolean(error) }"
                :style="prefix ? { paddingLeft: '2.5rem' } : undefined"
                :type="inputType"
                :value="modelValue ?? ''"
                :placeholder="placeholder"
                :autocomplete="autocomplete"
                :disabled="disabled"
                step="any"
                @input="handleInput"
            />
        </div>

        <p
            v-if="error"
            class="flex items-center gap-1.5 text-xs font-medium"
            :style="{ color: 'var(--color-danger)' }"
        >
            <svg
                class="h-3.5 w-3.5 shrink-0"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.2"
                stroke-linecap="round"
                stroke-linejoin="round"
            >
                <circle cx="12" cy="12" r="9" />
                <path d="M12 7.5v5M12 16h.01" />
            </svg>
            {{ error }}
        </p>
        <p v-else-if="hint" class="text-xs text-muted">{{ hint }}</p>
    </div>
</template>
