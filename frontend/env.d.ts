/// <reference types="vite/client" />

interface ImportMetaEnv {
    readonly VITE_API_URL: string;
    readonly VITE_AGENCY_URLS: string;
}

interface ImportMeta {
    readonly env: ImportMetaEnv;
}
