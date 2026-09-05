import { api } from '@/shared/services/api';

export interface Account {
    id: number;
    nomeAluno: string;
    dono: string;
    saldo: number;
}

interface CreateAccountRequest {
    id: number;
    nomeAluno: string;
    dono: string;
    saldoInicial: number;
}

export function fetchAccount(accountId: number) {
    return api.get<Account>(`/contas/${accountId}`, { accountId });
}

export function createAccount(account: CreateAccountRequest) {
    return api.post<Account>('/contas', account, { accountId: account.id });
}

export function deposit(accountId: number, amount: number) {
    return api.post<Account>(`/contas/${accountId}/depositar`, { valor: amount }, { accountId });
}

export function withdraw(accountId: number, amount: number) {
    return api.post<Account>(`/contas/${accountId}/sacar`, { valor: amount }, { accountId });
}
