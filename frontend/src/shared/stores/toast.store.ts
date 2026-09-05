import { defineStore } from 'pinia';
import { ref } from 'vue';

export type ToastVariant = 'success' | 'error' | 'info';

export interface Toast {
    id: number;
    variant: ToastVariant;
    title: string;
    description?: string;
}

const DISMISS_DELAY_MS = 6000;

export const useToastStore = defineStore('toast', () => {
    const toasts = ref<Toast[]>([]);
    const timers = new Map<number, ReturnType<typeof setTimeout>>();

    let nextId = 0;

    function dismiss(id: number): void {
        toasts.value = toasts.value.filter((toast) => toast.id !== id);

        const timer = timers.get(id);
        if (timer) {
            clearTimeout(timer);
            timers.delete(id);
        }
    }

    function push(variant: ToastVariant, title: string, description?: string): void {
        nextId += 1;
        const id = nextId;

        toasts.value = [...toasts.value, { id, variant, title, description }];
        timers.set(
            id,
            setTimeout(() => dismiss(id), DISMISS_DELAY_MS)
        );
    }

    function success(title: string, description?: string): void {
        push('success', title, description);
    }

    function error(title: string, description?: string): void {
        push('error', title, description);
    }

    function info(title: string, description?: string): void {
        push('info', title, description);
    }

    return { toasts, success, error, info, dismiss };
});
