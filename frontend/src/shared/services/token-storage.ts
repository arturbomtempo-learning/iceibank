export type UserRole = 'admin' | 'cliente';

export interface StoredSession {
    token: string;
    username: string;
    role: UserRole;
    expiresAt: number;
}

const STORAGE_KEY = 'iceibank.session';

const storage = window.sessionStorage;

function isStoredSession(value: unknown): value is StoredSession {
    if (typeof value !== 'object' || value === null) return false;

    const candidate = value as Record<string, unknown>;

    return (
        typeof candidate.token === 'string' &&
        typeof candidate.username === 'string' &&
        (candidate.role === 'admin' || candidate.role === 'cliente') &&
        typeof candidate.expiresAt === 'number'
    );
}

export function readSession(): StoredSession | null {
    const rawSession = storage.getItem(STORAGE_KEY);
    if (!rawSession) return null;

    try {
        const parsedSession: unknown = JSON.parse(rawSession);

        if (!isStoredSession(parsedSession)) {
            clearSession();
            return null;
        }

        if (parsedSession.expiresAt <= Date.now()) {
            clearSession();
            return null;
        }

        return parsedSession;
    } catch {
        clearSession();
        return null;
    }
}

export function writeSession(session: StoredSession): void {
    storage.setItem(STORAGE_KEY, JSON.stringify(session));
}

export function clearSession(): void {
    storage.removeItem(STORAGE_KEY);
}
