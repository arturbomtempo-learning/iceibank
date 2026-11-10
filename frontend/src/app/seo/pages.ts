export const SITE_NAME = 'ICEIBank';

export const DEFAULT_DESCRIPTION =
    'Internet banking distribuído em três agências independentes, com saldo consolidado, transferências entre agências e sessão autenticada.';

export interface PageSeo {
    title: string;
    description?: string;
    indexable?: boolean;
}

export interface SitePage extends Required<PageSeo> {
    path: string;
}

const PRIVATE_DESCRIPTION = 'Área autenticada do internet banking do ICEIBank.';

export const sitePages = {
    home: {
        path: '/',
        title: 'ICEIBank · Internet banking distribuído em três agências',
        description: DEFAULT_DESCRIPTION,
        indexable: true,
    },
    brand: {
        path: '/identidade-visual',
        title: 'Identidade visual',
        description:
            'Design system do ICEIBank: logo, cores, tipografia, mascote, temas, componentes e regras de escrita do internet banking.',
        indexable: true,
    },
    login: {
        path: '/login',
        title: 'Acessar sua conta',
        description: 'Entre no internet banking do ICEIBank com seu usuário e senha.',
        indexable: false,
    },
    dashboard: {
        path: '/painel',
        title: 'Painel',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
    deposit: {
        path: '/depositar',
        title: 'Depositar',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
    withdraw: {
        path: '/sacar',
        title: 'Sacar',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
    transfer: {
        path: '/transferir',
        title: 'Transferir',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
    newAccount: {
        path: '/abrir-conta',
        title: 'Abrir conta',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
    newCustomer: {
        path: '/novo-correntista',
        title: 'Novo correntista',
        description: PRIVATE_DESCRIPTION,
        indexable: false,
    },
} satisfies Record<string, SitePage>;

export function formatTitle(title: string): string {
    return title.includes(SITE_NAME) ? title : `${title} · ${SITE_NAME}`;
}

export function robotsDirective(indexable: boolean | undefined): string {
    return indexable ? 'index, follow' : 'noindex, nofollow';
}
