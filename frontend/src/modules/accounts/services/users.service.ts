import { api } from '@/shared/services/api';

interface CreateUserRequest {
    usuario: string;
    senha: string;
}

export interface CreatedUser {
    usuario: string;
    papel: string;
}

export function createCustomer(customer: CreateUserRequest) {
    return api.post<CreatedUser>('/usuarios', customer);
}
