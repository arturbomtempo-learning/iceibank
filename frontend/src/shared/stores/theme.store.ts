import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

export type Theme = 'light' | 'dark';

const STORAGE_KEY = 'iceibank.theme';

const THEME_COLOR: Record<Theme, string> = {
    light: '#f4f7f5',
    dark: '#05110e',
};

function readStoredTheme(): Theme | null {
    try {
        const stored = window.localStorage.getItem(STORAGE_KEY);
        return stored === 'light' || stored === 'dark' ? stored : null;
    } catch {
        return null;
    }
}

function systemTheme(): Theme {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

function persist(theme: Theme): void {
    try {
        window.localStorage.setItem(STORAGE_KEY, theme);
    } catch {
        return;
    }
}

function applyToDocument(theme: Theme): void {
    document.documentElement.dataset.theme = theme;

    const meta = document.querySelector('meta[name="theme-color"]');
    meta?.setAttribute('content', THEME_COLOR[theme]);
}

export const useThemeStore = defineStore('theme', () => {
    const theme = ref<Theme>(readStoredTheme() ?? systemTheme());

    const isDark = computed(() => theme.value === 'dark');

    function set(next: Theme): void {
        theme.value = next;
        persist(next);
        applyToDocument(next);
    }

    function toggle(): void {
        set(theme.value === 'dark' ? 'light' : 'dark');
    }

    function initialize(): void {
        applyToDocument(theme.value);

        if (readStoredTheme() !== null) return;

        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
            if (readStoredTheme() !== null) return;
            theme.value = event.matches ? 'dark' : 'light';
            applyToDocument(theme.value);
        });
    }

    return { theme, isDark, set, toggle, initialize };
});
