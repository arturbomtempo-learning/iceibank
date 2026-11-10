import type { Theme } from '@/shared/stores/theme.store';

export interface BrandShade {
    step: number;
    hex: string;
    usage: string;
}

export interface CoreColor {
    name: string;
    token: string;
    hex: string;
    description: string;
}

export interface SemanticToken {
    name: string;
    token: string;
    light: string;
    dark: string;
    usage: string;
}

export interface TokenGroup {
    title: string;
    tokens: SemanticToken[];
}

export interface TypeStyle {
    name: string;
    family: 'display' | 'sans';
    size: number;
    weight: number;
    lineHeight: number;
    tracking: number;
    previewSize: string;
    sample: string;
    uppercase?: boolean;
}

export interface RadiusToken {
    name: string;
    token: string;
    value: number;
    usage: string;
}

export interface ShadowToken {
    name: string;
    token: string;
    usage: string;
}

export interface MotionToken {
    name: string;
    duration: number;
    usage: string;
}

export interface BrandIcon {
    name: string;
    path: string;
}

export interface VoiceGuideline {
    title: string;
    description: string;
    prefer: string;
    avoid: string;
}

export interface Principle {
    title: string;
    description: string;
}

export const principles: Principle[] = [
    {
        title: 'Clareza antes de tudo',
        description:
            'Saldo, valor e destino precisam ser lidos de relance. Hierarquia forte, números tabulares e nenhum enfeite disputando a atenção com o dinheiro.',
    },
    {
        title: 'Transparência que se vê',
        description:
            'Quando uma agência não responde, a tela diz qual ficou de fora. O sistema nunca apresenta um número incompleto como se fosse o certo.',
    },
    {
        title: 'Acessível por padrão',
        description:
            'Contraste AA nos textos, foco sempre visível, alvos de toque confortáveis e respeito à preferência por movimento reduzido.',
    },
    {
        title: 'Personalidade na medida',
        description:
            'O verde vibrante e o mascote aparecem nas boas-vindas e nas conquistas. Nas decisões financeiras, a interface fica sóbria.',
    },
];

export const coreColors: CoreColor[] = [
    {
        name: 'Verde ICEI',
        token: '--color-primary',
        hex: '#0a8659',
        description: 'Cor primária. Botões, links, foco e valores positivos.',
    },
    {
        name: 'Tinta',
        token: '--color-ink',
        hex: '#062017',
        description: 'Superfícies de destaque: menu lateral, cartão de saldo e chamadas.',
    },
    {
        name: 'Menta',
        token: '--color-accent',
        hex: '#57e3a8',
        description: 'Acento sobre a tinta. Usado com moderação, só no que precisa brilhar.',
    },
];

export const brandScale: BrandShade[] = [
    { step: 50, hex: '#ebfbf4', usage: 'Fundos suaves' },
    { step: 100, hex: '#cdf5e5', usage: 'Realces leves' },
    { step: 200, hex: '#9ceac9', usage: 'Seleção de texto' },
    { step: 300, hex: '#61d9a8', usage: 'Hover de campos' },
    { step: 400, hex: '#2fc187', usage: 'Início do gradiente' },
    { step: 500, hex: '#12a56e', usage: 'Contorno de foco' },
    { step: 600, hex: '#0a8659', usage: 'Primária' },
    { step: 700, hex: '#076b48', usage: 'Primária em hover' },
    { step: 800, hex: '#08543a', usage: 'Fim do gradiente' },
    { step: 900, hex: '#08422f', usage: 'Texto sobre suave' },
    { step: 950, hex: '#04211a', usage: 'Fundo profundo' },
];

export const semanticGroups: TokenGroup[] = [
    {
        title: 'Superfícies e linhas',
        tokens: [
            {
                name: 'Fundo',
                token: '--color-bg',
                light: '#f4f7f5',
                dark: '#05110e',
                usage: 'Plano de fundo da aplicação',
            },
            {
                name: 'Superfície',
                token: '--color-surface',
                light: '#ffffff',
                dark: '#0b1c17',
                usage: 'Cartões, campos e painéis',
            },
            {
                name: 'Superfície em hover',
                token: '--color-surface-hover',
                light: '#f2f6f3',
                dark: '#11261f',
                usage: 'Itens interativos sob o cursor',
            },
            {
                name: 'Superfície rebaixada',
                token: '--color-surface-sunken',
                light: '#eef3f0',
                dark: '#081813',
                usage: 'Campos desativados e selos neutros',
            },
            {
                name: 'Borda',
                token: '--color-border',
                light: '#e3eae6',
                dark: '#1a2e28',
                usage: 'Divisores e contorno de cartões',
            },
            {
                name: 'Borda forte',
                token: '--color-border-strong',
                light: '#d2ddd7',
                dark: '#2a4438',
                usage: 'Contorno de campos e botões secundários',
            },
        ],
    },
    {
        title: 'Texto',
        tokens: [
            {
                name: 'Texto',
                token: '--color-text',
                light: '#0b1f18',
                dark: '#e7efeb',
                usage: 'Títulos, valores e conteúdo principal',
            },
            {
                name: 'Texto secundário',
                token: '--color-text-muted',
                light: '#5f7369',
                dark: '#93a9a0',
                usage: 'Descrições, legendas e rótulos',
            },
        ],
    },
    {
        title: 'Marca',
        tokens: [
            {
                name: 'Primária',
                token: '--color-primary',
                light: '#0a8659',
                dark: '#14b077',
                usage: 'Ação principal e destaques',
            },
            {
                name: 'Primária forte',
                token: '--color-primary-dark',
                light: '#076b48',
                dark: '#35c78d',
                usage: 'Hover da ação principal',
            },
            {
                name: 'Primária suave',
                token: '--color-primary-soft',
                light: '#ebfbf4',
                dark: '#0f2c23',
                usage: 'Fundo de selos e avisos da marca',
            },
            {
                name: 'Linha primária',
                token: '--color-primary-line',
                light: '#9ceac9',
                dark: '#1f4a3a',
                usage: 'Contorno de avisos da marca',
            },
            {
                name: 'Texto primário',
                token: '--color-primary-ink',
                light: '#08422f',
                dark: '#b9eed6',
                usage: 'Texto sobre a primária suave',
            },
            {
                name: 'Sobre a primária',
                token: '--color-on-primary',
                light: '#ffffff',
                dark: '#04160f',
                usage: 'Texto dentro de botões primários',
            },
        ],
    },
    {
        title: 'Feedback',
        tokens: [
            {
                name: 'Sucesso',
                token: '--color-success',
                light: '#0a8659',
                dark: '#35c78d',
                usage: 'Operação concluída',
            },
            {
                name: 'Sucesso suave',
                token: '--color-success-soft',
                light: '#ebfbf4',
                dark: '#0f2c23',
                usage: 'Fundo de mensagens de sucesso',
            },
            {
                name: 'Erro',
                token: '--color-danger',
                light: '#c6303d',
                dark: '#f0707c',
                usage: 'Falhas, validações e ações destrutivas',
            },
            {
                name: 'Erro suave',
                token: '--color-danger-soft',
                light: '#fdecee',
                dark: '#2d1519',
                usage: 'Fundo de mensagens de erro',
            },
            {
                name: 'Atenção',
                token: '--color-warning',
                light: '#b0740c',
                dark: '#dda24a',
                usage: 'Situações que pedem cuidado',
            },
            {
                name: 'Atenção suave',
                token: '--color-warning-soft',
                light: '#fdf4e3',
                dark: '#2c2214',
                usage: 'Fundo de mensagens de atenção',
            },
        ],
    },
    {
        title: 'Tinta',
        tokens: [
            {
                name: 'Tinta',
                token: '--color-ink',
                light: '#062017',
                dark: '#0e241d',
                usage: 'Menu lateral e cartões de destaque',
            },
            {
                name: 'Tinta elevada',
                token: '--color-ink-raised',
                light: '#0a2d20',
                dark: '#143026',
                usage: 'Elementos flutuantes sobre a tinta',
            },
            {
                name: 'Tinta em hover',
                token: '--color-ink-hover',
                light: '#0f3a2a',
                dark: '#1a3a2e',
                usage: 'Item de menu ativo ou sob o cursor',
            },
            {
                name: 'Texto sobre a tinta',
                token: '--color-ink-muted',
                light: '#8bb4a3',
                dark: '#8fb4a3',
                usage: 'Texto secundário sobre a tinta',
            },
            {
                name: 'Linha sobre a tinta',
                token: '--color-ink-line',
                light: '#17452f',
                dark: '#234638',
                usage: 'Divisores sobre a tinta',
            },
        ],
    },
];

const effectVariables: Record<Theme, Record<string, string>> = {
    light: {
        '--color-surface-glass': 'rgba(255, 255, 255, 0.82)',
        '--shadow-xs': '0 1px 2px rgba(6, 32, 23, 0.05)',
        '--shadow': '0 1px 2px rgba(6, 32, 23, 0.04), 0 4px 16px -4px rgba(6, 32, 23, 0.06)',
        '--shadow-lg': '0 2px 4px rgba(6, 32, 23, 0.04), 0 16px 40px -12px rgba(6, 32, 23, 0.16)',
        '--shadow-brand': '0 4px 14px -6px rgba(10, 134, 89, 0.35)',
        '--ring-brand': '0 0 0 3px rgba(18, 165, 110, 0.18)',
        '--ring-danger': '0 0 0 3px rgba(198, 48, 61, 0.16)',
    },
    dark: {
        '--color-surface-glass': 'rgba(11, 28, 23, 0.86)',
        '--shadow-xs': '0 1px 2px rgba(0, 0, 0, 0.35)',
        '--shadow': '0 1px 2px rgba(0, 0, 0, 0.3), 0 4px 16px -4px rgba(0, 0, 0, 0.45)',
        '--shadow-lg': '0 2px 4px rgba(0, 0, 0, 0.3), 0 16px 40px -12px rgba(0, 0, 0, 0.6)',
        '--shadow-brand': '0 4px 14px -6px rgba(20, 176, 119, 0.5)',
        '--ring-brand': '0 0 0 3px rgba(20, 176, 119, 0.25)',
        '--ring-danger': '0 0 0 3px rgba(240, 112, 124, 0.22)',
    },
};

export function themeVariables(theme: Theme): Record<string, string> {
    const colors = Object.fromEntries(
        semanticGroups.flatMap((group) => group.tokens).map((token) => [token.token, token[theme]])
    );

    return { ...colors, ...effectVariables[theme], colorScheme: theme };
}

export const typeScale: TypeStyle[] = [
    {
        name: 'Display',
        family: 'display',
        size: 64,
        weight: 800,
        lineHeight: 1.05,
        tracking: -2.2,
        previewSize: 'clamp(2.25rem, 7vw, 4rem)',
        sample: 'Um banco inteiro.',
    },
    {
        name: 'Título 1',
        family: 'display',
        size: 40,
        weight: 700,
        lineHeight: 1.12,
        tracking: -2.2,
        previewSize: 'clamp(1.75rem, 5vw, 2.5rem)',
        sample: 'Contas particionadas',
    },
    {
        name: 'Título 2',
        family: 'display',
        size: 30,
        weight: 700,
        lineHeight: 1.2,
        tracking: -2.2,
        previewSize: 'clamp(1.5rem, 4vw, 1.875rem)',
        sample: 'Transferir entre agências',
    },
    {
        name: 'Título 3',
        family: 'display',
        size: 20,
        weight: 700,
        lineHeight: 1.3,
        tracking: -2.2,
        previewSize: '1.25rem',
        sample: 'Extrato consolidado',
    },
    {
        name: 'Corpo grande',
        family: 'sans',
        size: 17,
        weight: 400,
        lineHeight: 1.6,
        tracking: 0,
        previewSize: '1.0625rem',
        sample: 'O saldo somado das três agências, em uma única tela.',
    },
    {
        name: 'Corpo',
        family: 'sans',
        size: 15,
        weight: 400,
        lineHeight: 1.55,
        tracking: 0,
        previewSize: '0.9375rem',
        sample: 'A transferência foi publicada para a agência de destino.',
    },
    {
        name: 'Legenda',
        family: 'sans',
        size: 13,
        weight: 500,
        lineHeight: 1.5,
        tracking: 0,
        previewSize: '0.8125rem',
        sample: 'Conta 6 · Agência 0',
    },
    {
        name: 'Sobretítulo',
        family: 'display',
        size: 11,
        weight: 700,
        lineHeight: 1.4,
        tracking: 14,
        previewSize: '0.6875rem',
        sample: 'Saldo disponível',
        uppercase: true,
    },
];

export const radiusTokens: RadiusToken[] = [
    { name: 'Extra pequeno', token: '--radius-xs', value: 8, usage: 'Blocos de grade e chips' },
    { name: 'Padrão', token: '--radius', value: 12, usage: 'Botões, campos e avisos' },
    { name: 'Médio', token: '--radius-md', value: 14, usage: 'Elementos flutuantes' },
    { name: 'Cartão', token: '--radius-card', value: 18, usage: 'Cartões de conteúdo' },
    { name: 'Grande', token: '--radius-lg', value: 20, usage: 'Painéis em destaque' },
    { name: 'Extra grande', token: '--radius-xl', value: 24, usage: 'Cartão de saldo e chamadas' },
];

export const shadowTokens: ShadowToken[] = [
    { name: 'Mínima', token: '--shadow-xs', usage: 'Cartões em repouso' },
    { name: 'Padrão', token: '--shadow', usage: 'Hover de botões secundários' },
    { name: 'Elevada', token: '--shadow-lg', usage: 'Avisos e painéis flutuantes' },
    { name: 'Marca', token: '--shadow-brand', usage: 'Botão primário' },
];

export const motionTokens: MotionToken[] = [
    { name: 'Interação', duration: 180, usage: 'Hover, foco e troca de cor' },
    { name: 'Transição', duration: 300, usage: 'Menu, cabeçalho e tema' },
    { name: 'Revelação', duration: 600, usage: 'Entrada de conteúdo na rolagem' },
];

export const brandIcons: BrandIcon[] = [
    { name: 'Início', path: 'M3 10.5 12 3l9 7.5V21H3z' },
    { name: 'Depositar', path: 'M12 19V5M5 12l7-7 7 7' },
    { name: 'Sacar', path: 'M12 5v14M5 12l7 7 7-7' },
    { name: 'Transferir', path: 'M4 8h13m0 0-4-4m4 4-4 4M20 16H7m0 0 4 4m-4-4 4-4' },
    { name: 'Abrir conta', path: 'M12 5v14M5 12h14' },
    {
        name: 'Novo correntista',
        path: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM19 8v6M22 11h-6',
    },
    {
        name: 'Mostrar saldo',
        path: 'M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7ZM15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z',
    },
    { name: 'Concluído', path: 'm4 12.5 5 5L20 6.5' },
    { name: 'Atenção', path: 'M12 8v5M12 16.5h.01M12 3 2.5 20h19L12 3Z' },
    { name: 'Informação', path: 'M12 16v-5M12 8h.01M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z' },
    { name: 'Avançar', path: 'M5 12h13m0 0-5-5m5 5-5 5' },
    { name: 'Sair', path: 'M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9' },
];

export const voiceGuidelines: VoiceGuideline[] = [
    {
        title: 'Direto',
        description: 'Diga o que aconteceu e o que a pessoa pode fazer, na primeira frase.',
        prefer: 'Saldo insuficiente. Escolha um valor de até R$ 800,00.',
        avoid: 'Ops! Parece que algo não saiu como esperado com a sua operação.',
    },
    {
        title: 'Transparente',
        description: 'Quando algo falha, conte qual parte falhou em vez de esconder o problema.',
        prefer: 'A Agência 2 não respondeu. O total mostra só as contas disponíveis.',
        avoid: 'Erro ao carregar os dados.',
    },
    {
        title: 'Próximo',
        description:
            'Fale com a pessoa usando "você", sem jargão técnico nem formalidade excessiva.',
        prefer: 'Você saiu da sua conta com segurança.',
        avoid: 'A sessão do usuário foi finalizada pelo servidor de autenticação.',
    },
    {
        title: 'Preciso com valores',
        description: 'Dinheiro sempre no formato brasileiro, com símbolo, milhar e centavos.',
        prefer: 'R$ 1.250,00',
        avoid: '1250.0 reais',
    },
];
