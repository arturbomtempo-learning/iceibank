import { ref, type Ref } from 'vue';
import type { ZodType } from 'zod';

type FieldErrors<TDraft> = Partial<Record<keyof TDraft, string>>;

export function useForm<TDraft extends Record<string, unknown>, TValues>(
    schema: ZodType<TValues>,
    initialValues: TDraft
) {
    const values = ref({ ...initialValues }) as Ref<TDraft>;
    const errors = ref({}) as Ref<FieldErrors<TDraft>>;
    const isSubmitting = ref(false);

    function clearErrors(): void {
        errors.value = {};
    }

    function reset(): void {
        values.value = { ...initialValues };
        clearErrors();
    }

    function validate(): TValues | null {
        const result = schema.safeParse(values.value);

        if (result.success) {
            clearErrors();
            return result.data;
        }

        const nextErrors: FieldErrors<TDraft> = {};

        for (const issue of result.error.issues) {
            const field = issue.path[0] as keyof TDraft | undefined;
            if (field !== undefined && nextErrors[field] === undefined) {
                nextErrors[field] = issue.message;
            }
        }

        errors.value = nextErrors;
        return null;
    }

    async function handleSubmit(onValid: (validValues: TValues) => Promise<void> | void) {
        const validValues = validate();
        if (!validValues) return;

        isSubmitting.value = true;

        try {
            await onValid(validValues);
        } finally {
            isSubmitting.value = false;
        }
    }

    return { values, errors, isSubmitting, handleSubmit, reset, clearErrors };
}
