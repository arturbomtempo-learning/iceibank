import type { RouteRecordRaw } from 'vue-router';

import AppLayout from '@/shared/layouts/AppLayout/index.vue';

export const routes: RouteRecordRaw[] = [
    {
        path: '/',
        name: 'home',
        component: () => import('@/modules/landing/pages/LandingPage/index.vue'),
    },
    {
        path: '/identidade-visual',
        name: 'brand',
        component: () => import('@/modules/brand/pages/BrandPage/index.vue'),
    },
    {
        path: '/login',
        name: 'login',
        component: () => import('@/modules/auth/pages/LoginPage/index.vue'),
        meta: { requiresGuest: true },
    },
    {
        path: '/',
        component: AppLayout,
        meta: { requiresAuth: true },
        children: [
            {
                path: 'painel',
                name: 'dashboard',
                component: () => import('@/modules/home/pages/DashboardPage/index.vue'),
            },
            {
                path: 'depositar',
                name: 'deposit',
                component: () => import('@/modules/accounts/pages/DepositPage/index.vue'),
            },
            {
                path: 'sacar',
                name: 'withdraw',
                component: () => import('@/modules/accounts/pages/WithdrawPage/index.vue'),
            },
            {
                path: 'transferir',
                name: 'transfer',
                component: () => import('@/modules/transfers/pages/TransferPage/index.vue'),
            },
            {
                path: 'abrir-conta',
                name: 'new-account',
                component: () => import('@/modules/accounts/pages/NewAccountPage/index.vue'),
                meta: { requiresManager: true },
            },
            {
                path: 'novo-correntista',
                name: 'new-customer',
                component: () => import('@/modules/accounts/pages/NewCustomerPage/index.vue'),
                meta: { requiresManager: true },
            },
        ],
    },
    {
        path: '/:pathMatch(.*)*',
        redirect: { name: 'home' },
    },
];
