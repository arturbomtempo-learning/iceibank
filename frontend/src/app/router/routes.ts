import type { RouteRecordRaw } from 'vue-router';

import AppLayout from '@/shared/layouts/AppLayout.vue';

export const routes: RouteRecordRaw[] = [
    {
        path: '/login',
        name: 'login',
        component: () => import('@/modules/auth/pages/LoginPage.vue'),
        meta: { requiresGuest: true },
    },
    {
        path: '/',
        component: AppLayout,
        meta: { requiresAuth: true },
        children: [
            {
                path: '',
                name: 'dashboard',
                component: () => import('@/modules/home/pages/DashboardPage.vue'),
            },
            {
                path: 'depositar',
                name: 'deposit',
                component: () => import('@/modules/accounts/pages/DepositPage.vue'),
            },
            {
                path: 'sacar',
                name: 'withdraw',
                component: () => import('@/modules/accounts/pages/WithdrawPage.vue'),
            },
            {
                path: 'transferir',
                name: 'transfer',
                component: () => import('@/modules/transfers/pages/TransferPage.vue'),
            },
            {
                path: 'abrir-conta',
                name: 'new-account',
                component: () => import('@/modules/accounts/pages/NewAccountPage.vue'),
                meta: { requiresManager: true },
            },
            {
                path: 'novo-correntista',
                name: 'new-customer',
                component: () => import('@/modules/accounts/pages/NewCustomerPage.vue'),
                meta: { requiresManager: true },
            },
        ],
    },
    {
        path: '/:pathMatch(.*)*',
        redirect: { name: 'dashboard' },
    },
];
