import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';

import type { Plugin } from 'vite';

import { formatTitle, sitePages, robotsDirective, type SitePage } from '../src/app/seo/pages.ts';

interface SeoPluginOptions {
    siteUrl: string;
}

const pages: SitePage[] = Object.values(sitePages);

const homePage: SitePage = sitePages.home;

function escapeAttribute(value: string): string {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
}

function absoluteUrl(siteUrl: string, path: string): string {
    return `${siteUrl}${path}`;
}

function renderPage(html: string, page: SitePage, siteUrl: string): string {
    return html
        .replaceAll('__SEO_TITLE__', escapeAttribute(formatTitle(page.title)))
        .replaceAll('__SEO_DESCRIPTION__', escapeAttribute(page.description))
        .replaceAll('__SEO_ROBOTS__', robotsDirective(page.indexable))
        .replaceAll('__SEO_URL__', escapeAttribute(absoluteUrl(siteUrl, page.path)));
}

function pageForUrl(url: string | undefined): SitePage {
    const pathname = new URL(url ?? '/', 'http://localhost').pathname;
    return pages.find((page) => page.path === pathname) ?? homePage;
}

function htmlFileFor(page: SitePage): string {
    return page.path === '/' ? 'index.html' : `${page.path.slice(1)}.html`;
}

function robotsTxt(siteUrl: string): string {
    return ['User-agent: *', 'Allow: /', '', `Sitemap: ${siteUrl}/sitemap.xml`, ''].join('\n');
}

function sitemapXml(siteUrl: string): string {
    const urls = pages
        .filter((page) => page.indexable)
        .map(
            (page) => `    <url>\n        <loc>${absoluteUrl(siteUrl, page.path)}</loc>\n    </url>`
        );

    return [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
        ...urls,
        '</urlset>',
        '',
    ].join('\n');
}

export function seo(options: SeoPluginOptions): Plugin {
    const siteUrl = options.siteUrl.replace(/\/+$/, '');

    let isBuild = false;

    return {
        name: 'iceibank:seo',
        configResolved(config) {
            isBuild = config.command === 'build';
        },
        transformIndexHtml: {
            order: 'pre',
            handler(html, context) {
                const withSiteUrl = html.replaceAll('__SITE_URL__', siteUrl);
                return isBuild
                    ? withSiteUrl
                    : renderPage(withSiteUrl, pageForUrl(context.originalUrl), siteUrl);
            },
        },
        generateBundle() {
            this.emitFile({ type: 'asset', fileName: 'robots.txt', source: robotsTxt(siteUrl) });
            this.emitFile({ type: 'asset', fileName: 'sitemap.xml', source: sitemapXml(siteUrl) });
        },
        async writeBundle(outputOptions, bundle) {
            const template = bundle['index.html'];
            const outputDir = outputOptions.dir;
            if (!template || template.type !== 'asset' || !outputDir) return;

            const html = String(template.source);

            await Promise.all(
                pages.map(async (page) => {
                    const file = join(outputDir, htmlFileFor(page));
                    await mkdir(dirname(file), { recursive: true });
                    await writeFile(file, renderPage(html, page, siteUrl));
                })
            );
        },
    };
}
