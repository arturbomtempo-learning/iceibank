import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios';

import { useAgencyStore } from '@/shared/stores/agency.store';
import { useToastStore } from '@/shared/stores/toast.store';
import { useUiStore } from '@/shared/stores/ui.store';

import { readSession } from './token-storage';

declare module 'axios' {
    export interface AxiosRequestConfig {
        accountId?: number;
    }
}

interface ApiErrorBody {
    erro?: string;
}

type UnauthorizedHandler = () => void;

let handleUnauthorized: UnauthorizedHandler = () => {};

export function setUnauthorizedHandler(handler: UnauthorizedHandler): void {
    handleUnauthorized = handler;
}

export const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL,
    timeout: 10000,
    headers: { 'Content-Type': 'application/json' },
});

function withAgencyAndToken(request: InternalAxiosRequestConfig): InternalAxiosRequestConfig {
    request.baseURL = useAgencyStore().resolveBaseUrl(request.accountId);

    const session = readSession();
    if (session) {
        request.headers.set('Authorization', `Bearer ${session.token}`);
    }

    return request;
}

export function extractErrorMessage(error: unknown): string {
    if (!axios.isAxiosError(error)) {
        return 'Não foi possível concluir a operação.';
    }

    const requestError = error as AxiosError<ApiErrorBody>;

    if (requestError.response?.data?.erro) {
        return requestError.response.data.erro;
    }

    if (requestError.code === 'ECONNABORTED') {
        return 'A agência demorou demais para responder.';
    }

    if (!requestError.response) {
        return 'Não foi possível falar com a agência responsável. Verifique se ela está no ar.';
    }

    return 'Não foi possível concluir a operação.';
}

api.interceptors.request.use((request) => {
    useUiStore().startLoading();
    return withAgencyAndToken(request);
});

api.interceptors.response.use(
    (response) => {
        useUiStore().stopLoading();
        return response;
    },
    (error: unknown) => {
        useUiStore().stopLoading();

        const message = extractErrorMessage(error);
        const isUnauthorized = axios.isAxiosError(error) && error.response?.status === 401;
        const isLoginAttempt = axios.isAxiosError(error) && error.config?.url === '/auth/login';

        if (isUnauthorized && !isLoginAttempt) {
            useToastStore().error('Sessão encerrada', 'Faça login novamente para continuar.');
            handleUnauthorized();
            return Promise.reject(error);
        }

        useToastStore().error('Operação não concluída', message);
        return Promise.reject(error);
    }
);
