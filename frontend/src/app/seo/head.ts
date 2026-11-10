import type { RouteLocationNormalized } from 'vue-router';

import { DEFAULT_DESCRIPTION, formatTitle, robotsDirective, SITE_NAME } from './pages';

type MetaAttribute = 'name' | 'property';

function setMeta(attribute: MetaAttribute, key: string, content: string): void {
    let element = document.head.querySelector<HTMLMetaElement>(`meta[${attribute}="${key}"]`);

    if (!element) {
        element = document.createElement('meta');
        element.setAttribute(attribute, key);
        document.head.append(element);
    }

    element.content = content;
}

function setCanonical(href: string): void {
    let element = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');

    if (!element) {
        element = document.createElement('link');
        element.rel = 'canonical';
        document.head.append(element);
    }

    element.href = href;
}

export function applyRouteHead(route: RouteLocationNormalized): void {
    const seo = route.meta.seo;
    const title = formatTitle(seo?.title ?? SITE_NAME);
    const description = seo?.description ?? DEFAULT_DESCRIPTION;
    const url = `${window.location.origin}${route.path}`;

    document.title = title;

    setMeta('name', 'description', description);
    setMeta('name', 'robots', robotsDirective(seo?.indexable));
    setMeta('property', 'og:title', title);
    setMeta('property', 'og:description', description);
    setMeta('property', 'og:url', url);
    setMeta('name', 'twitter:title', title);
    setMeta('name', 'twitter:description', description);
    setCanonical(url);
}
