import { createRouter, createWebHistory } from 'vue-router';

import { useAuthStore } from '@/shared/stores/auth.store';

import { routes } from './routes';

export const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to) => {
    const authStore = useAuthStore();
    authStore.syncFromStorage();

    if (to.meta.requiresAuth && !authStore.isAuthenticated) {
        return { name: 'login' };
    }

    if (to.meta.requiresGuest && authStore.isAuthenticated) {
        return { name: 'dashboard' };
    }

    if (to.meta.requiresManager && !authStore.isManager) {
        return { name: 'dashboard' };
    }

    return true;
});
