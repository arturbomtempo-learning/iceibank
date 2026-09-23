import { setUnauthorizedHandler } from '@/shared/services/api';
import { useAuthStore } from '@/shared/stores/auth.store';
import { useThemeStore } from '@/shared/stores/theme.store';

import { router } from './router';

export function initializeApp(): void {
    useThemeStore().initialize();

    const authStore = useAuthStore();
    authStore.syncFromStorage();

    setUnauthorizedHandler(() => {
        authStore.signOut();
        router.push({ name: 'login' });
    });
}
