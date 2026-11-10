import { fileURLToPath, URL } from 'node:url';

import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';
import { defineConfig, loadEnv } from 'vite';
import vueDevTools from 'vite-plugin-vue-devtools';

import { seo } from './vite-plugins/seo.ts';

const DEFAULT_SITE_URL = 'http://localhost:5173';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, fileURLToPath(new URL('.', import.meta.url)), '');

    return {
        plugins: [
            vue(),
            vueDevTools(),
            tailwindcss(),
            seo({ siteUrl: env.SITE_URL || DEFAULT_SITE_URL }),
        ],
        resolve: {
            alias: {
                '@': fileURLToPath(new URL('./src', import.meta.url)),
            },
        },
    };
});
