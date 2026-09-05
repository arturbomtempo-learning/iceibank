import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

import {
    clearSession,
    readSession,
    writeSession,
    type StoredSession,
} from '@/shared/services/token-storage';

import { login as requestLogin } from '../services/auth.service';

export const useAuthStore = defineStore('auth', () => {
    const session = ref<StoredSession | null>(readSession());

    const isAuthenticated = computed(() => session.value !== null);
    const username = computed(() => session.value?.username ?? '');
    const role = computed(() => session.value?.role ?? null);
    const isManager = computed(() => session.value?.role === 'admin');

    async function signIn(username: string, password: string): Promise<void> {
        const { data } = await requestLogin({ usuario: username, senha: password });

        const authenticatedSession: StoredSession = {
            token: data.token,
            username,
            role: data.papel,
            expiresAt: Date.now() + data.expiraEmSegundos * 1000,
        };

        writeSession(authenticatedSession);
        session.value = authenticatedSession;
    }

    function signOut(): void {
        clearSession();
        session.value = null;
    }

    function syncFromStorage(): void {
        session.value = readSession();
    }

    return { isAuthenticated, username, role, isManager, signIn, signOut, syncFromStorage };
});
