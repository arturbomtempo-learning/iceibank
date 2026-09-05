import { api } from './api';
import type { UserRole } from '@/shared/services/token-storage';

interface LoginRequest {
    usuario: string;
    senha: string;
}

export interface LoginResponse {
    token: string;
    papel: UserRole;
    expiraEmSegundos: number;
}

export function login(credentials: LoginRequest) {
    return api.post<LoginResponse>('/auth/login', credentials);
}
