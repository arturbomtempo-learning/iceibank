import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

export interface Agency {
    id: number;
    url: string;
    label: string;
}

export const AUTOMATIC_ROUTING = 'auto';

export type AgencySelection = number | typeof AUTOMATIC_ROUTING;

const STORAGE_KEY = 'iceibank.agency';

const agencies: Agency[] = import.meta.env.VITE_AGENCY_URLS.split(',')
    .map((url) => url.trim())
    .filter((url) => url.length > 0)
    .map((url, index) => ({ id: index, url, label: `Agência ${index}` }));

function isKnownAgencyId(id: number): boolean {
    return agencies.some((agency) => agency.id === id);
}

function readStoredSelection(): AgencySelection {
    const storedSelection = window.localStorage.getItem(STORAGE_KEY);
    if (storedSelection === null || storedSelection === AUTOMATIC_ROUTING) {
        return AUTOMATIC_ROUTING;
    }

    const storedId = Number(storedSelection);
    return isKnownAgencyId(storedId) ? storedId : AUTOMATIC_ROUTING;
}

export const useAgencyStore = defineStore('agency', () => {
    const selection = ref<AgencySelection>(readStoredSelection());

    const options = computed(() => agencies);

    const isAutomatic = computed(() => selection.value === AUTOMATIC_ROUTING);

    const gateway = computed(() =>
        isAutomatic.value ? agencies[0] : agencies.find((agency) => agency.id === selection.value)
    );

    function agencyForAccount(accountId: number): Agency | undefined {
        return agencies[accountId % agencies.length];
    }

    function resolveAgency(accountId?: number): Agency | undefined {
        if (!isAutomatic.value) return gateway.value;
        if (accountId === undefined || !Number.isInteger(accountId) || accountId < 0) {
            return gateway.value;
        }

        return agencyForAccount(accountId);
    }

    function resolveBaseUrl(accountId?: number): string {
        return resolveAgency(accountId)?.url ?? import.meta.env.VITE_API_URL;
    }

    function urlForAgency(agencyId: number): string {
        return agencies[agencyId]?.url ?? import.meta.env.VITE_API_URL;
    }

    function labelForAgency(agencyId: number): string {
        return agencies[agencyId]?.label ?? `Agência ${agencyId}`;
    }

    function select(nextSelection: AgencySelection): void {
        if (nextSelection !== AUTOMATIC_ROUTING && !isKnownAgencyId(nextSelection)) return;

        selection.value = nextSelection;
        window.localStorage.setItem(STORAGE_KEY, String(nextSelection));
    }

    return {
        selection,
        options,
        isAutomatic,
        gateway,
        agencyForAccount,
        resolveAgency,
        resolveBaseUrl,
        urlForAgency,
        labelForAgency,
        select,
    };
});
