import { useAuthStore } from '@/shared/stores/auth.store';
import { setUnauthorizedHandler } from '@/shared/services/api';

import { router } from './router';

export function initializeApp(): void {
    const authStore = useAuthStore();
    authStore.syncFromStorage();

    setUnauthorizedHandler(() => {
        authStore.signOut();
        router.push({ name: 'login' });
    });
}
