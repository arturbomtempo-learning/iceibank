import { api } from '@/shared/services/api';

interface TransferRequest {
    idOrigem: number;
    idDestino: number;
    valor: number;
}

export interface TransferResponse {
    mensagem: string;
}

export function transfer(request: TransferRequest) {
    return api.post<TransferResponse>('/transferencias', request);
}
