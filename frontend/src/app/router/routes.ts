import type { RouteRecordRaw } from 'vue-router';

import { sitePages } from '@/app/seo/pages';
import AppLayout from '@/shared/layouts/AppLayout/index.vue';

export const routes: RouteRecordRaw[] = [
    {
        path: sitePages.home.path,
        name: 'home',
        component: () => import('@/modules/landing/pages/LandingPage/index.vue'),
        meta: { seo: sitePages.home },
    },
    {
        path: sitePages.brand.path,
        name: 'brand',
        component: () => import('@/modules/brand/pages/BrandPage/index.vue'),
        meta: { seo: sitePages.brand },
    },
    {
        path: sitePages.login.path,
        name: 'login',
        component: () => import('@/modules/auth/pages/LoginPage/index.vue'),
        meta: { requiresGuest: true, seo: sitePages.login },
    },
    {
        path: '/',
        component: AppLayout,
        meta: { requiresAuth: true },
        children: [
            {
                path: sitePages.dashboard.path,
                name: 'dashboard',
                component: () => import('@/modules/home/pages/DashboardPage/index.vue'),
                meta: { seo: sitePages.dashboard },
            },
            {
                path: sitePages.deposit.path,
                name: 'deposit',
                component: () => import('@/modules/accounts/pages/DepositPage/index.vue'),
                meta: { seo: sitePages.deposit },
            },
            {
                path: sitePages.withdraw.path,
                name: 'withdraw',
                component: () => import('@/modules/accounts/pages/WithdrawPage/index.vue'),
                meta: { seo: sitePages.withdraw },
            },
            {
                path: sitePages.transfer.path,
                name: 'transfer',
                component: () => import('@/modules/transfers/pages/TransferPage/index.vue'),
                meta: { seo: sitePages.transfer },
            },
            {
                path: sitePages.newAccount.path,
                name: 'new-account',
                component: () => import('@/modules/accounts/pages/NewAccountPage/index.vue'),
                meta: { requiresManager: true, seo: sitePages.newAccount },
            },
            {
                path: sitePages.newCustomer.path,
                name: 'new-customer',
                component: () => import('@/modules/accounts/pages/NewCustomerPage/index.vue'),
                meta: { requiresManager: true, seo: sitePages.newCustomer },
            },
        ],
    },
    {
        path: '/:pathMatch(.*)*',
        redirect: { name: 'home' },
    },
];
