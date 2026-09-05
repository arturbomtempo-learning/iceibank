import { z } from 'zod';

export const createCustomerSchema = z.object({
    username: z
        .string()
        .trim()
        .min(3, 'O usuário deve ter pelo menos 3 caracteres.')
        .regex(
            /^[a-z0-9._-]+$/,
            'Use apenas letras minúsculas, números, ponto, hífen ou sublinhado.'
        ),
    password: z.string().min(6, 'A senha deve ter pelo menos 6 caracteres.'),
});

export type CreateCustomerValues = z.infer<typeof createCustomerSchema>;

export type CreateCustomerDraft = {
    username: string;
    password: string;
};
