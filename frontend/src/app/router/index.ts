import { createRouter, createWebHistory } from 'vue-router';

import { applyRouteHead } from '@/app/seo/head';
import { useAuthStore } from '@/shared/stores/auth.store';

import { routes } from './routes';

export const router = createRouter({
    history: createWebHistory(),
    routes,
    scrollBehavior(to, from, savedPosition) {
        if (savedPosition) return savedPosition;
        if (to.path === from.path) return false;
        return { top: 0 };
    },
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

router.afterEach((to) => applyRouteHead(to));
