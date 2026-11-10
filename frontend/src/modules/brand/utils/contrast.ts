const LIGHT_TEXT = '#ffffff';
const DARK_TEXT = '#062017';

export type ContrastLevel = 'AAA' | 'AA' | 'AA grande' | '—';

export interface ReadableText {
    color: string;
    ratio: number;
    level: ContrastLevel;
}

function channel(value: number): number {
    const scaled = value / 255;
    return scaled <= 0.03928 ? scaled / 12.92 : ((scaled + 0.055) / 1.055) ** 2.4;
}

function luminance(hex: string): number {
    const value = Number.parseInt(hex.slice(1), 16);
    const red = channel((value >> 16) & 255);
    const green = channel((value >> 8) & 255);
    const blue = channel(value & 255);

    return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

export function contrastRatio(foreground: string, background: string): number {
    const [lighter, darker] = [luminance(foreground), luminance(background)].sort((a, b) => b - a);
    return ((lighter ?? 0) + 0.05) / ((darker ?? 0) + 0.05);
}

export function contrastLevel(ratio: number): ContrastLevel {
    if (ratio >= 7) return 'AAA';
    if (ratio >= 4.5) return 'AA';
    if (ratio >= 3) return 'AA grande';
    return '—';
}

export function readableText(background: string): ReadableText {
    const onLight = contrastRatio(LIGHT_TEXT, background);
    const onDark = contrastRatio(DARK_TEXT, background);
    const ratio = Math.max(onLight, onDark);

    return {
        color: onLight >= onDark ? LIGHT_TEXT : DARK_TEXT,
        ratio,
        level: contrastLevel(ratio),
    };
}

export function formatRatio(ratio: number): string {
    return `${ratio.toFixed(1).replace('.', ',')}:1`;
}
