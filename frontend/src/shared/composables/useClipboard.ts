import { useToastStore } from '@/shared/stores/toast.store';

export function useClipboard() {
    const toastStore = useToastStore();

    async function copy(value: string, label: string): Promise<void> {
        try {
            await navigator.clipboard.writeText(value);
            toastStore.success('Copiado', `${label} foi copiado para a área de transferência.`);
        } catch {
            toastStore.error(
                'Não foi possível copiar',
                'O navegador bloqueou o acesso à área de transferência.'
            );
        }
    }

    return { copy };
}
