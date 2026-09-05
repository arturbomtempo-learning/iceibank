import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

export interface Agency {
    id: number;
    url: string;
    label: string;
}

const STORAGE_KEY = 'iceibank.agency';

const agencies: Agency[] = import.meta.env.VITE_AGENCY_URLS.split(',')
    .map((url) => url.trim())
    .filter((url) => url.length > 0)
    .map((url, index) => ({ id: index, url, label: `Agência ${index}` }));

function readStoredAgencyId(): number {
    const storedId = Number(window.localStorage.getItem(STORAGE_KEY));
    const isKnownAgency = agencies.some((agency) => agency.id === storedId);

    return isKnownAgency ? storedId : (agencies[0]?.id ?? 0);
}

export const useAgencyStore = defineStore('agency', () => {
    const selectedId = ref(readStoredAgencyId());

    const options = computed(() => agencies);

    const selected = computed(
        () => agencies.find((agency) => agency.id === selectedId.value) ?? agencies[0]
    );

    const baseUrl = computed(() => selected.value?.url ?? import.meta.env.VITE_API_URL);

    function select(id: number): void {
        if (!agencies.some((agency) => agency.id === id)) return;

        selectedId.value = id;
        window.localStorage.setItem(STORAGE_KEY, String(id));
    }

    return { selectedId, options, selected, baseUrl, select };
});
