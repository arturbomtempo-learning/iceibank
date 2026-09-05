import { api } from './api';

export interface Account {
    id: number;
    nomeAluno: string;
    dono: string;
    saldo: number;
    agencia: number;
}

export interface ConsolidatedStatement {
    usuario: string;
    contas: Account[];
    saldoTotal: number;
    agenciasIndisponiveis: number[];
}

interface CreateAccountRequest {
    id: number;
    nomeAluno: string;
    dono: string;
    saldoInicial: number;
}

export function fetchStatement() {
    return api.get<ConsolidatedStatement>('/extrato');
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
