import 'vue-router';

import type { PageSeo } from '@/app/seo/pages';

declare module 'vue-router' {
    interface RouteMeta {
        requiresAuth?: boolean;
        requiresGuest?: boolean;
        requiresManager?: boolean;
        seo?: PageSeo;
    }
}
